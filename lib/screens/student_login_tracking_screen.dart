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
  String selectedDate = DateTime.now().toIso8601String().split('T')[0];

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
                  child: Text(
                    DateFormat('dd MMM yyyy').format(DateTime.parse(selectedDate)),
                  ),
                ),
              ],
            ),
          ),
          // Total Attendance stat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('date', isEqualTo: selectedDate)
                  .snapshots(),
              builder: (context, snapshot) {
                final totalAttendance = snapshot.data?.docs.length ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6E6F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Attendance",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        totalAttendance.toString(),
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
          // Combined student list from BOTH collections
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('loginSessions')
                  .where('date', isEqualTo: selectedDate)
                  .snapshots(),
              builder: (context, loginSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('date', isEqualTo: selectedDate)
                      .snapshots(),
                  builder: (context, attendanceSnapshot) {
                    if (loginSnapshot.connectionState == ConnectionState.waiting ||
                        attendanceSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (loginSnapshot.hasError) {
                      debugPrint("Login Firestore error: ${loginSnapshot.error}");
                      return Center(child: Text("Error: ${loginSnapshot.error}"));
                    }
                    if (attendanceSnapshot.hasError) {
                      debugPrint("Attendance Firestore error: ${attendanceSnapshot.error}");
                      return Center(child: Text("Error: ${attendanceSnapshot.error}"));
                    }

                    // Build login map by studentId
                    final Map<String, Map<String, dynamic>> loginMap = {};
                    if (loginSnapshot.hasData) {
                      for (var doc in loginSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final studentId = data['studentId'] as String?;
                        if (studentId != null && !loginMap.containsKey(studentId)) {
                          loginMap[studentId] = data;
                        }
                      }
                    }

                    // Build attendance map by studentId
                    final Map<String, List<Map<String, dynamic>>> attendanceMap = {};
                    if (attendanceSnapshot.hasData) {
                      for (var doc in attendanceSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final studentId = data['studentId'] as String?;
                        if (studentId != null) {
                          attendanceMap.putIfAbsent(studentId, () => []);
                          attendanceMap[studentId]!.add(data);
                        }
                      }
                    }

                    // Union of all studentIds from both collections
                    final allStudentIds = <String>{...loginMap.keys, ...attendanceMap.keys};

                    if (allStudentIds.isEmpty) {
                      return const Center(
                        child: Text("No students logged in or marked attendance on this date"),
                      );
                    }

                    // Convert to list and sort: students with login sessions first, sorted by login time
                    final studentList = allStudentIds.toList();
                    studentList.sort((a, b) {
                      final loginA = loginMap[a];
                      final loginB = loginMap[b];
                      if (loginA != null && loginB != null) {
                        final timeA = (loginA['loginTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
                        final timeB = (loginB['loginTime'] as Timestamp?)?.toDate() ?? DateTime(1970);
                        return timeB.compareTo(timeA);
                      }
                      if (loginA != null) return -1;
                      if (loginB != null) return 1;
                      return 0;
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: studentList.length,
                      itemBuilder: (context, index) {
                        final studentId = studentList[index];
                        final loginData = loginMap[studentId];
                        final studentAttendance = attendanceMap[studentId] ?? [];

                        final loginTime = (loginData?['loginTime'] as Timestamp?)?.toDate();

                        // Get display name - prefer loginSession name, fallback to attendance name
                        String displayName = loginData?['name'] as String? ?? 'Unknown';
                        if (displayName == 'Unknown' && studentAttendance.isNotEmpty) {
                          displayName = studentAttendance.first['studentName'] as String? ?? 'Unknown';
                        }

                        final enrollmentNumber = loginData?['enrollmentNumber'] as String? ??
                            (studentAttendance.isNotEmpty
                                ? studentAttendance.first['enrollmentNumber'] as String?
                                : null) ??
                            'N/A';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFFD6E6F2),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Enrollment: $enrollmentNumber",
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (loginTime != null)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text(
                                            "Login Time",
                                            style: TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                          Text(
                                            DateFormat('hh:mm a').format(loginTime),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      const Text(
                                        "No login",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(height: 20),
                                // Attendance section
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Color(0xFF473C33),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Attendance:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (studentAttendance.isEmpty)
                                  const Text(
                                    "No attendance marked for this date",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: studentAttendance.map((att) {
                                      final subject = att['subject'] as String? ?? 'Unknown';
                                      final time = att['time'] as String? ?? '--:--';
                                      return Chip(
                                        backgroundColor: const Color(0xFFD6E6F2),
                                        padding: EdgeInsets.zero,
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        label: Text(
                                          "$subject ($time)",
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
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

