import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:my_new_app/tabScreens/match_screen.dart';

class GamePage extends StatefulWidget {
  final String sessionId;
  final String opponentUserId;

  const GamePage({super.key, required this.sessionId, required this.opponentUserId});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String opponentNickname = 'Loading...';
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> opponentQuestions = [];

  bool isGameStarted = false;
  bool isAnsweringPhase = false;
  bool isRendererInitialized = false;
  bool _isCalling = false;  // To prevent duplicate calls
  int chatTimerSeconds = 450; // 7 minutes and 30 seconds for chat
  int answerTimerSeconds = 30;
  Timer? gameTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? signalingSubscription;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    print("Initializing GamePage...");
    _initializeGame();
    _initializeWebRTC();
    fetchOpponentNickname();
  }

  Future<void> _initializeWebRTC() async {
    print("Initializing WebRTC...");
    await _remoteRenderer.initialize();
    isRendererInitialized = true;

    await _reinitializePeerConnection(); // Initialize the peer connection
  }

  Future<void> _reinitializePeerConnection() async {
    print("Reinitializing PeerConnection...");

    await _peerConnection?.close(); // Close any existing connection if open
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print("Generated ICE Candidate: ${candidate.candidate}");
      _sendCandidateToOpponent(candidate);
    };

    _peerConnection?.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'audio' && event.streams.isNotEmpty && mounted) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
        print("Remote audio track added to renderer.");
      }
    };

    _peerConnection?.onIceConnectionState = (state) {
      print("ICE connection state changed to: $state");
      if (state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
        print("PeerConnection closed, reinitializing...");
        _reinitializePeerConnection();
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {'googNoiseSuppression': true, 'googEchoCancellation': true},
      'video': false
    });

    if (_localStream == null || _localStream!.getTracks().isEmpty) {
      print("Error: Local stream or tracks are unavailable");
      return;
    }

    for (var track in _localStream!.getTracks()) {
      print("Adding local track: ${track.id}");
      _peerConnection?.addTrack(track, _localStream!);
    }

    print("PeerConnection reinitialized.");
  }

  Future<void> _startCallIfCaller() async {
    if (_isCalling || _peerConnection == null || 
        _peerConnection!.iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateClosed) {
      print("Cannot start call: either already calling or PeerConnection is closed.");
      return;
    }

    _isCalling = true;  // Prevent duplicate calls
    try {
      final sessionSnapshot = await FirebaseFirestore.instance.collection('game_sessions').doc(widget.sessionId).get();

      if (!sessionSnapshot.exists && _peerConnection != null) {
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        print("Created and sent offer as caller.");
        _sendOfferToOpponent(offer);
      }
    } catch (error) {
      print("Error in startCallIfCaller: $error");
    } finally {
      _isCalling = false; // Reset after attempt
    }
  }

  Future<void> _sendOfferToOpponent(RTCSessionDescription offer) async {
    print("Sending offer to opponent...");
    await FirebaseFirestore.instance.collection('game_sessions').doc(widget.sessionId).collection('offer').add({
      'sdp': offer.sdp,
      'type': offer.type,
      'senderId': currentUserId,
    });
  }

  Future<void> _sendAnswerToOpponent(RTCSessionDescription answer) async {
    print("Sending answer to opponent...");
    await FirebaseFirestore.instance.collection('game_sessions').doc(widget.sessionId).collection('answer').add({
      'sdp': answer.sdp,
      'type': answer.type,
      'senderId': currentUserId,
    });
  }

  Future<void> _sendCandidateToOpponent(RTCIceCandidate candidate) async {
    print("Sending ICE candidate to opponent...");
    await FirebaseFirestore.instance
        .collection('game_sessions')
        .doc(widget.sessionId)
        .collection('candidates')
        .add({
      'candidate': candidate.toMap(),
      'senderId': currentUserId,
    });
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
        _listenForGameChanges();

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
            opponentQuestions = answers.entries
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

  void _listenForGameChanges() {
    print("Listening for game session changes...");
    FirebaseFirestore.instance
        .collection('game_sessions')
        .doc(widget.sessionId)
        .snapshots()
        .listen((gameSnapshot) {
      if (!gameSnapshot.exists || gameSnapshot.data() == null) {
        if (isGameOverForBothUsers(gameSnapshot)) {
          print("Game session ended for both users.");
          _leaveGame();
        }
      }
    });
  }

  bool isGameOverForBothUsers(DocumentSnapshot<Map<String, dynamic>> gameSnapshot) {
    final data = gameSnapshot.data();
    return data?['status'] == 'finished';
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

    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MatchScreen()),
      );
    }
  }

  void _leaveGame() {
    print("Leaving game session...");
    gameTimer?.cancel();
    signalingSubscription?.cancel();
    _peerConnection?.close();
    _localStream?.dispose();
    if (isRendererInitialized) {
      _remoteRenderer.dispose();
    }

    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MatchScreen()),
      );
    }
  }

  @override
  void dispose() {
    print("Disposing GamePage...");
    gameTimer?.cancel();
    signalingSubscription?.cancel();
    _peerConnection?.close();
    _localStream?.dispose();
    if (isRendererInitialized) {
      _remoteRenderer.dispose();
    }
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
          const Text('Voice Chat:'),
          _buildVoiceActivityIndicators(),
          const SizedBox(height: 20),
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
              height: 40,
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
              height: 40,
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}
