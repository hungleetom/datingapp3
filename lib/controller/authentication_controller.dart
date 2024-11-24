import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/authentication/login_screen.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:my_new_app/models/person.dart' as personModel;
import 'package:my_new_app/models/questionnaire_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  late Rx<User?> firebaseCurrentUser;
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  Rx<File?> pickedFile = Rx<File?>(null);

  @override
  void onReady() {
    super.onReady();
    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(firebaseCurrentUser, _handleAuthStateChanged);
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getString('last_page') ?? '/home';

    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      await _navigateToLastPageOrProfileCompletion(user.uid, lastPage);
    }
  }

  Future<void> _navigateToLastPageOrProfileCompletion(String userId, String lastPage) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData == null) {
        Get.offAllNamed('/nickname');
        return;
      }

      if ((userData['nickname'] ?? '').isEmpty) {
        Get.offAllNamed('/nickname');
      } else if ((userData['birthdate'] ?? '').isEmpty) {
        Get.offAllNamed('/birthdate');
      } else if ((userData['gender'] ?? '').isEmpty) {
        Get.offAllNamed('/gender');
      } else if ((userData['preferredDistance'] ?? 0.0) <= 0.0) {
        Get.offAllNamed('/distance');
      } else if ((userData['photos'] ?? []).isEmpty) {
        Get.offAllNamed('/pictures');
      } else if (!hasMinimumAnswers(userData['questionnaireAnswers'])) {
        Get.offAllNamed('/updateQuestionnaire');
      } else {
        if (Get.currentRoute != lastPage) {
          Get.offAllNamed(lastPage);
        }
      }
    } catch (e) {
      Get.snackbar("Navigation Error", "An error occurred: $e");
    }
  }

  bool hasMinimumAnswers(Map<String, dynamic>? answers) {
    if (answers == null) return false;

    int friendshipAnswers = (answers['friendship'] as Map<String, String>? ?? {}).values
        .where((answer) => answer.isNotEmpty)
        .length;
    int romanticAnswers = (answers['romantic'] as Map<String, String>? ?? {}).values
        .where((answer) => answer.isNotEmpty)
        .length;

    return friendshipAnswers >= 3 && romanticAnswers >= 3;
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final reference = FirebaseStorage.instance
          .ref("Profile Images/${FirebaseAuth.instance.currentUser!.uid}");
      final task = reference.putFile(imageFile);
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  Future<void> saveLastPage(String routeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_page', routeName);
  }

  Future<bool> nicknameExists(String nickname) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> pickImageFileFromGallery() async {
    try {
      final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        pickedFile.value = File(imageFile.path);
        Get.snackbar("Profile Image", "You have successfully picked your profile image");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick an image: $e");
    }
  }

  Future<void> captureImageFromPhoneCamera() async {
    try {
      final imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (imageFile != null) {
        pickedFile.value = File(imageFile.path);
        Get.snackbar("Profile Image", "You have successfully captured your profile image");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to capture an image: $e");
    }
  }

  Future<void> createUserAccount({
    required String nickname,
    required String gender,
    required DateTime birthdate,
    required List<File> photos,
    required double preferredDistance,
    required GeoPoint location,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not authenticated. Please log in first.");
        return;
      }

      if (await nicknameExists(nickname)) {
        Get.snackbar("Nickname Exists", "This nickname is already taken. Please choose another.");
        return;
      }

      List<String> photoUrls = await Future.wait(
        photos.map((photo) => uploadImageToStorage(photo)),
      );

      final personInstance = personModel.Person(
        uid: user.uid,
        email: user.email,
        nickname: nickname,
        gender: gender,
        birthdate: birthdate,
        photos: photoUrls,
        preferredDistance: preferredDistance,
        location: location,
      );

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(personInstance.toMap());

      final questions = _questionnaireService.getDefaultQuestions();
      final emptyAnswers = {
        'friendship': {for (var q in questions.where((q) => q['category'] == 'friendship')) q['question']: ''},
        'romantic': {for (var q in questions.where((q) => q['category'] == 'romantic')) q['question']: ''}
      };

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'questionnaireAnswers': emptyAnswers,
      });

      Get.snackbar("Account Created", "Your profile has been successfully created.");
      Get.offAll(() => const HomeScreen());
    } catch (error) {
      Get.snackbar("Account Creation Unsuccessful", "Error occurred: $error");
    }
  }

  Future<void> setUpAgoraLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String logPath = "${directory.path}/agora-iris.log";

      // Configure your Agora instance with the log file path
      // Example:
      // yourAgoraInstance.setLogFile(logPath);

      print("Agora logs will be saved to: $logPath");
    } catch (e) {
      Get.snackbar("Error", "Failed to set up Agora logs: $e");
    }
  }

  Future<void> updateUserMbti(String mbti) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'mbti': mbti});
        print('MBTI updated successfully.');
      } else {
        Get.snackbar('Error', 'User not authenticated.');
      }
    } catch (e) {
      print('Failed to update MBTI: $e');
      Get.snackbar('Error', 'Failed to update MBTI.');
    }
  }
}
