import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final enrollmentNumberController = TextEditingController();

  bool isLogin = true;
  String selectedRole = 'Student';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    enrollmentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // 🔥 TITLE
                Text(
                  isLogin ? "CampuSync" : "Create Account ✨",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF473C33),
                  ),
                ),

                const SizedBox(height: 20),

                if (!isLogin)
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      filled: true,
                      fillColor: const Color(0xFFF8F6F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    filled: true,
                    fillColor: const Color(0xFFF8F6F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (!isLogin)
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: "Select Role",
                      filled: true,
                      fillColor: const Color(0xFFF8F6F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Student', 'Teacher']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),

                if (!isLogin && selectedRole == 'Student') const SizedBox(height: 10),

                if (!isLogin && selectedRole == 'Student')
                  TextField(
                    controller: enrollmentNumberController,
                    decoration: InputDecoration(
                      labelText: "Enrollment Number",
                      filled: true,
                      fillColor: const Color(0xFFF8F6F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: const Color(0xFFF8F6F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF473C33),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      if (isLogin) {
                        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                        // Record student login
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user!.uid)
                            .get();

                        if (userDoc.exists && userDoc['role'] == 'Student') {
                          await FirebaseFirestore.instance
                              .collection('loginSessions')
                              .add({
                                'studentId': userCredential.user!.uid,
                                'name': userDoc['name'],
                                'enrollmentNumber': userDoc['enrollmentNumber'] ?? 'N/A',
                                'email': userDoc['email'],
                                'loginTime': FieldValue.serverTimestamp(),
                                'date': DateTime.now().toIso8601String().split('T')[0],
                              });
                        }
                      } else {
                        final userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                        final uid = userCredential.user!.uid;

                        final userData = {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'role': selectedRole,
                        };

                        // Add enrollment number for students
                        if (selectedRole == 'Student') {
                          userData['enrollmentNumber'] = enrollmentNumberController.text.trim();
                        }

                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .set(userData);
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: Text(isLogin ? "Login" : "Sign Up"),
                ),

                if (isLogin)
                  const SizedBox(height: 16),

                
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
