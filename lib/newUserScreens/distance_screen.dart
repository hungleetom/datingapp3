import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_app/newUserScreens/picture_screen.dart';

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({super.key});

  @override
  _DistanceScreenState createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  bool isLocationEnabled = false;
  double _distance = 50.0;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;

    if (status == PermissionStatus.granted) {
      setState(() {
        isLocationEnabled = true;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      Position position = await Geolocator.getCurrentPosition();
      await _saveDistanceAndLocation(_distance, position);
      // Navigate to the PictureScreen after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PictureScreen()),
      );
    } else {
      Get.snackbar('Permission Denied', 'Location tracking is required to use this feature.');
    }
  }

  Future<void> _saveDistanceAndLocation(double distance, Position position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'preferredDistance': distance,
        'location': GeoPoint(position.latitude, position.longitude),
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Do you live nearby?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share your current location to find people\n'
              'within your selected distance range.\n'
              'You won\'t be able to use the app without sharing your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.location_on,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 32),
            Slider(
              value: _distance,
              min: 10.0,
              max: 100.0,
              divisions: 9,
              label: "${_distance.round()} km",
              onChanged: (value) {
                setState(() {
                  _distance = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Location Info',
                  'Learn how your location data will be used.',
                );
              },
              child: const Text(
                'How will my location information be used?',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
