import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/global.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:my_new_app/widgets/custom_text_field_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlsList = [];
  double val = 0;

  // Controllers for user input
  TextEditingController nicknameTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();
  TextEditingController mbtiTextEditingController = TextEditingController();
  TextEditingController preferredDistanceTextEditingController = TextEditingController();

  DateTime? birthdate;
  GeoPoint? location; // Store location (if needed)

  chooseImage() async {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
  }

  uploadImages() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      var refImages = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");

      await refImages.putFile(img).whenComplete(() async {
        await refImages.getDownloadURL().then((urlImage) {
          urlsList.add(urlImage);
          i++;
        });
      });
    }
  }

  retrieveUserData() async {
    await FirebaseFirestore.instance.collection("users").doc(currentUserID).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          nicknameTextEditingController.text = snapshot.data()!['nickname'] ?? '';
          genderTextEditingController.text = snapshot.data()!['gender'] ?? '';
          ageTextEditingController.text = snapshot.data()!['age']?.toString() ?? '';
          emailTextEditingController.text = snapshot.data()!['email'] ?? '';
          phoneNumberTextEditingController.text = snapshot.data()!['phoneNumber'] ?? '';
          cityTextEditingController.text = snapshot.data()!['city'] ?? '';
          countryTextEditingController.text = snapshot.data()!['country'] ?? '';
          mbtiTextEditingController.text = snapshot.data()!['mbti'] ?? '';
          preferredDistanceTextEditingController.text = snapshot.data()!['preferredDistance']?.toString() ?? '';
          birthdate = snapshot.data()!['birthdate'] != null ? DateTime.parse(snapshot.data()!['birthdate']) : null;
          location = snapshot.data()!['location'] ?? const GeoPoint(0, 0);
        });
      }
    });
  }

  updateUserDataToFirestoreDatabase() async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: SizedBox(
            height: 200,
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Uploading images..."),
                ],
              ),
            ),
          ),
        );
      },
    );

    await uploadImages();

    await FirebaseFirestore.instance.collection("users").doc(currentUserID).update({
      'nickname': nicknameTextEditingController.text.trim(),
      'gender': genderTextEditingController.text.trim().toLowerCase(),
      'age': int.parse(ageTextEditingController.text.trim()),
      'email': emailTextEditingController.text.trim(),
      'phoneNumber': phoneNumberTextEditingController.text.trim(),
      'city': cityTextEditingController.text.trim(),
      'country': countryTextEditingController.text.trim(),
      'mbti': mbtiTextEditingController.text.trim(),
      'birthdate': birthdate?.toIso8601String(),
      'preferredDistance': double.parse(preferredDistanceTextEditingController.text.trim()),
      'photos': urlsList, // Storing the list of image URLs
      'location': location, // Store location
    });

    Get.snackbar("Updated", "Your account has been updated successfully");
    Get.to(const HomeScreen());

    setState(() {
      uploading = false;
      _image.clear();
      urlsList.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          next ? "Profile Information" : "Choose Images",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          next
              ? Container()
              : IconButton(
                  onPressed: () {
                    if (_image.length == 5) {
                      setState(() {
                        next = true;
                      });
                    } else {
                      Get.snackbar("5 Images", "Please choose 5 images");
                    }
                  },
                  icon: const Icon(Icons.navigate_next_outlined))
        ],
      ),
      body: next
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildProfileField("Nickname", Icons.person_outline, nicknameTextEditingController, "Nickname"),
                    buildProfileField("Email", Icons.email_outlined, emailTextEditingController, "Email"),
                    buildProfileField("Age", Icons.numbers, ageTextEditingController, "Age"),
                    buildProfileField("Gender", Icons.person_pin, genderTextEditingController, "Gender"),
                    buildProfileField("Phone Number", Icons.phone, phoneNumberTextEditingController, "Phone Number"),
                    buildProfileField("City", Icons.location_city, cityTextEditingController, "City"),
                    buildProfileField("Country", Icons.location_city, countryTextEditingController, "Country"),
                    buildProfileField("MBTI", Icons.tag_faces, mbtiTextEditingController, "MBTI"),
                    buildProfileField("Preferred Distance", Icons.map, preferredDistanceTextEditingController, "Preferred Distance (km)"),
                    ElevatedButton(
                      onPressed: () async {
                        await updateUserDataToFirestoreDatabase();
                      },
                      child: const Text("Update Account"),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              itemCount: _image.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return index == 0
                    ? Container(
                        color: Colors.white30,
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              if (_image.length < 5) {
                                !uploading ? chooseImage() : null;
                              } else {
                                setState(() {
                                  uploading == true;
                                });
                              }
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_image[index - 1]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
              },
            ),
    );
  }

  Widget buildProfileField(String label, IconData icon, TextEditingController controller, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width - 36,
          height: 50,
          child: CustomTextFieldWidget(
            editingController: controller,
            labelText: hintText,
            iconData: icon,
            isObscure: false,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
