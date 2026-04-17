import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CampuSyncApp());
}

// 🔥 STREAK GLOBAL
int streak = 0;
String lastAttendanceDate = "";


Future<void> loadStreak() async {
  final prefs = await SharedPreferences.getInstance();

  streak = prefs.getInt('streak') ?? 0;
  lastAttendanceDate = prefs.getString('lastDate') ?? "";
}

Future<void> saveStreak() async {
  final prefs = await SharedPreferences.getInstance();

  prefs.setInt('streak', streak);
  prefs.setString('lastDate', lastAttendanceDate);
}

void updateStreak() {
  final today = DateTime.now().toIso8601String().split('T')[0];

  if (lastAttendanceDate == today) return;

  final yesterday = DateTime.now()
      .subtract(const Duration(days: 1))
      .toString()
      .substring(0, 10);

  if (lastAttendanceDate == yesterday) {
    streak += 1;
  } else {
    streak = 1;
  }

  lastAttendanceDate = today;
  saveStreak();
}

Map<String, bool> classStatus = {
  "Internet Of Things": false,
  "E-Commerce": false,
  "Data Warehousing": false,
  "Deep Learning": false,
};

class CampuSyncApp extends StatelessWidget {
  const CampuSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

// ================= NAV =================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final screens = [
    const HomeScreen(),
    NewsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF473C33),
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ================= HOME =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  await loadStreak(); 
  setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    String day = DateFormat('dd').format(now);
    String month = DateFormat('MMMM').format(now).toUpperCase();
    String weekday = DateFormat('EEE').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Good Morning, Mappy 👋",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Streak"),
                  Row(
                    children: [
                      Text("$streak"),
                      const SizedBox(width: 6),
                      Text(
                        streak == 0 ? '😭' : streak < 5 ? '🐣' : '🔥',
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TeacherScreen()),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          child: const Text("Teacher Panel 👩‍🏫"),
                        ),
                                
                        const SizedBox(height: 16),

                        Text(day,
                            style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold)),
                        Text(month),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text("$weekday\nHave a great day 🌤"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TodoScreen()),
                  );
                },
                child: _card(
                  const Color(0xFF9EDC8A),
                  "To-Do",
                  "Tap to manage tasks →",
                ),
              ),

              const SizedBox(height: 20),

              _card(
                const Color(0xFFF8C8DC),
                "Calendar",
                "Tap to view schedule →",
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClassesScreen()),
                  ).then((_){
                    setState((){});
                  });
                },
                child: _card(
                  const Color(0xFF473C33),
                  "Join Classes 📚",
                  "View today's lectures →",
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryScreen(),
                    ),
                  );
                },
                child: _card(
                  Colors.orange,
    "Attendance History 📊",
    "View past attendance →",
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Color color, String title, String footer,
      {Color textColor = Colors.black}) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          Text(footer,
              style: TextStyle(
                  color: Color.fromRGBO(
                      textColor.red, textColor.green, textColor.blue, 0.7))),
        ],
      ),
    );
  }
}

// ================= TODO =================

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> tasks = [];

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
    loadStreak();
  }

  void loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('tasks');
    
    if (data != null) {
      setState(() {
        tasks = data.map((e) {
          final parts = e.split('|');
          return {
            "title": parts[0],
            "done": parts[1] == 'true',
          };
        }).toList();
      });
    }
  }

  void saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = tasks
      .map((task) => "${task['title']}|${task['done']}")
      .toList();
      
    prefs.setStringList('tasks', data);
  }

  void addTask() {
    debugPrint("ADD CLICKED");

    if (controller.text.trim().isEmpty) return;

    setState(() {
      tasks.add({"title": controller.text.trim(), "done": false});
      controller.clear();
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                        const InputDecoration(hintText: "Add a task..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: (){
                    addTask();
                  },
                )
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: tasks[index]["done"],
                    title: Text(tasks[index]["title"]),

                    secondary: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteTask(index);
                        },
                    ),
                    onChanged: (val) {
                      setState(() {
                        tasks[index]["done"] = val!;
                      });
                      saveTasks();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CLASSES =================

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Classes")),
      backgroundColor: const Color(0xFFFFF9F2),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClassCard("Internet Of Things", "Dr. Megha Bansal"),
          ClassCard("E-Commerce", "Ms. Prerna"),
          ClassCard("Data Warehousing", "Dr. Priyanka Gupta"),
          ClassCard("Deep Learning", "Ms. Tanvi Dalal"),
        ],
      ),
    );
  }
}


class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No attendance yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final date = data['date'] ?? "No date";
              final time = data.containsKey('time') ? data['time'] : "--:--";

              return ListTile(
                title: Text(data['subject']),
                subtitle: Text("$date • $time"),
                trailing: const Text("✔",
                    style: TextStyle(color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}

class ClassCard extends StatefulWidget {
  final String subject;
  final String teacher;

  const ClassCard(this.subject, this.teacher, {super.key});

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  bool attendanceMarked = false;

  @override
Widget build(BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.subject)
        .snapshots(),
    builder: (context, snapshot) {

      bool isActive = false;

      if (snapshot.hasData && snapshot.data!.data() != null) {
        final data = snapshot.data!.data() as Map<String, dynamic>;
        isActive = data['isActive'] ?? false;
      }

      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('attendance')
            .where('subject', isEqualTo: widget.subject)
            .where('date', isEqualTo: DateTime.now().toIso8601String().split('T')[0])
            .where('studentId', isEqualTo: 'temp-user')
            .get(),
        builder: (context, snapshot2) {

          bool alreadyMarked = false;

          if (snapshot2.hasData && snapshot2.data!.docs.isNotEmpty) {
            alreadyMarked = true;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E6F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(widget.subject,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 4),

                Text(widget.teacher),

                const SizedBox(height: 12),

                if (isActive)
                  const Text("Class Active 🔴",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold))
                else
                  const Text("Class not active",
                      style: TextStyle(color: Colors.black54)),

                const SizedBox(height: 10),

                if (isActive && !alreadyMarked)
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();

                      final today = now.toIso8601String().split('T')[0];
                      final time = DateFormat('HH:mm').format(now);

                      await FirebaseFirestore.instance
                          .collection('attendance')
                          .add({
                        'subject': widget.subject,
                        'date': today,
                        'time': time,
                        'studentId': 'temp-user',
                      });

                      updateStreak();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Attendance saved for ${widget.subject} ✅"),
                        ),
                      );

                      setState(() {});
                    },
                    child: const Text("Mark Attendance 📸"),
                  ),

                if (alreadyMarked)
                  const Text("Attendance Submitted ✅",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      );
    },
  );
}
}
// ================= NEWS =================

class NewsScreen extends StatelessWidget {
  NewsScreen({super.key});

  final List<Map<String, String>> events = [

    {
      "title": "Aanayat 3.0 – Open Mic Competition",
      "date": "13 April 2026",
      "full": """✨ UNCUT – Literary Society, VSBS presents ✨

🎤 Aanayat 3.0 – Open Mic Competition

“Shabdon se sur tak, har hunar ka ek hi manch.”

We are excited to invite you to showcase your talent at Aanayat 3.0! Whether it’s poetry, music, storytelling, or any form of expression — this is your stage to shine.

📅 Date: 13th April 2026
⏰ Time: 11 AM onwards
📍 Venue: GDPI Room, A Block

🏆 Win exciting prizes up to ₹5,000!

Don’t miss this opportunity to express, perform, and inspire. Scan the QR code on the poster to register now!

See you on stage! 🌟"""
    },

    {
      "title": "Mega Health Camp 🏥",
      "date": "1 April 2026",
      "full": """Mega Health Camp 🏥

"Health is the greatest wealth."

The NSS unit of VIPS-TC is organizing a Mega Health Camp, the biggest event of the semester, aimed at promoting health awareness and encouraging preventive healthcare among students and staff.

📅 Date: 1st April 2026
📍 Venue: Conference Room, B-Block
🕒 Timings: 10 AM onwards

⚠️ Attendance of all volunteers for health check-up is compulsory.
⚠️ Attendance of all female volunteers for session is compulsory.

📌 Volunteers will be awarded extra NSS credits.

For any queries:
Ananya Chauhan: +91 88003 01006
Riya: +91 9220458425

Regards
NSS VIPS-TC"""
    },

    {
      "title": "Period Pain Stimulation Event",
      "date": "15 April 2026",
      "full": """“Understanding pain builds empathy — experience it to respect it!”

The NSS Unit of VIPS-TC is organizing a Period Pain Stimulation Event to spread awareness and break stigmas surrounding menstrual health.

📅 Date: 15th April 2026
⏰ Time: 11:00 AM onwards
📍 Venue: Between A–B Block

📌 Open for all students
📌 NSS HOURS WILL BE PROVIDED

Contact:
Gaurika: 9971715297
Vanshika: 8569991819"""
    },

    {
      "title": "Scribble Day ✍️👕",
      "date": "17 April 2026",
      "full": """BCA'26 SCRIBBLE DAY!

The pens are ready, the wall is waiting, and the memories are calling!

📅 Date: 17th April
🕛 Time: 12:00 PM – 3:00 PM
📍 Behind C Block

Celebrate your journey, friendships, and memories.

Organised by Cultural Society, VSIT"""
    },

    {
      "title": "Food Donation Drive",
      "date": "9 April 2026",
      "full": """Food Donation Drive

We are organising a Food Donation Drive to support the underprivileged.

Donate rice, grains, pulses, biscuits, or packaged food.

Even a small contribution can make a difference.

Let’s help together ❤️"""
    },

    {
      "title": "Creative Exhibition 🌍",
      "date": "21 April 2026",
      "full": """Creative Exhibition

On World Creativity Day, VSIT is organising an exhibition for innovative ideas aligned with SDGs.

📅 Event Date: 21 April 2026
📍 Room 807, Block-C

🎓 E-Certificates for all participants

Showcase your creativity and innovation!"""
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus News")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsDetailScreen(
                    event["title"]!,
                    event["full"]!,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event["title"]!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(event["date"]!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// DETAIL SCREEN

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String full;

  const NewsDetailScreen(this.title, this.full, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          full,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// ================= PROFILE =================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    initData();   
  }

  void initData() async {
  await loadStreak();
  setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              Text(
                "Mappy",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF473C33),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Keep going, you're doing great.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Streak",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$streak days 🔥",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teacher Panel")),
      backgroundColor: const Color(0xFFFFF9F2),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: classStatus.keys.map((subject) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD6E6F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Expanded(
          child: Text(
            subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('classes')
              .doc(subject)
              .snapshots(),
          builder: (context, snapshot) {
            bool isActive = false;

            if (snapshot.hasData && snapshot.data!.data() != null) {
              final data = snapshot.data!.data()!;
              isActive = data['isActive'] ?? false;
            }

            return Switch(
              value: isActive,
              onChanged: (value) async {
                await FirebaseFirestore.instance
                    .collection('classes')
                    .doc(subject)
                    .set({'isActive': value});
              },
            );
          },
        ),
      ],
    ),

    const SizedBox(height: 10),

    ElevatedButton(
      onPressed: () async {
        final today =
            DateTime.now().toIso8601String().split('T')[0];

        final snapshot = await FirebaseFirestore.instance
            .collection('attendance')
            .where('subject', isEqualTo: subject)
            .where('date', isEqualTo: today)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset done for $subject")),
        );
      },
      child: const Text("Reset Attendance 🔄"),
    ),
  ],
),
          );
        }).toList(),
      ),
    );
  }
}