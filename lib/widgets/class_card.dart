import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../auth_helpers.dart';
import '../streak.dart';

bool get _isMobileWeb {
  if (!kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
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
  File? image;

  Future<void> captureImage() async {
    final picker = ImagePicker();
    
    try {
      var picked = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      // Fallback for iOS Safari/web where camera might not work
      if (picked == null && kIsWeb) {
        picked = await picker.pickImage(source: ImageSource.gallery);
      }

      if (picked != null) {
        setState(() {
          image = File(picked!.path);
        });
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      // Fallback to gallery on error
      try {
        final picked = await picker.pickImage(source: ImageSource.gallery);
        if (picked != null) {
          setState(() {
            image = File(picked.path);
          });
        }
      } catch (galleryError) {
        debugPrint("Gallery error: $galleryError");
      }
    }
  }

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
              .where(
                'date',
                isEqualTo: DateTime.now().toIso8601String().split('T')[0],
              )
              .where(
                      'studentId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(widget.teacher),

                  const SizedBox(height: 12),

                  if (isActive)
                    const Text(
                      "Class Active 🔴",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      "Class not active",
                      style: TextStyle(color: Colors.black54),
                    ),

                  const SizedBox(height: 10),

                  if (isActive && !alreadyMarked)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64B5F6),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        bool authenticated;

                        if (kIsWeb) {
                          authenticated = await showPasswordDialog(
                            context,
                            () async {},
                          );
                        } else {
                          authenticated = await authenticateUser();
                        }

                        if (!authenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Authentication cancelled. Please try again."),
                            ),
                          );
                          return;
                        }

                        if (kIsWeb) {
                          // Show picker dialog to get fresh user gesture for iOS Safari
                          final picker = ImagePicker();
                          final XFile? picked = await showDialog<XFile?>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Capture Photo'),
                              content: const Text('Select how you want to add your photo'),
                              actions: [
                                if (_isMobileWeb)
                                  TextButton(
                                    onPressed: () async {
                                      final result = await picker.pickImage(
                                        source: ImageSource.camera,
                                        preferredCameraDevice: CameraDevice.front,
                                      );
                                      if (context.mounted) Navigator.pop(context, result);
                                    },
                                    child: const Text('Camera'),
                                  ),
                                TextButton(
                                  onPressed: () async {
                                    final result = await picker.pickImage(source: ImageSource.gallery);
                                    if (context.mounted) Navigator.pop(context, result);
                                  },
                                  child: const Text('Gallery'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                          if (picked != null) {
                            setState(() {
                              image = File(picked.path);
                            });
                          }
                        } else {
                          await captureImage();
                        }

                        if (image == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No photo captured. Attendance not marked.")),
                          );
                          return;
                        }

                        final now = DateTime.now();
                        final today = now.toIso8601String().split('T')[0];
                        final time = DateFormat('HH:mm').format(now);

                        final user = FirebaseAuth.instance.currentUser!;
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        final userData = userDoc.data() as Map<String, dynamic>;
                        
                        //save attendance
                        await FirebaseFirestore.instance
                            .collection('attendance')
                            .add({
                          'subject': widget.subject,
                          'date': today,
                          'time': time,
                          'studentId': user.uid,
                          'studentName': userData['name'],
                        });

                        updateStreak();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Attendance saved for ${widget.subject} ✅"),
                          ),
                        );

                        setState(() {});
                      },
                      child: const Text("Mark Attendance 📸"),
                    ),

                  if (alreadyMarked)
                    const Text(
                      "Attendance Submitted ✅",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
