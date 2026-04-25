import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'navigation/main_navigation.dart';
import 'navigation/teacher_navigation.dart';
import 'screens/login_screen.dart';

class CampuSyncApp extends StatelessWidget {
  const CampuSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final roleData = roleSnapshot.data?.data() as Map<String, dynamic>?;
                final role = roleData?['role'] as String? ?? 'student';

                if (role == 'teacher') {
                  return const TeacherNavigation();
                }

                return const MainNavigation();
              },
            );
          } else {
            return const LoginScreen(); // Not logged in
          }
        },
      ),
    );
  }
}
