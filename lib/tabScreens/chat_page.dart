import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_app/GamePage/game_page.dart';
import 'package:my_new_app/GamePage/game_page_second.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

class ChatPage extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserNickname; // User's nickname for display
  const ChatPage({super.key, required this.receiverUserId, required this.receiverUserNickname});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  String currentUserId = '';
  bool isFriend = false;
  bool hasMatched = false;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    checkFriendshipAndMatch();
  }

  Future<void> checkFriendshipAndMatch() async {
    // Check if the user is friends or has matched with the other user
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(currentUserId).get();
    DocumentSnapshot receiverSnapshot = await _firestore.collection('users').doc(widget.receiverUserId).get();

    if (userSnapshot.exists && receiverSnapshot.exists) {
      setState(() {
        hasMatched = (userSnapshot['matchedUsers'] ?? []).contains(widget.receiverUserId);
        isFriend = (userSnapshot['friends'] ?? []).contains(widget.receiverUserId);
      });
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    String chatId = _getChatId(currentUserId, widget.receiverUserId);
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  String _getChatId(String user1, String user2) {
    return user1.compareTo(user2) < 0 ? '${user1}_$user2' : '${user2}_$user1';
  }

  void sendFriendRequest() async {
    await _firestore.collection('users').doc(widget.receiverUserId).collection('friend_requests').add({
      'senderId': currentUserId,
      'isViewed': false,
      'pointsUsed': false,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request sent to ${widget.receiverUserNickname}')),
    );
  }

  void initiateGame(bool isFriendMode) {
    String sessionId = const Uuid().v4(); // Use UUID to generate a session ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isFriendMode
            ? GamePage(sessionId: sessionId, opponentUserId: widget.receiverUserId)
            : GamePageSecond(sessionId: sessionId, opponentUserId: widget.receiverUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserNickname),
        actions: [
          if (isFriend || hasMatched)
            IconButton(
              icon: const Icon(Icons.gamepad),
              onPressed: () => initiateGame(true), // Assuming friend game mode
            ),
          IconButton(
            icon: const Icon(Icons.block),
            onPressed: () {
              // Implement block functionality here
            },
          ),
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () {
              // Implement report functionality here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_getChatId(currentUserId, widget.receiverUserId))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;
                    bool isSentByMe = messageData['senderId'] == currentUserId;
                    return ListTile(
                      title: Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            messageData['message'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          if (isFriend || hasMatched)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => sendMessage(_messageController.text),
                  ),
                ],
              ),
            )
          else
            Center(
              child: ElevatedButton(
                onPressed: sendFriendRequest,
                child: const Text('Send Friend Request'),
              ),
            ),
        ],
      ),
    );
  }
}
