import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


class Person {
  String? uid;
  String? nickname;
  String? gender;
  int? age;
  String? email;
  String? country;
  String? city;
  String? phoneNumber;
  DateTime? birthdate;
  List<String>? photos;
  double? preferredDistance;
  GeoPoint? location;
  String? mbti;
  int points;
  String? userInterest;
  String? bio;
  List<String>? savedProfiles;
  List<String>? friendRequests;
  Map<String, dynamic>? questionnaireAnswers; // Field for questionnaire answers

  Person({
    this.uid,
    this.nickname,
    this.gender,
    this.age,
    this.email,
    this.country,
    this.city,
    this.phoneNumber,
    required this.birthdate,
    required this.photos,
    required this.preferredDistance,
    required this.location,
    this.mbti,
    this.points = 0,
    this.userInterest,
    this.bio,
    this.savedProfiles,
    this.friendRequests,
    this.questionnaireAnswers, // Initialize questionnaireAnswers
  });

  // Convert the object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'email': email,
      'country': country,
      'city': city,
      'phoneNumber': phoneNumber,
      'birthdate': birthdate?.toIso8601String(),
      'photos': photos,
      'preferredDistance': preferredDistance,
      'location': location,
      'mbti': mbti,
      'points': points,
      'userInterest': userInterest,
      'bio': bio,
      'savedProfiles': savedProfiles ?? [],
      'friendRequests': friendRequests ?? [],
      'questionnaireAnswers': questionnaireAnswers ?? {}, // Initialize as empty if null
    };
  }

  // Create a Person object from Firestore snapshot
  factory Person.fromDataSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;

    return Person(
      uid: snapshot.id,
      nickname: data['nickname'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      email: data['email'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      birthdate: data['birthdate'] != null ? DateTime.parse(data['birthdate']) : null,
      photos: List<String>.from(data['photos'] ?? []),
      preferredDistance: (data['preferredDistance'] ?? 0).toDouble(),
      location: data['location'] ?? const GeoPoint(0, 0),
      mbti: data['mbti'] ?? '',
      points: data['points'] ?? 0,
      userInterest: data['userInterest'] ?? '',
      bio: data['bio'] ?? '',
      savedProfiles: List<String>.from(data['savedProfiles'] ?? []),
      friendRequests: List<String>.from(data['friendRequests'] ?? []),
      questionnaireAnswers: data['questionnaireAnswers'] ?? {}, // Load existing answers or empty map
    );
  }

  // Update the user's location in Firestore
  static Future<void> updateUserLocation(String userId) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }

      // Get the user's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      GeoPoint newLocation = GeoPoint(position.latitude, position.longitude);

      // Get the city and country from the coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude
      );
      String newCity = placemarks[0].locality ?? 'Unknown City';
      String newCountry = placemarks[0].isoCountryCode ?? 'Unknown Country';

      // Get the flag emoji for the country
      String flagEmoji = getFlagEmoji(newCountry);

      // Update Firestore with the new location and city/country
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'location': newLocation,
        'city': newCity,
        'country': "$newCountry $flagEmoji",
      });
    } catch (e) {
      print("Error updating user location: $e");
    }
  }

  // Monitor significant location changes and update Firestore
  static void monitorLocationChanges(String userId) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 10000, // 10 km threshold
        accuracy: LocationAccuracy.best,
      ),
    ).listen((Position position) async {
      try {
        // Update user location when it changes significantly
        await updateUserLocation(userId);
      } catch (e) {
        print("Error while monitoring location: $e");
      }
    });
  }

  // Get flag emoji based on country code
  static String getFlagEmoji(String countryCode) {
    if (countryCode.isEmpty) return '';

    int firstChar = countryCode.codeUnitAt(0) + 127397;
    int secondChar = countryCode.codeUnitAt(1) + 127397;
    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }
}
