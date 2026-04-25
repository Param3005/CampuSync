import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../streak.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
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
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text("Logout"),
              ),

              const SizedBox(height: 10),

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
                  

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF473C33),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Edit Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .update({
                      'name': nameController.text.trim(),
                    });

                    setState(() {}); // refresh UI

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Name updated successfully ✅")),
                    );
                  },
                  child: const Text("Save Name"),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
