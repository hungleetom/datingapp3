import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:my_new_app/accountSettingScreen/account_settings_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userID;

  const UserDetailsScreen({super.key, required this.userID});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String name = '', age = '', phoneNumber = '', city = '', country = '', mbti = '';
  DateTime? birthdate;
  final String defaultImageUrl = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    retrieveUserInfo();
  }

  Future<void> retrieveUserInfo() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userID)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          imageUrls = List<String>.from(data["photos"] ?? []);
          if (imageUrls.isEmpty) {
            imageUrls = List.generate(5, (_) => defaultImageUrl);
          } else if (imageUrls.length < 5) {
            imageUrls.addAll(List.generate(5 - imageUrls.length, (_) => defaultImageUrl));
          }

          name = data["nickname"] ?? '';
          age = data['age']?.toString() ?? '';
          phoneNumber = data["phoneNumber"] ?? '';
          city = data["city"] ?? '';
          country = data["country"] ?? '';
          mbti = data["mbti"] ?? '';
          birthdate = data["birthdate"] != null ? DateTime.parse(data["birthdate"]) : null;
        });
      }
    } catch (e) {
      print('Error retrieving user info: $e');
      Get.snackbar("Error", "Failed to load user data.");
    }
  }

  Future<void> _confirmDeleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _deleteAccount();
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "No user found.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      final result = await _reauthenticateUser(user);
      if (result) {
        await user.delete();
        FirebaseAuth.instance.signOut();

        Get.offAllNamed('/login');
        Get.snackbar("Account Deleted", "Your account has been successfully deleted.");
      } else {
        Get.snackbar("Error", "Authentication failed. Unable to delete account.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete account: $e");
    }
  }

  Future<bool> _reauthenticateUser(User user) async {
    try {
      final email = user.email;
      if (email == null) return false;

      final passwordController = TextEditingController();
      bool isAuthenticated = false;

      await Get.dialog(
        AlertDialog(
          title: const Text('Re-enter Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to delete your account.'),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                try {
                  final credential = EmailAuthProvider.credential(
                    email: email,
                    password: password,
                  );
                  await user.reauthenticateWithCredential(credential);
                  isAuthenticated = true;
                  Get.back();
                } catch (e) {
                  Get.snackbar("Authentication Failed", "Incorrect password.");
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      return isAuthenticated;
    } catch (e) {
      print("Error during re-authentication: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        leading: widget.userID != FirebaseAuth.instance.currentUser?.uid
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 30),
                onPressed: () => Get.back(),
              )
            : Container(),
        actions: widget.userID == FirebaseAuth.instance.currentUser?.uid
            ? [
                IconButton(
                  icon: const Icon(Icons.settings, size: 30),
                  onPressed: () => Get.to(() => const AccountSettingsScreen()),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 30),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/login');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, size: 30, color: Colors.red),
                  onPressed: _confirmDeleteAccount,
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 10),
            _buildSectionTitle("Personal Info"),
            _buildInfoTable(),
            const SizedBox(height: 30),
            _buildActionButton(
                "View Saved Profiles", Icons.bookmark, '/savedProfiles'),
            _buildActionButton("View Friends", Icons.group, '/friends'),
            _buildActionButton("Change Questionnaire Answers",
                Icons.question_answer, '/updateQuestionnaire'),
            _buildActionButton("Update Profile Information",
                Icons.edit, '/updateProfile'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Carousel(
        items: imageUrls.map((url) => Image.network(url, fit: BoxFit.cover)).toList(),
        autoScrollDuration: const Duration(seconds: 2),
        animationPageDuration: const Duration(milliseconds: 500),
        animationPageCurve: Curves.easeIn,
        indicatorBarColor: Colors.black.withOpacity(0.3),
        activateIndicatorColor: Colors.black,
        unActivatedIndicatorColor: Colors.grey,
        stopAtEnd: false,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInfoTable() {
    return Table(
      children: [
        _buildTableRow("Name", name),
        _buildTableRow("Age", age),
        _buildTableRow("Phone", phoneNumber),
        _buildTableRow("City", city),
        _buildTableRow("Country", country),
        _buildTableRow("MBTI", mbti),
        _buildTableRow(
            "Birthdate", birthdate?.toLocal().toString().split(' ')[0] ?? 'Not Set'),
      ],
    );
  }

  TableRow _buildTableRow(String key, String value) {
    return TableRow(
      children: [
        Text("$key:", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () => Get.toNamed(route),
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
    );
  }
}
