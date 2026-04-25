import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
  final String title;
  final String full;

  const NewsDetailScreen(this.title, this.full, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(full, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
