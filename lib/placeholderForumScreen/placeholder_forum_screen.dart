import 'package:flutter/material.dart';

class PlaceholderForumScreen extends StatelessWidget {
  const PlaceholderForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum Page (Placeholder)"),
      ),
      body: const Center(
        child: Text(
          "This is a placeholder for the forum page where new users will enter their information.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
