import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamePageSecond extends StatefulWidget {
  final String sessionId;
  final String opponentUserId;

  const GamePageSecond({super.key, required this.sessionId, required this.opponentUserId});

  @override
  _GamePageSecondState createState() => _GamePageSecondState();
}

class _GamePageSecondState extends State<GamePageSecond> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String opponentNickname = 'Loading...';
  int currentScore = 0;
  int opponentScore = 0;
  bool isMyTurn = false;
  String currentQuestion = '';
  List<Map<String, dynamic>> questions = [];

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  // Voice activity indicator values
  bool isSpeaking = false;
  bool isOpponentSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    initRenderers();
    _startVoiceChat();
    fetchOpponentNickname();
  }

  Future<void> _initializeGame() async {
    DocumentSnapshot sessionSnapshot = await FirebaseFirestore.instance
        .collection('relationship_game_sessions')
        .doc(widget.sessionId)
        .get();

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

  Future<void> fetchOpponentNickname() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.opponentUserId)
        .get();

    setState(() {
      opponentNickname = userSnapshot['nickname'] ?? 'Unknown';
    });
  }

  Future<void> fetchQuestionsForGame() async {
    QuerySnapshot questionSnapshot = await FirebaseFirestore.instance
        .collection('relationship_questions')
        .get();

    setState(() {
      questions = questionSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      currentQuestion = questions.isNotEmpty ? questions[0]['question'] : 'No questions available';
    });
  }

  void _listenForGameChanges() {
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

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startVoiceChat() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      FirebaseFirestore.instance
          .collection('relationship_game_sessions')
          .doc(widget.sessionId)
          .collection('ice_candidates')
          .add({
        'candidate': candidate.toMap(),
        'sender': currentUserId,
      });
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _localRenderer.srcObject = _localStream;

    _peerConnection?.onAddStream = (MediaStream stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };

    if (isMyTurn) {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await FirebaseFirestore.instance
          .collection('relationship_game_sessions')
          .doc(widget.sessionId)
          .collection('webrtc')
          .doc('offer')
          .set({'offer': offer.toMap()});
    } else {
      DocumentSnapshot offerSnapshot = await FirebaseFirestore.instance
          .collection('relationship_game_sessions')
          .doc(widget.sessionId)
          .collection('webrtc')
          .doc('offer')
          .get();

      if (offerSnapshot.exists) {
        RTCSessionDescription offer = RTCSessionDescription(
            offerSnapshot['offer']['sdp'], offerSnapshot['offer']['type']);

        await _peerConnection!.setRemoteDescription(offer);

        RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        await FirebaseFirestore.instance
            .collection('relationship_game_sessions')
            .doc(widget.sessionId)
            .collection('webrtc')
            .doc('answer')
            .set({'answer': answer.toMap()});
      }
    }

    DocumentSnapshot answerSnapshot = await FirebaseFirestore.instance
        .collection('relationship_game_sessions')
        .doc(widget.sessionId)
        .collection('webrtc')
        .doc('answer')
        .get();

    if (answerSnapshot.exists) {
      RTCSessionDescription answer = RTCSessionDescription(
          answerSnapshot['answer']['sdp'], answerSnapshot['answer']['type']);

      await _peerConnection!.setRemoteDescription(answer);
    }

    FirebaseFirestore.instance
        .collection('relationship_game_sessions')
        .doc(widget.sessionId)
        .collection('ice_candidates')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.exists && doc['sender'] != currentUserId) {
          _peerConnection?.addCandidate(
            RTCIceCandidate(doc['candidate']['candidate'],
                doc['candidate']['sdpMid'], doc['candidate']['sdpMLineIndex']),
          );
        }
      }
    });

    _simulateVoiceActivity(); // Simulate voice activity detection
  }

  void _simulateVoiceActivity() {
    // Simulated voice activity detection, toggling every 1 second for example purposes.
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

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
    _peerConnection?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedQuestion = currentQuestion.replaceAll('[name]', opponentNickname);

    return Scaffold(
      appBar: AppBar(
        title: Text('Relationship Game with $opponentNickname'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Current Question: $formattedQuestion', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
