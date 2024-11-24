import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart'; // Import GetX

class PictureScreen extends StatefulWidget {
  const PictureScreen({super.key});

  @override
  _PictureScreenState createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  final List<XFile> _images = [];
  bool _isUploading = false; // Track upload state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Pictures')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  return index == _images.length
                      ? IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _pickImage,
                        )
                      : Image.file(
                          File(_images[index].path),
                          fit: BoxFit.cover,
                        );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _images.isNotEmpty && !_isUploading
                  ? () async {
                      setState(() => _isUploading = true);
                      await _savePictures();
                      setState(() => _isUploading = false);
                      Get.offNamed('/questionnaire'); // Navigation handled using GetX
                    }
                  : null,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(pickedFile);
      });
    }
  }

  Future<void> _savePictures() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Upload images to Firebase Storage
      List<String> imageUrls = await Future.wait(
        _images.map((image) => _uploadImageToStorage(image)),
      );

      // Save image URLs to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photos': imageUrls,
      }, SetOptions(merge: true));
    } catch (e) {
      // Censored error handling for public sharing
      Get.snackbar('Error', 'Failed to upload pictures.');
    }
  }

  Future<String> _uploadImageToStorage(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users/${user!.uid}/${image.name}'); // Sensitive path using UID

    final uploadTask = storageRef.putFile(File(image.path));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL(); // Returns image URL
  }
}
