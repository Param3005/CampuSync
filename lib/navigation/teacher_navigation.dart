import 'package:flutter/material.dart';

import '../screens/news_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/teacher_screen.dart';

class TeacherNavigation extends StatefulWidget {
  const TeacherNavigation({super.key});

  @override
  State<TeacherNavigation> createState() => _TeacherNavigationState();
}

class _TeacherNavigationState extends State<TeacherNavigation> {
  int currentIndex = 0;

  final screens = [const TeacherScreen(), NewsScreen(), const ProfileScreen()];

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
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Teacher"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
