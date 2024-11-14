import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/models/person.dart'; // Make sure to import your Person model
import 'package:my_new_app/tabScreens/user_details_screen.dart'; // Screen to view user details

class SavedProfilesScreen extends StatefulWidget {
  const SavedProfilesScreen({super.key});

  @override
  _SavedProfilesScreenState createState() => _SavedProfilesScreenState();
}

class _SavedProfilesScreenState extends State<SavedProfilesScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Person>> fetchSavedProfiles() async {
    try {
      // Fetch the list of saved user IDs from the current user's saved collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        List<dynamic> savedUserIds = userSnapshot['savedProfiles'] ?? [];

        // Fetch each saved user's profile information
        List<Person> savedProfiles = [];
        for (String userId in savedUserIds) {
          DocumentSnapshot profileSnapshot =
              await FirebaseFirestore.instance.collection('users').doc(userId).get();

          if (profileSnapshot.exists) {
            Person person = Person.fromDataSnapshot(profileSnapshot);
            savedProfiles.add(person);
          }
        }
        return savedProfiles;
      }
      return [];
    } catch (e) {
      print('Error fetching saved profiles: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Profiles'),
      ),
      body: FutureBuilder<List<Person>>(
        future: fetchSavedProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading saved profiles.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved profiles.'));
          } else {
            List<Person> savedProfiles = snapshot.data!;
            return ListView.builder(
              itemCount: savedProfiles.length,
              itemBuilder: (context, index) {
                Person person = savedProfiles[index];
                String profileImageUrl = person.photos != null && person.photos!.isNotEmpty
                    ? person.photos![0] // Use the first image in the photos list
                    : 'https://via.placeholder.com/150'; // Placeholder image if no photo is available

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  title: Text(person.nickname ?? 'Unknown'),
                  subtitle: Text('${person.city ?? 'Unknown City'}, ${person.country ?? 'Unknown Country'}'),
                  onTap: () {
                    // Navigate to the user details screen for the selected profile
                    Get.to(() => UserDetailsScreen(userID: person.uid!));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
