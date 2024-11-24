import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:my_new_app/controller/authentication_controller.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart'; // Line login package
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_new_app/newUserScreens/nickname_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool showProgressBar = false;
  final controllerAuth = Get.find<AuthenticationController>();

  @override
  void initState() {
    super.initState();
    LineSDK.instance.setup('2006336152').then((_) {
      print('LineSDK is ready');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 120),
              Image.asset("images/heart.png", width: 500),
              const Text(
                "Welcome",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              const Text(
                "Please Login with One of the Options Below!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Google login button
              GestureDetector(
                onTap: () async {
                  await signInWithGoogle();
                },
                child: Image.asset('images/googleloginbuttonlight.png', height: 350), // Google logo
              ),
              const SizedBox(height: 20),

              // Kakao login button
              GestureDetector(
                onTap: () async {
                  await signInWithKakao();
                },
                child: Image.asset('images/kakaologin.png', height: 50), // Kakao logo
              ),
              const SizedBox(height: 20),

              // Line login button
              GestureDetector(
                onTap: () async {
                  await signInWithLine();
                },
                child: Image.asset('images/line_login_button.png', height: 50), // Line logo
              ),
              const SizedBox(height: 20),

              // Progress bar
              showProgressBar
                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkUserInFirestore() async {
  try {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Check if the user exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        // If user is new, start onboarding process at nickname screen
        Get.offAll(() => const NicknameScreen());
      } else {
        // If user already exists, navigate to the home screen
        Get.offAll(() => const HomeScreen());
      }
    } else {
      Get.snackbar("Login Failed", "Unable to authenticate user.");
    }
  } catch (error) {
    Get.snackbar("Login Failed", "Failed to retrieve user data: $error");
  }
}


  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Get.snackbar("Login Cancelled", "Google login cancelled by user.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _checkUserInFirestore(); // Check if user exists in Firestore
    } catch (error) {
      Get.snackbar("Login Failed", "Google login failed: $error");
    }
  }

  // Kakao Sign In
  Future<void> signInWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final OAuthCredential credential = OAuthProvider("oidc.datingapp").credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _checkUserInFirestore();
    } catch (error) {
      Get.snackbar("Login Failed", "Kakao login failed: $error");
    }
  }

  // Line Sign In
  Future<void> signInWithLine() async {
    try {
      final result = await LineSDK.instance.login(scopes: ['profile', 'openid', 'email']);
      final accessToken = result.accessToken.value;

      _checkUserInFirestore();
    } catch (error) {
      Get.snackbar("Login Failed", "Line sign-in failed: $error");
    }
  }
}
