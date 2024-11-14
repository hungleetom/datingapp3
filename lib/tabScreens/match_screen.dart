import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_app/GamePage/game_page.dart';
import 'package:my_new_app/GamePage/game_page_second.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String selectedGender = 'Both';
  bool isSearching = false;
  bool isMatched = false;
  Timer? cancelTimer;
  int countdown = 5;
  String sessionId = "";
  bool isFriendMode = true;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  RangeValues ageRange = const RangeValues(20, 30); // Default age range
  double preferredDistance = 10.0; // Default distance in kilometers

  @override
  void dispose() {
    cancelTimer?.cancel();
    _stopSearching();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Automatically start searching if returning from a game page
    if (ModalRoute.of(context)?.settings.arguments == 'fromGamePage') {
      startSearching(isFriendMode);
    }
  }

  // Request Microphone Permission and Start Searching
  Future<void> requestMicrophonePermissionAndStartSearch(bool friendMode) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      // Permission already granted, start searching
      startSearching(friendMode);
    } else if (status.isDenied || status.isRestricted) {
      final newStatus = await Permission.microphone.request();
      if (newStatus.isGranted) {
        // Permission granted after request, start searching
        startSearching(friendMode);
      } else if (newStatus.isPermanentlyDenied) {
        // Permission permanently denied, prompt to open settings
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission is permanently denied. Please enable it from settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      } else {
        // Permission denied without permanent block
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for voice chat.')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Microphone permission is permanently denied. Please enable it from settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  // Start searching for a match
  Future<void> startSearching(bool friendMode) async {
    setState(() {
      isSearching = true;
      isFriendMode = friendMode;
    });

    await FirebaseFirestore.instance.collection('searching_users').doc(currentUserId).set({
      'gender': selectedGender,
      'isFriendMode': friendMode,
      'ageRange': {'min': ageRange.start.toInt(), 'max': ageRange.end.toInt()},
      'preferredDistance': preferredDistance,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _checkForMatch();
  }

  // Stop searching and remove user from the pool
  Future<void> _stopSearching() async {
    await FirebaseFirestore.instance.collection('searching_users').doc(currentUserId).delete();
  }

  // Check if there is a match available
  void _checkForMatch() {
    FirebaseFirestore.instance
        .collection('searching_users')
        .where('gender', isEqualTo: selectedGender)
        .where('isFriendMode', isEqualTo: isFriendMode)
        .get()
        .then((querySnapshot) async {
      var availableMatches = querySnapshot.docs.where((doc) => doc.id != currentUserId).toList();

      if (availableMatches.isNotEmpty) {
        var matchedUser = availableMatches.first;
        var matchedUserId = matchedUser.id;

        setState(() {
          isMatched = true;
          sessionId = const Uuid().v4();
        });

        await _stopSearching();
        await FirebaseFirestore.instance.collection('searching_users').doc(matchedUserId).delete();

        startCancelTimer(matchedUserId);
      } else {
        FirebaseFirestore.instance.collection('searching_users').snapshots().listen((snapshot) {
          _checkForMatch();
        });
      }
    });
  }

  // Timer for 5-second countdown
  void startCancelTimer(String opponentUserId) {
    cancelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });

      if (countdown == 0) {
        cancelTimer?.cancel();
        connectUsers(opponentUserId);
      }
    });
  }

  // Function to navigate to the appropriate game page
  void connectUsers(String opponentUserId) async {
    if (isFriendMode) {
      // Navigate to GamePage for friend mode
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GamePage(sessionId: sessionId, opponentUserId: opponentUserId),
          settings: const RouteSettings(arguments: 'fromGamePage'),
        ),
      );
    } else {
      // Navigate to GamePageSecond for partner mode
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GamePageSecond(sessionId: sessionId, opponentUserId: opponentUserId),
          settings: const RouteSettings(arguments: 'fromGamePage'),
        ),
      );
    }

    resetMatchScreen(); // Reset the state after navigating
  }

  // Function to reset MatchScreen state to its original state
  void resetMatchScreen() {
    setState(() {
      isSearching = false;
      isMatched = false;
      countdown = 5;
    });
  }

  // Function to cancel the match and continue searching
  void cancelMatch() {
    cancelTimer?.cancel();
    _stopSearching();
    resetMatchScreen();
  }

  // Function to find another match after cancelling
  void findAnotherMatch() {
    cancelMatch();
    startSearching(isFriendMode);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        resetMatchScreen();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find a Match'),
          backgroundColor: Colors.tealAccent[700],
          actions: [
            DropdownButton<String>(
              value: selectedGender,
              items: ['Male', 'Female', 'Both'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isSearching)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      isMatched
                          ? 'Matched! Connecting in $countdown seconds...'
                          : 'Searching... Please wait',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: cancelMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Cancel Match'),
                    ),
                  ],
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        'Find your perfect match!',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Gender Preference',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: selectedGender,
                        items: ['Male', 'Female', 'Both'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Age Range',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      RangeSlider(
                        values: ageRange,
                        min: 18,
                        max: 60,
                        divisions: 42,
                        labels: RangeLabels('${ageRange.start.toInt()}', '${ageRange.end.toInt()}'),
                        onChanged: (RangeValues newRange) {
                          setState(() {
                            ageRange = newRange;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Preferred Distance (km)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: preferredDistance,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: '${preferredDistance.toInt()} km',
                        onChanged: (double newDistance) {
                          setState(() {
                            preferredDistance = newDistance;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => requestMicrophonePermissionAndStartSearch(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.tealAccent[700],
                        ),
                        child: const Text('Find a Friend', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => requestMicrophonePermissionAndStartSearch(false),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('Find a Partner', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
