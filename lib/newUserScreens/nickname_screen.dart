import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_new_app/newUserScreens/birthdate_screen.dart';  // Using Get for Snackbar notifications

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({super.key});

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Your Nickname')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please enter a nickname:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _onNextButtonPressed,
                    child: const Text('Next'),
                  ),
          ],
        ),
      ),
    );
  }

  // Handler for when the "Next" button is pressed
  Future<void> _onNextButtonPressed() async {
    String nickname = _nicknameController.text.trim();
    
    if (nickname.isEmpty) {
      Get.snackbar('Error', 'Please enter a nickname.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if the nickname already exists in Firestore
      bool exists = await _nicknameExists(nickname);

      if (exists) {
        Get.snackbar('Error', 'This nickname is already taken. Please choose another.');
      } else {
        await _saveNickname(nickname);
        Get.snackbar('Success', 'Nickname saved successfully!');
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const BirthdateScreen()),
);

      }
    } catch (error) {
      Get.snackbar('Error', 'An error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to check if a nickname already exists
  Future<bool> _nicknameExists(String nickname) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // Method to save the nickname to Firestore
  Future<void> _saveNickname(String nickname) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nickname': nickname,
      }, SetOptions(merge: true));
    }
  }
}
