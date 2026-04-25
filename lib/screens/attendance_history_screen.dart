import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4), 
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: const Color(0xFFFFEB3B),
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where(
              'studentId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint("Attendance history failed: ${snapshot.error}");
            return const Center(child: Text("Unable to load attendance"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final first = a.data() as Map<String, dynamic>;
              final second = b.data() as Map<String, dynamic>;
              return (second['date'] ?? '').toString().compareTo(
                    (first['date'] ?? '').toString(),
                  );
            });

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
                trailing: const Text(
                  "✔",
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
