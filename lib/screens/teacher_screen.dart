import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../calendar_screen.dart';
import '../class_status.dart';
import 'student_login_tracking_screen.dart';
import 'todo_screen.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  @override
  Widget build(BuildContext context) {
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
                  String name = "Teacher";

                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['name'] ?? "Teacher";
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
              const SizedBox(height: 20),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE2E4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Calendar 📅",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text("Tap to view schedule →"),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TodoScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9EDC8A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "To-Do 📝",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text("Tap to manage tasks →"),
                        ],
                      ),
                    ),
                  ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentLoginTrackingScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD6A5C0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Student Login Tracking 📊",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text("View who logged in with enrollment number →"),
                ],
              ),
            ),
          ),
          ...classStatus.keys.map((subject) {
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
                      final today = DateTime.now().toIso8601String().split(
                        'T',
                      )[0];

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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
