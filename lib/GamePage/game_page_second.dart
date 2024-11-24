import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:my_new_app/homeScreen/home_screen.dart'; // Import HomeScreen

class GamePageSecond extends StatefulWidget {
  final String sessionId;
  final String opponentUserId;

  const GamePageSecond({super.key, required this.sessionId, required this.opponentUserId});

  @override
  _GamePageSecondState createState() => _GamePageSecondState();
}

class _GamePageSecondState extends State<GamePageSecond> {
  static const String appId = "48a56dde7fc34804a142356a57f03c34"; // Replace with your Agora App ID
  static const String tempToken = "007eJxTYFgRpPFnrd2EmX2fSn89asst9fxsN/2U2c66H8fXv+xsTL2jwGBikWhqlpKSap6WbGxiYWCSaGhiZGxqlmhqnmZgDBSaMNMmvSGQkWG1vhwzIwMEgvg8DCWpxSXxyRmJeXmpOQwMAH1zJWc="; // Replace with a temporary token for testing
  static const String channelName = "relationship_game"; // Replace with your channel name

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String opponentNickname = 'Loading...';
  int currentScore = 0;
  int opponentScore = 0;
  bool isMyTurn = false;
  String currentQuestion = '';
  List<Map<String, dynamic>> questions = [];

  bool isSpeaking = false;
  bool isOpponentSpeaking = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    print("Initializing GamePageSecond...");
    initializeAgora();
    fetchOpponentNickname();
    _initializeGame();
  }

  Future<void> initializeAgora() async {
    print("Initializing Agora...");
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));

    // Set event handlers
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print("Successfully joined channel: ${connection.channelId}");
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print("Remote user joined: $remoteUid");
      },
      onUserOffline: (connection, remoteUid, reason) {
        print("Remote user left: $remoteUid, reason: $reason");
      },
    ));

    // Enable audio
    await _engine.enableAudio();

    // Join the channel
    await _engine.joinChannel(
      token: tempToken,
      channelId: channelName,
      uid: 0, // Local user UID
      options: const ChannelMediaOptions(),
    );

    // Simulate voice activity for UI purposes
    _simulateVoiceActivity();
  }

  Future<void> fetchOpponentNickname() async {
    print("Fetching opponent nickname...");
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.opponentUserId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null && mounted) {
        setState(() {
          opponentNickname = userSnapshot['nickname'] ?? 'Unknown';
        });
      } else if (mounted) {
        setState(() {
          opponentNickname = 'Unknown';
        });
      }
    } catch (e) {
      print("Error fetching opponent nickname: $e");
      if (mounted) {
        setState(() {
          opponentNickname = 'Error loading name';
        });
      }
    }
  }

  Future<void> _initializeGame() async {
    print("Initializing game session...");
    try {
      DocumentSnapshot sessionSnapshot = await FirebaseFirestore.instance
          .collection('relationship_game_sessions')
          .doc(widget.sessionId)
          .get();

      if (sessionSnapshot.exists) {
        setState(() {
          if (sessionSnapshot['player1'] == currentUserId) {
            isMyTurn = true;
          } else {
            isMyTurn = false;
          }
        });
        fetchQuestionsForGame();
        _listenForGameChanges();
      }
    } catch (e) {
      print("Error initializing game session: $e");
    }
  }

  Future<void> fetchQuestionsForGame() async {
    print("Fetching questions for game...");
    try {
      QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('relationship_questions')
          .get();

      setState(() {
        questions = questionSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        currentQuestion = questions.isNotEmpty ? questions[0]['question'] : 'No questions available';
      });
    } catch (e) {
      print("Error fetching questions: $e");
    }
  }

  void _listenForGameChanges() {
    print("Listening for game session changes...");
    FirebaseFirestore.instance
        .collection('relationship_game_sessions')
        .doc(widget.sessionId)
        .snapshots()
        .listen((gameSnapshot) {
      if (gameSnapshot.exists) {
        setState(() {
          currentScore = gameSnapshot['player1Score'];
          opponentScore = gameSnapshot['player2Score'];
          isMyTurn = gameSnapshot['currentPlayerId'] == currentUserId;
        });
      }
    });
  }

  void _simulateVoiceActivity() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isSpeaking = !isSpeaking;
          isOpponentSpeaking = !isOpponentSpeaking;
        });
        _simulateVoiceActivity();
      }
    });
  }

  void _submitAnswer(String answer) async {
    if (isMyTurn) {
      final sessionRef = FirebaseFirestore.instance
          .collection('relationship_game_sessions')
          .doc(widget.sessionId);

      DocumentSnapshot sessionSnapshot = await sessionRef.get();
      Map<String, dynamic> sessionData =
          sessionSnapshot.data() as Map<String, dynamic>;

      if (sessionData['currentPlayerId'] == currentUserId) {
        sessionRef.update({
          'player1Score': FieldValue.increment(1),
          'currentPlayerId': widget.opponentUserId,
          'currentQuestion': 'Next question here',
        });
      } else {
        sessionRef.update({
          'player2Score': FieldValue.increment(1),
          'currentPlayerId': currentUserId,
          'currentQuestion': 'Next question here',
        });
      }

      if (currentScore + 1 >= 3) {
        _endGame();
      }

      setState(() {
        isMyTurn = false;
      });
    }
  }

  void _endGame() async {
    await FirebaseFirestore.instance
        .collection('relationship_game_sessions')
        .doc(widget.sessionId)
        .update({'gameStatus': 'completed'});

    _navigateToHomeScreen();
  }

  void _leaveGame() async {
    print("Leaving game session...");
    await _engine.leaveChannel();
    _navigateToHomeScreen();
  }

  void _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(initialIndex: 0), // Adjust index as needed
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedQuestion = currentQuestion.replaceAll('[name]', opponentNickname);

    return Scaffold(
      appBar: AppBar(
        title: Text('Relationship Game with $opponentNickname'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current Question: $formattedQuestion',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (isMyTurn)
            Column(
              children: [
                ElevatedButton(
                    onPressed: () => _submitAnswer('A'),
                    child: const Text('A')),
                ElevatedButton(
                    onPressed: () => _submitAnswer('B'),
                    child: const Text('B')),
                ElevatedButton(
                    onPressed: () => _submitAnswer('C'),
                    child: const Text('C')),
              ],
            ),
          const SizedBox(height: 20),
          Text('Your score: $currentScore'),
          Text('Opponent score: $opponentScore'),
          const SizedBox(height: 30),
          const Text('Voice Chat:'),
          const SizedBox(height: 10),
          _buildVoiceActivityIndicators(),
        ],
      ),
    );
  }

  Widget _buildVoiceActivityIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('You', style: TextStyle(fontWeight: FontWeight.bold)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 10,
              height: isSpeaking ? 60 : 20,
              color: Colors.blue,
            ),
          ],
        ),
        Column(
          children: [
            const Text('Opponent', style: TextStyle(fontWeight: FontWeight.bold)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 10,
              height: isOpponentSpeaking ? 60 : 20,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
