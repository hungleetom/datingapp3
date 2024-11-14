import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BirthdateScreen extends StatefulWidget {
  const BirthdateScreen({super.key});

  @override
  _BirthdateScreenState createState() => _BirthdateScreenState();
}

class _BirthdateScreenState extends State<BirthdateScreen> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Birthdate'),
        backgroundColor: Colors.tealAccent[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Step 1 of 3",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedDate == null
                  ? 'Select your birthdate'
                  : 'Selected: ${_selectedDate!.toLocal()}'.split(' ')[0],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectDate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[300],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pick Date',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedDate != null
                  ? () async {
                      await _saveBirthdate(_selectedDate!);
                      Get.offNamed('/gender');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[700],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveBirthdate(DateTime birthdate) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'birthdate': birthdate.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }
}
