import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/controller/authentication_controller.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';

class MbtiSelectionScreen extends StatefulWidget {
  const MbtiSelectionScreen({super.key});

  @override
  _MbtiSelectionScreenState createState() => _MbtiSelectionScreenState();
}

class _MbtiSelectionScreenState extends State<MbtiSelectionScreen> {
  final AuthenticationController authController = Get.find<AuthenticationController>();

  // List of the 16 MBTI types
  final List<String> mbtiTypes = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP'
  ];

  String? selectedMbti;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your MBTI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your MBTI type:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: mbtiTypes.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(mbtiTypes[index]),
                    value: mbtiTypes[index],
                    groupValue: selectedMbti,
                    onChanged: (String? value) {
                      setState(() {
                        selectedMbti = value;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedMbti != null ? _submitMbti : null,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle MBTI submission
  void _submitMbti() async {
    if (selectedMbti != null) {
      try {
        await authController.updateUserMbti(selectedMbti!);
        Get.snackbar('MBTI Updated', 'Your MBTI has been successfully saved.');
        
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to the photo upload screen
        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomeScreen()),
);

      } catch (e) {
        Get.snackbar('Error', 'Failed to update MBTI: $e');
      }
    }
  }
}
