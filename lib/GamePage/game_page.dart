import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:my_new_app/homeScreen/home_screen.dart'; // Import HomeScreen

class GamePage extends StatefulWidget {
  final String sessionId;
  final String opponentUserId;

  const GamePage({super.key, required this.sessionId, required this.opponentUserId});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String appId = "app_id"; // Replace with your Agora App ID
  static const String tempToken = "temp_token"; // Replace with a temporary token for testing
  static const String channelName = "name"; // Replace with your channel name

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String opponentNickname = 'Loading...';

  bool isGameStarted = false;
  bool isAnsweringPhase = false;
  bool isAudioMuted = false;
  int chatTimerSeconds = 450; // 7 minutes and 30 seconds for chat
  int answerTimerSeconds = 30; // Time for answering phase
  Timer? gameTimer;

  late RtcEngine _engine; // Agora RTC Engine
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> opponentQuestions = [];

  @override
  void initState() {
    super.initState();
    print("Initializing GamePage...");
    initializeAgora();
    fetchOpponentNickname();
    _initializeGame();
  }

  Future<void> initializeAgora() async {
    print("Initializing Agora...");
    try {
      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(appId: appId),
      );
      print("Agora initialized successfully");

      await _engine.joinChannel(
        token: tempToken, // Replace with a valid token
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(),
      );
      print("Joined Agora channel successfully");
    } catch (e) {
      print("Error initializing Agora: $e");
      if (e is AgoraRtcException) {
        print("Agora Exception Code: ${e.code}");
      }
      _leaveGame(); // Navigate back gracefully
    }
  }

  Future<void> fetchOpponentNickname() async {
    print("Fetching opponent nickname...");
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.opponentUserId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null && mounted) {
        setState(() {
          opponentNickname = userSnapshot.data()!['nickname'] ?? 'Unknown';
        });
      } else if (mounted) {
        setState(() {
          opponentNickname = 'Unknown';
        });
      }
      print("Opponent nickname: $opponentNickname");
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
      DocumentSnapshot<Map<String, dynamic>> sessionSnapshot = await FirebaseFirestore.instance
          .collection('game_sessions')
          .doc(widget.sessionId)
          .get();

      if (sessionSnapshot.exists) {
        fetchQuestionsForGame();

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isGameStarted = true;
              _startChatTimer();
            });
          }
        });
      } else {
        _leaveGame();
      }
    } catch (e) {
      print("Error initializing game session: $e");
      _leaveGame();
    }
  }

  Future<void> fetchQuestionsForGame() async {
    print("Fetching questions for game...");
    try {
      DocumentSnapshot<Map<String, dynamic>> opponentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.opponentUserId)
          .get();

      if (opponentSnapshot.exists && opponentSnapshot.data() != null && mounted) {
        final data = opponentSnapshot.data()!;
        if (data.containsKey('questionnaireAnswers') && data['questionnaireAnswers'] is Map) {
          Map<String, dynamic> answers = data['questionnaireAnswers'];
          setState(() {
            questions = answers.entries
                .where((e) => e.value != null)
                .map<Map<String, dynamic>>((e) => {"question": e.value})
                .toList();
          });
        }
      }
    } catch (e) {
      print("Error fetching opponent questions: $e");
    }
  }

  void _startChatTimer() {
    print("Starting chat timer...");
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        chatTimerSeconds--;
      });

      if (chatTimerSeconds == 0) {
        print("Chat timer finished, starting answering phase...");
        timer.cancel();
        _startAnsweringPhase();
      }
    });
  }

  void _startAnsweringPhase() {
    gameTimer?.cancel();

    if (!mounted) return;
    setState(() {
      isAnsweringPhase = true;
      chatTimerSeconds = answerTimerSeconds;
    });

    print("Starting answering phase...");
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        chatTimerSeconds--;
      });

      if (chatTimerSeconds == 0) {
        print("Answering phase finished, evaluating game result...");
        timer.cancel();
        _evaluateGameResult();
      }
    });
  }

  void _evaluateGameResult() {
    int userScore = 0;
    int opponentScore = 0;

    if (userScore > opponentScore) {
      FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'score': FieldValue.increment(2),
      });
    } else if (userScore < opponentScore) {
      FirebaseFirestore.instance.collection('users').doc(widget.opponentUserId).update({
        'score': FieldValue.increment(2),
      });
    } else {
      FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'score': FieldValue.increment(1),
      });
      FirebaseFirestore.instance.collection('users').doc(widget.opponentUserId).update({
        'score': FieldValue.increment(1),
      });
    }

    _endGame();
  }

  void _endGame() async {
    await FirebaseFirestore.instance
        .collection('game_sessions')
        .doc(widget.sessionId)
        .delete();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(initialIndex: 0), // Navigate to HomeScreen, Match tab
      ),
      (route) => false,
    );
  }

  void _leaveGame() async {
    print("Leaving game session...");
    try {
      await _engine.leaveChannel();
      await _engine.release();
      print("Agora resources released");
    } catch (e) {
      print("Error during Agora cleanup: $e");
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(initialIndex: 0), // Navigate to HomeScreen, Match tab
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    print("Disposing GamePage...");
    gameTimer?.cancel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game with $opponentNickname'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveGame,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isGameStarted)
            if (!isAnsweringPhase)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Time remaining for chat: ${chatTimerSeconds ~/ 60}:${(chatTimerSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              setState(() {
                isAudioMuted = !isAudioMuted;
              });
              _engine.muteLocalAudioStream(isAudioMuted);
              print(isAudioMuted ? "Muted" : "Unmuted");
            },
            child: Text(isAudioMuted ? "Unmute" : "Mute"),
          ),
        ],
      ),
    );
  }
}
