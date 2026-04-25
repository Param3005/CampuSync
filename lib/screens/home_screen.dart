import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../calendar_screen.dart';
import '../streak.dart';
import 'attendance_history_screen.dart';
import 'chat_screen.dart';
import 'classes_screen.dart';
import 'todo_screen.dart';

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
      backgroundColor: const Color(0xFFF8F6F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, snapshot) {

                  String name = "User";

                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['name'] ?? "User";
                  }

                  return Text(
                    "Good Morning, $name 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),


              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Streak",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF473C33),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        "$streak",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF473C33),
                        ),
                      ),

                      const SizedBox(width: 6),
                      Image.asset(
                        streak == 0
                            ? 'assets/images/sad.png'
                            : streak < 2
                            ? 'assets/images/happy.png'
                            : 'assets/images/streak.png',
                        height: 35,
                      ),
                    ],
                  ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(month),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(child: Text("$weekday\nHave a great day 🌤")),
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
                  "To-Do 📝",
                  "Tap to manage tasks →",
                ),
              ),

              const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalendarScreen(),
                  ),
                );
              },
              child: _card(
                const Color(0xFFF8C8DC),
                "Calendar 📅",
                "Tap to view schedule →",
              ),
            ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
                },
                child: _card(
                  const Color(0xFFB39DDB),
                  "AI Assistant 🤖",
                  "Ask anything →",
                ),
              ),
                const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClassesScreen()),
                  ).then((_) {
                    setState(() {});
                  });
                },
                child: _card(
                  const Color(0xFF90CAF9),
                  "Join Classes 📚",
                  "View today's lectures →",

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
                  const Color(0xFFFFF176),
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

  Widget _card(
    Color color,
    String title,
    String footer, {
    Color textColor = Colors.black,
  }) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            footer,
            style: TextStyle(
              color: Color.fromRGBO(
                textColor.red,
                textColor.green,
                textColor.blue,
                0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
