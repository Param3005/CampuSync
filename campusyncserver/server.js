const express = require("express");
const fetch = require("node-fetch");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const logFile = path.join(__dirname, "server.log");

function log(message) {
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] ${message}\n`;
  console.log(logMessage);
  fs.appendFileSync(logFile, logMessage);
}

const app = express(); 
const GROQ_API_KEY = process.env.GROQ_API_KEY;
const GROQ_MODEL = process.env.GROQ_MODEL || "llama-3.3-70b-versatile";
const FIREBASE_PROJECT_ID = process.env.FIREBASE_PROJECT_ID || "campusync-8626d";


app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("CampusSync AI server is running");
});

app.get("/ask", (req, res) => {
  res.send("Use POST /ask with JSON like { \"message\": \"Hello\" }");
});

function getBearerToken(req) {
  const authHeader = req.headers.authorization || "";
  return authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;
}

function decodeFirebaseUid(idToken) {
  const payload = idToken.split(".")[1];
  if (!payload) return null;

  const normalized = payload.replace(/-/g, "+").replace(/_/g, "/");
  const decoded = JSON.parse(Buffer.from(normalized, "base64").toString("utf8"));
  return decoded.user_id || decoded.sub || null;
}

function firestoreValueToJson(value) {
  if (value.stringValue !== undefined) return value.stringValue;
  if (value.integerValue !== undefined) return Number(value.integerValue);
  if (value.doubleValue !== undefined) return value.doubleValue;
  if (value.booleanValue !== undefined) return value.booleanValue;
  if (value.timestampValue !== undefined) return value.timestampValue;
  if (value.nullValue !== undefined) return null;
  return undefined;
}

function firestoreFieldsToJson(fields = {}) {
  return Object.fromEntries(
    Object.entries(fields).map(([key, value]) => [key, firestoreValueToJson(value)])
  );
}

async function getAttendanceSummary(idToken) {
  if (!idToken) {
    return "Please sign in first so I can check your attendance.";
  }

  const uid = decodeFirebaseUid(idToken);
  if (!uid) {
    return "I could not read your Firebase login token. Please sign in again.";
  }

  const response = await fetch(
    `https://firestore.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${idToken}`
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId: "attendance" }],
          where: {
            fieldFilter: {
              field: { fieldPath: "studentId" },
              op: "EQUAL",
              value: { stringValue: uid }
            }
          }
        }
      })
    }
  );

  const data = await response.json();

  if (!response.ok) {
    console.error(data);
    return "I could not fetch your attendance from Firebase yet.";
  }

  const attendance = data
    .filter((row) => row.document)
    .map((row) => firestoreFieldsToJson(row.document.fields));

  if (attendance.length === 0) {
    return "You do not have any attendance entries yet.";
  }

  const bySubject = attendance.reduce((counts, entry) => {
    const subject = entry.subject || "Unknown subject";
    counts[subject] = (counts[subject] || 0) + 1;
    return counts;
  }, {});

  const latest = [...attendance].sort((a, b) => {
    return `${b.date || ""} ${b.time || ""}`.localeCompare(`${a.date || ""} ${a.time || ""}`);
  })[0];

  const subjectLines = Object.entries(bySubject)
    .map(([subject, total]) => `${subject}: ${total}`)
    .join(", ");

  return `You have ${attendance.length} attendance entries. By subject: ${subjectLines}. Latest entry: ${latest.subject || "Unknown subject"} on ${latest.date || "unknown date"} at ${latest.time || "--:--"}.`;
}

app.post("/ask", async (req, res) => {
  log("🔥 /ask endpoint called!");
  const message = req.body.message?.trim();
  log("📝 Message received: " + message);

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  if (message.toLowerCase().includes("attendance")) {
    const text = await getAttendanceSummary(getBearerToken(req));

    return res.json({
      candidates: [
        {
          content: {
            parts: [{ text }]
          }
        }
      ]
    });
  }

  if (!GROQ_API_KEY) {
    log("❌ GROQ_API_KEY is missing!");
    return res.status(500).json({
      error: "Missing GROQ_API_KEY environment variable"
    });
  }

  log("📤 Sending to GROQ API: " + message);
  
  try {
    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${GROQ_API_KEY}`
        },
        body: JSON.stringify({
          model: GROQ_MODEL,
          messages: [
            {
              role: "system",
              content: "You are CampusSync AI, a helpful assistant for students."
            },
            {
              role: "user",
              content: message
            }
          ]
        })
      }
    );

    const data = await response.json();
    log("📥 GROQ Response status: " + response.status);
    log("📥 GROQ Full Response: " + JSON.stringify(data, null, 2));

    if (!response.ok) {
      log("❌ GROQ API Error (not OK): " + JSON.stringify(data));
      return res.status(response.status).json({
        error: data.error?.message || "GROQ API error"
      });
    }

    log("📊 Checking for choices: " + JSON.stringify(data.choices));
    log("📊 First choice: " + JSON.stringify(data.choices?.[0]));
    log("📊 Message: " + JSON.stringify(data.choices?.[0]?.message));
    
    const text = data.choices?.[0]?.message?.content?.trim();
    log("✅ Final text: " + (text || "UNDEFINED/EMPTY"));
    
    if (!text) {
      log("❌ No text found in response. Full response: " + JSON.stringify(data, null, 2));
      return res.json({
        candidates: [
          {
            content: {
              parts: [{ text: "Sorry, I got an empty response from the AI." }]
            }
          }
        ]
      });
    }

    res.json({
      candidates: [
        {
          content: {
            parts: [{ text }]
          }
        }
      ]
    });

  } catch (e) {
    log("❌ Exception: " + (e.message || String(e)));
    res.status(500).json({ error: "Something went wrong: " + e.message });
  }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => log(`Server running on port ${PORT}`));
