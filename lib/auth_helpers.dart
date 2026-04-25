import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';

Future<UserCredential> signInWithGoogle() async {
  final googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) {
    throw Exception('Google sign-in cancelled');
  }

  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredential.user!.uid)
      .get();

  if (!userDoc.exists) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'name': userCredential.user!.displayName ?? 'User',
      'email': userCredential.user!.email ?? '',
      'role': 'student',
    });
  }

  return userCredential;
}

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticateUser() async {
  try {
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final bool isSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isSupported) {
      return false;
    }

    final bool authenticated = await auth.authenticate(
      localizedReason: 'Authenticate to mark attendance',
      options: const AuthenticationOptions(
        biometricOnly: true,
      ),
    );

    return authenticated;
  } catch (e) {
    debugPrint("Auth error: $e");
    return false;
  }
}

Future<bool> showPasswordDialog(
  BuildContext context,
  Future<void> Function() onVerified,
) async {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Verify Identity 🔐"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Enter your password to mark attendance"),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            try {
                              final user = FirebaseAuth.instance.currentUser;

                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: user!.email!,
                                password: passwordController.text.trim(),
                              );

                              Navigator.pop(context, true);
                              await onVerified();
                            } catch (e) {
                              setState(() => isLoading = false);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Wrong password ❌"),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Verify"),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      false;
}
