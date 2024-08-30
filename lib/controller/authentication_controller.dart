import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/authentication/login_screen.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:my_new_app/models/person.dart' as personModel;

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  late Rx<User?> firebaseCurrentUser;

  Rx<File?> pickedFile = Rx<File?>(null);  // Initialize pickedFile as Rx<File?>
  File? get profileImage => pickedFile.value;

  pickImageFileFromGallery() async {
    final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      pickedFile.value = File(imageFile.path);  // Update pickedFile with the new File
      Get.snackbar("Profile Image", "You have successfully picked your profile image");
    }
  }

  captureImageFromPhoneCamera() async {
    final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      pickedFile.value = File(imageFile.path);  // Update pickedFile with the new File
      Get.snackbar("Profile Image", "You have successfully captured your profile image using camera");
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference referenceStorage = FirebaseStorage.instance.ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = referenceStorage.putFile(imageFile);
    TaskSnapshot snapshot = await task;

    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();
    return downloadUrlOfImage;
  }

  Future<void> createUserAccount(
      String email,
      String password,
      File imageProfile,
      String name,
      String age,
      String gender,
      String phoneNumber,
      String city,
      String country,
      String profileHeading,
      String lookingForInaPartner,
      int publishedDateTime,
      String height,
      String weight,
      String bodyType,
      String drink,
      String smoke,
      String maritalStatus,
      String haveChildren,
      String numberOfChildren,
      String profession,
      String employmentStatus,
      String income,
      String livingSituation,
      String willingToRelocate,
      String relationshipYouAreLookingFor,
      String nationality,
      String education,
      String languageSpoken,
      String religion,
      String ethnicity,
      ) async {
    try {
      // 1. Authenticate user and create user with email and password
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password);

      // 2. Upload image to storage
      String urlOfDownload = await uploadImageToStorage(imageProfile);

      // 3. Save user info to Firestore
      personModel.Person personInstance = personModel.Person(
        uid: FirebaseAuth.instance.currentUser!.uid,
        imageProfile: urlOfDownload,
        email: email,
        password: password,
        name: name,
        age: int.parse(age),
        gender: gender,
        phoneNumber: phoneNumber,
        city: city,
        country: country,
        profileHeading: profileHeading,
        lookingForInaPartner: lookingForInaPartner,
        publishedDateTime: publishedDateTime,
        height: height,
        weight: weight,
        bodyType: bodyType,
        drink: drink,
        smoke: smoke,
        maritalStatus: maritalStatus,
        haveChildren: haveChildren,
        numberOfChildren: numberOfChildren,
        profession: profession,
        employmentStatus: employmentStatus,
        income: income,
        livingSituation: livingSituation,
        willingToRelocate: willingToRelocate,
        relationshipYouAreLookingFor: relationshipYouAreLookingFor,
        nationality: nationality,
        education: education,
        languageSpoken: languageSpoken,
        religion: religion,
        ethnicity: ethnicity,
      );

      await FirebaseFirestore.instance.collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(personInstance.toJson());

      Get.snackbar("Account Created", "Congratulations!");
      Get.to(const HomeScreen());
    } catch (errorMsg) {
      Get.snackbar("Account Creation Unsuccessful", "Error occurred: $errorMsg");
    }
  }

  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailUser,
        password: passwordUser,
      );
    } catch (errorMsg) {
      Get.snackbar("Login Unsuccessful", "Error Occurred: $errorMsg");
      Get.to(const HomeScreen());
    }
  }

  checkIfUserIsLoggedIn(User? currentUser) {
    if (currentUser == null) {
      Get.to(const LoginScreen());
    } else {
      Get.to(const HomeScreen());
    }
  }

  @override
  void onReady() {
    super.onReady();

    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    ever(firebaseCurrentUser, checkIfUserIsLoggedIn);
  }
}
