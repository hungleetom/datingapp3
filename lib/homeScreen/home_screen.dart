import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_new_app/pushNotificationSystem/push_notification_system.dart';
import 'package:my_new_app/tabScreens/chat_page.dart';
import 'package:my_new_app/tabScreens/favorite_sent_favorite_received_screen.dart';
import 'package:my_new_app/tabScreens/like_sent_like_received_screen.dart';
import 'package:my_new_app/tabScreens/swipping_screen.dart';
import 'package:my_new_app/tabScreens/user_details_screen.dart';
import 'package:my_new_app/tabScreens/view_sent_view_received_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;

  final String userID = 'example_user_id'; // Replace with the actual userID you want to pass

  late List<Widget> tabScreenList;

  @override
  void initState() {
    super.initState();
    
    // Initialize the tab screen list
    tabScreenList = [
      const SwippingScreen(),
      const ViewSentViewReceivedScreen(),
      const FavoriteSentFavoriteReceivedScreen(),
      const ChatPage(receiverUserEmail: 'test@example.com', receiverUserID: 'some_user_id'),
      const LikeSentLikeReceivedScreen(),
      UserDetailsScreen(userID: FirebaseAuth.instance.currentUser!.uid), // Pass the userID here
    ];

    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.whenNotificationReceived(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indexNumber) {
          setState(() {
            screenIndex = indexNumber;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white12,
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.remove_red_eye,
              size: 30,
            ),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star,
              size: 30,
            ),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 30,
            ),
            label: ""
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: ""
          ),
        ],
      ),
      body: tabScreenList[screenIndex],
    );
  }
}
