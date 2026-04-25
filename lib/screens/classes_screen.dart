import 'package:flutter/material.dart';

import '../widgets/class_card.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Classes"),
        backgroundColor: const Color(0xFF90CAF9),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFE3F2FD),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClassCard("Internet Of Things", "Ms. Kanchan Chaudhary"),
          ClassCard("E-Commerce", "Ms. Suchi Chawla"),
          ClassCard("Data Warehousing", "Ms. Ruchika"),
          ClassCard("Deep Learning", "Ms. Lakshmi Kumari"),
        ],
      ),
    );
  }
}
