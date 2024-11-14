import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  String? gender;
  DateTime? birthdate;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        nicknameController.text = userData?['nickname'] ?? '';
        bioController.text = userData?['bio'] ?? '';
        gender = userData?['gender'];
        birthdate = userData?['birthdate'] != null
            ? DateTime.parse(userData!['birthdate'])
            : null;
      }
    } catch (e) {
      print('Error loading profile: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'nickname': nicknameController.text,
        'bio': bioController.text,
        'gender': gender,
        'birthdate': birthdate?.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Get.offAllNamed('/home', arguments: {'index': 4}); // Navigate to Profile tab
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != birthdate) {
      setState(() {
        birthdate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nickname',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nicknameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your nickname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bio',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tell something about yourself',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gender',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Male'),
                            value: 'male',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Female'),
                            value: 'female',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Birthdate',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          birthdate == null
                              ? 'Select your birthdate'
                              : '${birthdate!.toLocal()}'.split(' ')[0],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => selectBirthdate(context),
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        child: const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
