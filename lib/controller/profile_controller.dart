import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/global.dart';
import 'package:my_new_app/models/person.dart';

class ProfileController extends GetxController {
  // List to store user profiles
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUserProfileList => usersProfileList.value;

  final Rx<File?> pickedFile = Rx<File?>(null); // File for profile image

  // Get profile image
  File? get profileImage => pickedFile.value;

  @override
  void onInit() {
    super.onInit();
    fetchProfiles();
  }

  // Fetch all user profiles or filtered profiles based on user input
  void fetchProfiles() {
    if (chosenGender == null || chosenCountry == null || chosenAge == null) {
      usersProfileList.bindStream(_getAllProfiles());
    } else {
      usersProfileList.bindStream(_getFilteredProfiles());
    }
  }

  // Stream for fetching all profiles except the current user
  Stream<List<Person>> _getAllProfiles() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Person.fromDataSnapshot(doc)).toList();
    });
  }

  // Stream for fetching filtered profiles
  Stream<List<Person>> _getFilteredProfiles() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('gender', isNotEqualTo: chosenGender?.toLowerCase())
        .where('age', isGreaterThanOrEqualTo: int.parse(chosenAge ?? '0'))
        .where('country', isNotEqualTo: chosenCountry)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Person.fromDataSnapshot(doc)).toList();
    });
  }

  // Send a like to another user and manage like state
  Future<void> likeSentAndReceived(String toUserID, String senderName) async {
    var doc = await _getUserLikeReceivedDoc(toUserID);
    if (doc.exists) {
      await _removeLike(toUserID);
    } else {
      await _addLike(toUserID);
      _sendNotification(toUserID, 'Like', senderName);
    }
    update();
  }

  // Manage favorites between users
  Future<void> favoriteSentAndReceived(String toUserID, String senderName) async {
    var doc = await _getUserFavoriteReceivedDoc(toUserID);
    if (doc.exists) {
      await _removeFavorite(toUserID);
    } else {
      await _addFavorite(toUserID);
      _sendNotification(toUserID, 'Favorite', senderName);
    }
    update();
  }

  // Manage views between users
  Future<void> viewSentAndReceived(String toUserID, String senderName) async {
    var doc = await _getUserViewReceivedDoc(toUserID);
    if (!doc.exists) {
      await _addView(toUserID);
      _sendNotification(toUserID, 'View', senderName);
    }
    update();
  }

  // Send a notification to a user
  Future<void> _sendNotification(String receiverID, String type, String senderName) async {
    String deviceToken = await _getUserDeviceToken(receiverID);
    if (deviceToken.isNotEmpty) {
      await _sendFirebaseNotification(deviceToken, receiverID, type, senderName);
    }
  }

  // Get user's device token from Firestore
  Future<String> _getUserDeviceToken(String receiverID) async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverID).get();
    return userDoc.data()?['userDeviceToken'] ?? '';
  }

  // Firebase notification format and sending logic
  Future<void> _sendFirebaseNotification(
      String token, String receiverID, String type, String senderName) async {
    final String accessToken = await _getAccessToken();
    const url = 'https://fcm.googleapis.com/v1/projects/dating-app-7738e/messages:send';

    var payload = {
      "message": {
        "token": token,
        "notification": {
          "title": "New $type",
          "body": "You received a new $type from $senderName.",
        },
        "data": {
          "userID": receiverID,
          "senderID": FirebaseAuth.instance.currentUser?.uid,
          "type": type,
        },
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Notification failed: ${response.statusCode}');
    }
  }

  // Retrieve an access token for Firebase Cloud Messaging
  static Future<String> _getAccessToken() async {
    final serviceAccount = {
      "type": "service_account",
      "project_id": "dating-app-7738e",
      // ...Other service account fields...
    };

    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    var client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccount),
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  // Utility functions for managing likes, favorites, and views
  Future<DocumentSnapshot> _getUserLikeReceivedDoc(String toUserID) =>
      FirebaseFirestore.instance.collection('users').doc(toUserID).collection('likeReceived').doc(currentUserID).get();

  Future<DocumentSnapshot> _getUserFavoriteReceivedDoc(String toUserID) =>
      FirebaseFirestore.instance.collection('users').doc(toUserID).collection('favoriteReceived').doc(currentUserID).get();

  Future<DocumentSnapshot> _getUserViewReceivedDoc(String toUserID) =>
      FirebaseFirestore.instance.collection('users').doc(toUserID).collection('viewReceived').doc(currentUserID).get();

  Future<void> _removeLike(String toUserID) async {
    await FirebaseFirestore.instance.collection('users').doc(toUserID).collection('likeReceived').doc(currentUserID).delete();
    await FirebaseFirestore.instance.collection('users').doc(currentUserID).collection('likeSent').doc(toUserID).delete();
  }

  Future<void> _addLike(String toUserID) async {
    await FirebaseFirestore.instance.collection('users').doc(toUserID).collection('likeReceived').doc(currentUserID).set({});
    await FirebaseFirestore.instance.collection('users').doc(currentUserID).collection('likeSent').doc(toUserID).set({});
  }

  Future<void> _removeFavorite(String toUserID) async {
    await FirebaseFirestore.instance.collection('users').doc(toUserID).collection('favoriteReceived').doc(currentUserID).delete();
    await FirebaseFirestore.instance.collection('users').doc(currentUserID).collection('favoriteSent').doc(toUserID).delete();
  }

  Future<void> _addFavorite(String toUserID) async {
    await FirebaseFirestore.instance.collection('users').doc(toUserID).collection('favoriteReceived').doc(currentUserID).set({});
    await FirebaseFirestore.instance.collection('users').doc(currentUserID).collection('favoriteSent').doc(toUserID).set({});
  }

  Future<void> _addView(String toUserID) async {
    await FirebaseFirestore.instance.collection('users').doc(toUserID).collection('viewReceived').doc(currentUserID).set({});
    await FirebaseFirestore.instance.collection('users').doc(currentUserID).collection('viewSent').doc(toUserID).set({});
  }

  // Pick an image from the gallery
  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedFile.value = File(picked.path);
      Get.snackbar('Image Selected', 'You have successfully selected an image.');
    }
  }
}
