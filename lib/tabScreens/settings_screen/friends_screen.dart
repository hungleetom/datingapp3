import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId == null) return [];

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if the user data exists and contains a list of friends
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      List<String> friendIds = List<String>.from(userData['friends'] ?? []);

      // Fetch friend details from their IDs
      List<Map<String, dynamic>> friendsData = [];
      for (String friendId in friendIds) {
        DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
        if (friendSnapshot.exists) {
          friendsData.add(friendSnapshot.data() as Map<String, dynamic>);
        }
      }
      return friendsData;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Friends'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching friends.'));
          } else {
            final friends = snapshot.data ?? [];

            if (friends.isEmpty) {
              return const Center(child: Text('No Friends Yet'));
            }

            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['imageProfile'] ?? ''),
                  ),
                  title: Text(friend['nickname'] ?? 'Unknown'),
                  subtitle: Text(friend['email'] ?? ''),
                );
              },
            );
          }
        },
      ),
    );
  }
}
