import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // For phone input with country code detection
import 'package:my_new_app/homeScreen/home_screen.dart';

class PhoneNumberVerificationScreen extends StatefulWidget {
  const PhoneNumberVerificationScreen({super.key});

  @override
  _PhoneNumberVerificationScreenState createState() => _PhoneNumberVerificationScreenState();
}

class _PhoneNumberVerificationScreenState extends State<PhoneNumberVerificationScreen> {
  final TextEditingController smsCodeController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  String phoneNumber = ''; // Store complete phone number with country code
  String verificationId = '';
  bool isCodeSent = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isCodeSent) ...[
              const Text(
                "Please enter your phone number to verify:",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: 'US', // You can change this to detect the user's location
                onChanged: (phone) {
                  setState(() {
                    phoneNumber = phone.completeNumber; // Get full phone number with country code
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => sendVerificationCode(),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Send Verification Code'),
              ),
            ],
            if (isCodeSent) ...[
              const Text(
                "Enter the SMS code sent to your phone:",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: smsCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SMS Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => verifyPhoneNumber(),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Verify Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void sendVerificationCode() async {
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid phone number.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
          savePhoneNumberToFirestore();
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar('Error', 'Failed to verify phone number: ${e.message}');
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
            isCodeSent = true;
            isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void verifyPhoneNumber() async {
    if (smsCodeController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter the verification code.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCodeController.text.trim(),
      );
      await auth.signInWithCredential(credential);
      savePhoneNumberToFirestore();
    } catch (e) {
      Get.snackbar('Error', 'Failed to verify SMS code: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Modify this method to call _storePhoneNumber
  void savePhoneNumberToFirestore() async {
    try {
      await _storePhoneNumber(phoneNumber);
      Get.offAll(() => const HomeScreen()); // Go to home after successful save
    } catch (e) {
      Get.snackbar("Error", "Failed to store phone number: $e");
    }
  }

  // Function to store phone number in Firestore
  Future<void> _storePhoneNumber(String phoneNumber) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid);

        await userRef.set({
          'phoneNumber': phoneNumber,
          'verified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge the data with existing document
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to store phone number: $e");
    }
  }
}
