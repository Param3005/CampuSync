import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [];

  bool isLoading = false;

  bool isAttendanceQuestion(String message) {
    final lower = message.toLowerCase();
    return lower.contains('attendance') || lower.contains('present');
  }

  Future<String> getAttendanceSummary() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return "Please log in first so I can check your attendance.";
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('studentId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        return "No attendance records found yet.";
      }

      final subjectCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final subject = (data['subject'] ?? 'Unknown subject').toString();
        subjectCounts[subject] = (subjectCounts[subject] ?? 0) + 1;
      }

      final total = snapshot.docs.length;
      final subjects = subjectCounts.entries
          .map((entry) => "${entry.key}: ${entry.value}")
          .join("\n");

      return "You have $total attendance record${total == 1 ? '' : 's'}.\n$subjects";
    } catch (e) {
      debugPrint("Attendance fetch failed: $e");
      return "I couldn't fetch your attendance data right now. Please check your Firestore permissions and try again.";
    }
  }

  void sendMessage() async {
    String userMessage = controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userMessage});
      controller.clear();
      isLoading = true;
    });

    final reply = isAttendanceQuestion(userMessage)
        ? await getAttendanceSummary()
        : await askAI(userMessage);

    setState(() {
      messages.add({"role": "ai", "text": reply});
      isLoading = false; // 👈 ALWAYS reset
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Assistant 🤖")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUserMessage = msg["role"] == "user";

                return Container(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.blue
                          : const Color(0xFFE9D5FF),
                      border: isUserMessage
                          ? null
                          : Border.all(
                              color: const Color(0xFF7C3AED),
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(
                        color: isUserMessage
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (isLoading) const CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ask something...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
