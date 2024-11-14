import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import GetX

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Gender')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RadioListTile(
              title: const Text('Male'),
              value: 'Male',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
            RadioListTile(
              title: const Text('Female'),
              value: 'Female',
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value.toString();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedGender != null
                  ? () async {
                      await _saveGender(_selectedGender!);
                      Get.offNamed('/distance'); // Use GetX navigation
                    }
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGender(String gender) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'gender': gender,
      }, SetOptions(merge: true));
    }
  }
}
