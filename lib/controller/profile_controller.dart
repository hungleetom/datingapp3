import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_new_app/global.dart';
import 'package:my_new_app/models/person.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUserProfileList => usersProfileList.value;

  getResults()
  {
    onInit();
  }

  @override
  void onInit() {
    super.onInit();
    if(chosenGender == null || chosenCountry == null || chosenAge == null)
    {
      usersProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }),
    );
    }
    else
    {
      usersProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("gender", isNotEqualTo: chosenGender.toString().toLowerCase())
          .where("age", isGreaterThanOrEqualTo: int.parse(chosenAge.toString()))
          .where("country", isNotEqualTo: chosenCountry.toString())
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profilesList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profilesList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profilesList;
      }),
    );
    }
    
  }

  favoriteSentFavoriteReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("favoriteReceived")
        .doc(currentUserID)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("favoriteSent")
          .doc(toUserID)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .set({});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("favoriteSent")
          .doc(toUserID)
          .set({});

      sendNotificationToUser(toUserID, "Favorite", senderName);
    }
    update();
  }

  likeSentAndLikeReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("likeReceived")
        .doc(currentUserID)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(currentUserID)
          .delete();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("likeSent")
          .doc(toUserID)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(currentUserID)
          .set({});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("likeSent")
          .doc(toUserID)
          .set({});

      sendNotificationToUser(toUserID, "Like", senderName);
    }
    update();
  }

  viewSentAndViewReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection("viewReceived")
        .doc(currentUserID)
        .get();

    if (!document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("viewReceived")
          .doc(currentUserID)
          .set({});

      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection("viewSent")
          .doc(toUserID)
          .set({});

      sendNotificationToUser(toUserID, "View", senderName);
    }
    update();
  }

  sendNotificationToUser(String receiverID, String featureType, String senderName) async {
    String userDeviceToken = "";
    await FirebaseFirestore.instance
        .collection("users")
        .doc(receiverID)
        .get()
        .then((value) {
      if (value.data() != null && value.data()!["userDeviceToken"] != null) {
        userDeviceToken = value.data()!["userDeviceToken"].toString();
      }
    });

    if (userDeviceToken.isNotEmpty) {
      notificationFormat(
        userDeviceToken,
        receiverID,
        featureType,
        senderName,
      );
    }
  }

  notificationFormat(String userDeviceToken, String receiverID, String featureType, String senderName) async {
    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/dating-app-7738e/messages:send';

    Map<String, dynamic> notificationPayload = {
      "message": {
        "token": userDeviceToken,
        "notification": {
          "title": "New $featureType",
          "body": "You have received a new $featureType from $senderName. Click to see.",
        },
        "data": {
          "userID": receiverID,
          "senderID": FirebaseAuth.instance.currentUser!.uid,
          "featureType": featureType,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: jsonEncode(notificationPayload),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print("Failed to Send Notifications: ${response.statusCode}");
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "dating-app-7738e",
      "private_key_id": "8b5b74b33ab6df02b050ba3b9b9a59e36e53f208",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC13xBKxlcvld+E\nXbIpFudmieNREMRBsnjaZgqinVD0Se93WSHcPM0xCqiNnplsrwMto5OcvSZv/4RQ\nih5stMVDNtGAdLkUqU0DjRaA7+9acss9JmqnimZxjDYMrVT8eZ8uwkjEX9FLHpBM\nnDiPaeu08PMUPesF8HILsv9FkBoYznck2kURTUbN8X2aYYjFUnnUMnlV7nHEWAfi\nhZuM1uRm6tQyvP74Zuha4v06/tI5h3C+k5h6oxvthpGcVGlzw6ZJPi017CG7ojpY\nI4A57KxPjI8N3eQYrsCUBDJspRQPnpsuABZ0WFiXPteqD3S4KIdZRFwQh5qrz18q\nxX34QhpXAgMBAAECggEANR0pcWT+RlfjOJFye/yD5NbFK8IVRsh78fBWD8qYv1cu\nV7EQqfSZykY+FmnojayI5ZW9gMtew9ugBTNpEj8y0t/aDEVKXgXZh313Qn2P7d7T\niw7CnB5Xr7aOfGJMjRVpzyqPPMZs5Z7N7om7HOsGmse5fcJddlUTwWXrliGw9Wgs\njgqrMRpTBzhne1D0IBRFwCB7JlWJFV2kN7bfSbp3aZuFbQLXiWL+aLtl34zTmMxJ\n4E6p23nbZkrQEU8qnt4XlRGL4i6cRtW0Me53B6T9rwqchL/bdsLEMPq0hbpxIqR4\n2iIT/2bKU6Csk/ikWDZcTc+M9FA+x7cWeKf1o2dLwQKBgQDhTCT2qPC0mL1Rc06E\n9HKFzEUy9RMMiUMA2QbEh7ZRHwvfrtLPJjKu+IPK/tWV5ovwfg0o57Si1S43Nf8d\njjNfpHA9d/ww50JCDlx9D6rrac54x+kys1ZZI8PD4oDVN7oQtCOK1dXDYbcy5i/j\nd5pmj1zAr36OXuO5RfP30PcawQKBgQDOp+56BX8cjndJtaGJwe3YkNXNzrvuQ48m\ntJmf0W14FKntd0qcKNEHE3j0vDjQ7I+sFsJ55eBv53YrP+HaiEsjhjg9H2r4DZa4\n1UZaqMgsNV6Xit4zALEXP8swYnhrUM/0xQGBvCcqQoYtHpijwlP6W9AmRZfGy5n3\n2UvhBYpzFwKBgQDXWwa2NLSpnJrS4ap7koJp/OFknTjRMd+3TryWXbdbgZbDAQSH\neFbYQ7sO7lrRh+faQVNo91sGj0o3AklTQhs/YBrd1vRc9qGyLLIh5TkXADOZ5lW1\n3hE68eHuO3O03CjiUJ7s1gwYUC5i2/+IqkoPoRgjI12Qz4lUD1buWnPpwQKBgB9/\nfxzAG7i5ijsE4SNDGMKKiNv+p6xQRdBrdILkg9/qnl/gb9HPctS2RhhfW/WUKO3c\n5jV4MTY9PEipSv5pCbLXcVj3ofE++PshHsEQurnqRImqk+WINHXLtmegiqQoxBmV\nsX4ZtIp/az4TTMahBvXA6r/6mYCmZcheKW+ZzZlvAoGBAL9okCHbXWjah/v/4rAN\nfAms+p7wsvvrH9aXp4pP6gNLaG3oYOvqYf3QMgpCWW63dILDqXBQ4UabxnLPh/rv\ntWIYurwQO3CMHr+7rlNhwaRMbx1f8RWq8EmpNcpFljFkiB/FDOMs3iTwjR7731v3\n7sFuR0WWVyNKhR0To/F+GcEC\n-----END PRIVATE KEY-----\n",
      "client_email": "flutterhanjoon@dating-app-7738e.iam.gserviceaccount.com",
      "client_id": "108307891955816958889",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutterhanjoon%40dating-app-7738e.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }
}
