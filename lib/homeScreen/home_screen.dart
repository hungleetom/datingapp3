import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_new_app/pushNotificationSystem/push_notification_system.dart';
import 'package:my_new_app/tabScreens/chat_page.dart';
import 'package:my_new_app/tabScreens/like_sent_like_received_screen.dart';
import 'package:my_new_app/tabScreens/user_details_screen.dart';
import 'package:my_new_app/tabScreens/match_screen.dart';
import 'package:my_new_app/tabScreens/search_page.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex; // Accept initial index as argument

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _screenIndex; // Track the active screen index
  late List<Widget> _tabScreenList; // List of screens to show in tabs

  @override
  void initState() {
    super.initState();

    // Set the initial screen index
    _screenIndex = widget.initialIndex;

    // Placeholder values for chat page
    String placeholderUserId = 'testUserId';
    String placeholderUserNickname = 'TestUser';

    // Initialize the list of tab screens
    _tabScreenList = [
      const MatchScreen(),
      const LikeSentLikeReceivedScreen(),
      ChatPage(
        receiverUserId: placeholderUserId,
        receiverUserNickname: placeholderUserNickname,
      ),
      const SearchPage(),
      UserDetailsScreen(userID: FirebaseAuth.instance.currentUser!.uid),
    ];

    // Initialize Push Notification System
    _initializePushNotification();
  }

  void _initializePushNotification() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.whenNotificationReceived(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Close the app when back button is pressed
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Keep all icons visible
          backgroundColor: Colors.black, // Background color of the nav bar
          selectedItemColor: Colors.white, // Active icon color
          unselectedItemColor: Colors.white12, // Inactive icon color
          currentIndex: _screenIndex, // Highlight the active tab
          onTap: (int index) {
            setState(() {
              _screenIndex = index; // Update the active tab index
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star, size: 30),
              label: "Likes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, size: 30),
              label: "Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30),
              label: "Search",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: "Profile",
            ),
          ],
        ),
        body: IndexedStack(
          index: _screenIndex,
          children: _tabScreenList, // Display the active tab's content
        ),
      ),
    );
  }
}
