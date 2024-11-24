import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_new_app/controller/authentication_controller.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:my_new_app/models/questionnaire_data.dart';
import 'package:my_new_app/newUserScreens/birthdate_screen.dart';
import 'package:my_new_app/newUserScreens/distance_screen.dart';
import 'package:my_new_app/newUserScreens/gender_screen.dart';
import 'package:my_new_app/newUserScreens/nickname_screen.dart';
import 'package:my_new_app/newUserScreens/picture_screen.dart';
import 'package:my_new_app/newUserScreens/questionnaire_screen.dart';
import 'package:my_new_app/tabScreens/chat_page.dart';
import 'package:my_new_app/tabScreens/settings_screen/friends_screen.dart';
import 'package:my_new_app/tabScreens/settings_screen/update_questionnaire_screen.dart';
import 'package:my_new_app/tabScreens/settings_screen/saved_profiles_screen.dart';
import 'package:my_new_app/tabScreens/settings_screen/update_profile_screen.dart';
import 'package:my_new_app/tabScreens/user_details_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_new_app/authentication/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Kakao SDK
  kakao.KakaoSdk.init(
    nativeAppKey: 'native_app_key',
    javaScriptAppKey: 'javascript_app_key',
  );

  // Initialize other services
  await initializeFirebaseAndServices();

  runApp(const MyApp());
}

Future<void> initializeFirebaseAndServices() async {
  try {
    Get.put(AuthenticationController()); // Initialize authentication controller
    await requestPermissions(); // Request microphone and notification permissions
    await initializeQuestionnaire(); // Initialize questionnaire data in Firestore
  } catch (error) {
    print('Failed to initialize services: $error');
  }
}

Future<void> requestPermissions() async {
  // Request notification permission
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  // Request microphone permission
  if (await Permission.microphone.isDenied) {
    await Permission.microphone.request();
  }
}

Future<void> initializeQuestionnaire() async {
  final questionsRef = FirebaseFirestore.instance.collection('questions');
  QuerySnapshot existingQuestions = await questionsRef.get();

  if (existingQuestions.size > 0) {
    print("Questions already exist in Firestore. Skipping initialization.");
    return;
  }

  final questionnaireService = QuestionnaireService();
  List<Map<String, dynamic>> questions = questionnaireService.getDefaultQuestions();

  WriteBatch batch = FirebaseFirestore.instance.batch();
  for (var question in questions) {
    final docRef = questionsRef.doc();
    batch.set(docRef, question);
  }
  await batch.commit();
  print('Database initialized with default questions.');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dating App',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthenticationFlow()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/userDetails',
          page: () => UserDetailsScreen(
            userID: Get.arguments['userID'] ?? '',
          ),
        ),
        GetPage(name: '/friends', page: () => const FriendsScreen()),
        GetPage(name: '/updateQuestionnaire', page: () => const UpdateQuestionnaireScreen()),
        GetPage(name: '/nickname', page: () => const NicknameScreen()),
        GetPage(name: '/birthdate', page: () => const BirthdateScreen()),
        GetPage(name: '/gender', page: () => const GenderScreen()),
        GetPage(name: '/distance', page: () => const DistanceScreen()),
        GetPage(name: '/pictures', page: () => const PictureScreen()),
        GetPage(name: '/savedProfiles', page: () => const SavedProfilesScreen()),
        GetPage(name: '/updateProfile', page: () => const UpdateProfileScreen()),
        GetPage(
          name: '/home',
          page: () => HomeScreen(
            initialIndex: Get.arguments?['index'] ?? 0,
          ),
        ),
        GetPage(name: '/chat', page: () => const ChatPage(receiverUserId: '', receiverUserNickname: '')),
      ],
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      ),
    );
  }
}

class AuthenticationFlow extends StatelessWidget {
  const AuthenticationFlow({super.key});

  Future<Widget> _checkUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Step 1: Check onboarding status from SharedPreferences
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      if (onboardingComplete) {
        print("Onboarding complete. Navigating directly to HomeScreen.");
        return const HomeScreen();
      }

      // Step 2: Check if user is logged in
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is logged in. Navigating to LoginScreen.");
        return const LoginScreen();
      }

      // Step 3: Retrieve user data from Firestore
      DocumentSnapshot userDoc;
      try {
        userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      } catch (e) {
        print("Error retrieving user data from Firestore: $e");
        return _errorScreen();
      }

      final userData = userDoc.data() as Map<String, dynamic>?;
      if (userData == null) {
        print("User data is null. Navigating to NicknameScreen.");
        await prefs.setString('last_page', '/nickname');
        return const NicknameScreen();
      }

      print("User data retrieved successfully: $userData");
      try {
        await _updateUserAge(user.uid, userData);
      } catch (e) {
        print("Error updating user's age: $e");
      }

      if ((userData['nickname'] ?? '').isEmpty) {
        print("User nickname is missing. Navigating to NicknameScreen.");
        await prefs.setString('last_page', '/nickname');
        return const NicknameScreen();
      }

      if ((userData['birthdate'] ?? '').isEmpty) {
        print("User birthdate is missing. Navigating to BirthdateScreen.");
        await prefs.setString('last_page', '/birthdate');
        return const BirthdateScreen();
      }

      if ((userData['gender'] ?? '').isEmpty) {
        print("User gender is missing. Navigating to GenderScreen.");
        await prefs.setString('last_page', '/gender');
        return const GenderScreen();
      }

      if (userData['preferredDistance'] is! double && userData['preferredDistance'] is! int) {
        print("User preferred distance is not a double. Setting default to 50.0");
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'preferredDistance': 50.0});
        return const DistanceScreen();
      }

      if ((userData['photos'] ?? []).isEmpty) {
        print("User photos are missing. Navigating to PictureScreen.");
        await prefs.setString('last_page', '/pictures');
        return const PictureScreen();
      }

      if (!_hasMinimumAnswers(userData['questionnaireAnswers'])) {
        print("User questionnaire answers are insufficient. Navigating to QuestionnaireScreen.");
        await prefs.setString('last_page', '/questionnaire');
        return const QuestionnaireScreen();
      }


      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('last_page', '/home');
      print("Onboarding complete. Navigating to HomeScreen.");
      return const HomeScreen();
    } catch (e) {
      print("Unexpected error in _checkUserProfile: $e");
      return _errorScreen();
    }
  }

  Widget _errorScreen() {
    return const Scaffold(
      body: Center(
        child: Text(
          'An error occurred. Please try again later.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  bool _hasMinimumAnswers(Map<String, dynamic>? answers) {
    if (answers == null) return false;

    // Handle the nested dynamic type safely
    int friendshipAnswers = (answers['friendship'] as Map<String, dynamic>? ?? {}).values
        .where((answer) => answer is String && answer.trim().isNotEmpty) // Check if value is a String and non-empty
        .length;
    int romanticAnswers = (answers['romantic'] as Map<String, dynamic>? ?? {}).values
        .where((answer) => answer is String && answer.trim().isNotEmpty)
        .length;

    return friendshipAnswers >= 3 && romanticAnswers >= 3;
  }

  Future<void> _updateUserAge(String userId, Map<String, dynamic> userData) async {
    final birthdateStr = userData['birthdate'];
    if (birthdateStr == null || birthdateStr.isEmpty) return;

    final birthdate = DateTime.parse(birthdateStr);
    final int calculatedAge = _calculateAge(birthdate);

    // Update Firestore only if age differs from the stored value
    if (userData['age'] != calculatedAge) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'age': calculatedAge,
      });
    }
  }

  int _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _checkUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _errorScreen();
        } else {
          return snapshot.data ?? const LoginScreen(); // Navigate to the appropriate screen.
        }
      },
    );
  }
}

// Helper function to save the last visited page
Future<void> saveLastPage(String routeName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_page', routeName);
}
