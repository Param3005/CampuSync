import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentLoginTrackingScreen extends StatefulWidget {
  const StudentLoginTrackingScreen({super.key});

  @override
  State<StudentLoginTrackingScreen> createState() =>
      _StudentLoginTrackingScreenState();
}

class _StudentLoginTrackingScreenState extends State<StudentLoginTrackingScreen> {
  String selectedDate =
      DateTime.now().toIso8601String().split('T')[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Login Tracking 📊"),
        backgroundColor: const Color(0xFF473C33),
      ),
      backgroundColor: const Color(0xFFF5F1EB),
      body: Column(
        children: [
          // Date selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Date:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse(selectedDate),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked.toIso8601String().split('T')[0];
                      });
                    }
                  },
                  child: Text(DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(selectedDate))),
                ),
              ],
            ),
          ),
          // Login count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('loginSessions')
                  .where('date', isEqualTo: selectedDate)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final totalLogins = snapshot.data?.docs.length ?? 0;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9EDC8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Students Logged In:",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        totalLogins.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF473C33),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Student list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('loginSessions')
                  .where('date', isEqualTo: selectedDate)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint("Firestore error: ${snapshot.error}");
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No students logged in today"),
                  );
                }

                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final timeA = (a['loginTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
                    final timeB = (b['loginTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
                    return timeB.compareTo(timeA);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final loginTime = (data['loginTime'] as Timestamp?)
                            ?.toDate() ??
                        DateTime.now();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFD6E6F2),
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          data['name'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Enrollment: ${data['enrollmentNumber'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "Time: ${DateFormat('hh:mm a').format(loginTime)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
