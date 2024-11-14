import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_app/models/person.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Person> searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void searchProfiles(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isGreaterThanOrEqualTo: query)
          .where('nickname', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      setState(() {
        searchResults = querySnapshot.docs
            .map((doc) => Person.fromDataSnapshot(doc))
            .toList();
      });
    } catch (e) {
      print('Error searching profiles: $e');
      setState(() {
        searchResults = [];
      });
    }
  }

  void saveProfile(String profileId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'savedProfiles': FieldValue.arrayUnion([profileId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving profile. Please try again.')),
      );
    }
  }

  void sendFriendRequest(String profileId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(profileId)
          .update({
        'friendRequests': FieldValue.arrayUnion([currentUserId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending friend request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Profiles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by nickname...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = _searchController.text.trim();
                    });
                    searchProfiles(searchQuery);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: searchResults.isEmpty
          ? const Center(child: Text('No profiles found.'))
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                Person person = searchResults[index];
                String profileImageUrl = (person.photos != null && person.photos!.isNotEmpty)
                    ? person.photos![0] // Use the first image in the photos list
                    : 'https://via.placeholder.com/150'; // Placeholder image if no photo is available

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  title: Text(person.nickname ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Region: ${person.city ?? 'Unknown City'}, ${person.country ?? 'Unknown Country'}'),
                      if (person.userInterest != null && person.userInterest!.isNotEmpty)
                        Text('Interests: ${person.userInterest}'),
                      if (person.bio != null && person.bio!.isNotEmpty)
                        Text('Bio: ${person.bio}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => sendFriendRequest(person.uid!),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () => saveProfile(person.uid!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
