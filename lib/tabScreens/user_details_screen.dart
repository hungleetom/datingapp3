import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:get/get.dart';
import 'package:my_new_app/accountSettingScreen/account_settings_screen.dart';
import 'package:my_new_app/global.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userID;

  const UserDetailsScreen({super.key, required this.userID});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // Personal Info
  String name = '';
  String age = '';
  String phoneNumber = '';
  String city = '';
  String country = '';
  String profileHeading = '';
  String lookingForInaPartner = '';

  // Appearance
  String height = '';
  String weight = '';
  String bodyType = '';

  // Life Style
  String drink = '';
  String smoke = '';
  String maritalStatus = '';
  String haveChildren = '';
  String numberOfChildren = '';
  String profession = '';
  String employmentStatus = '';
  String income = '';
  String livingSituation = '';
  String willingToRelocate = '';
  String relationshipYouAreLookingFor = '';

  // Background - Cultural View
  String nationality = '';
  String education = '';
  String languageSpoken = '';
  String religion = '';
  String ethnicity = '';

  // Slider images (default photos for users who haven't filled out the entire profile picture)
  String urlImage1 = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";
  String urlImage2 = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";
  String urlImage3 = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";
  String urlImage4 = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";
  String urlImage5 = "https://firebasestorage.googleapis.com/v0/b/dating-app-7738e.appspot.com/o/Place%20Holder%2FSample_User_Icon.png?alt=media&token=2ab2bec4-e6ec-461f-9c5b-96c6b6fbfd15";

  // Retrieve user information from Firebase
  retrieveUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get()
        .then((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;

        setState(() {
          // Check if the images exist
          if (data["urlImage1"] != null) urlImage1 = data["urlImage1"];
          if (data["urlImage2"] != null) urlImage2 = data["urlImage2"];
          if (data["urlImage3"] != null) urlImage3 = data["urlImage3"];
          if (data["urlImage4"] != null) urlImage4 = data["urlImage4"];
          if (data["urlImage5"] != null) urlImage5 = data["urlImage5"];

          // Personal Info
          name = data["name"] ?? '';
          age = data['age']?.toString() ?? '';
          phoneNumber = data["phoneNumber"] ?? '';
          city = data["city"] ?? '';
          country = data["country"] ?? '';
          profileHeading = data["profileHeading"] ?? '';
          lookingForInaPartner = data["lookingForInaPartner"] ?? '';

          // Appearance
          height = data["height"] ?? '';
          weight = data["weight"] ?? '';
          bodyType = data["bodyType"] ?? '';

          // Life Style
          drink = data["drink"] ?? '';
          smoke = data["smoke"] ?? '';
          maritalStatus = data["maritalStatus"] ?? '';
          haveChildren = data["haveChildren"] ?? '';
          numberOfChildren = data["numberOfChildren"] ?? '';
          profession = data["profession"] ?? '';
          employmentStatus = data["employmentStatus"] ?? '';
          income = data["income"] ?? '';
          livingSituation = data["livingSituation"] ?? '';
          willingToRelocate = data["willingToRelocate"] ?? '';
          relationshipYouAreLookingFor = data["relationshipYouAreLookingFor"] ?? '';

          // Background - Cultural View
          nationality = data["nationality"] ?? '';
          education = data["education"] ?? '';
          languageSpoken = data["languageSpoken"] ?? '';
          religion = data["religion"] ?? '';
          ethnicity = data["ethnicity"] ?? '';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        //automaticallyImplyLeading: widget.userID == currentUserID ? false : true, // Ensures the AppBar remains clean without any leading icons (like a back button) unless explicitly added.
        //This is a back button to go back on the screen
        leading: widget.userID != currentUserID ? IconButton(
          onPressed: ()
          {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, size: 30,),
          ) : Container(),
        actions: [
          widget.userID == currentUserID ? 
          Row(
            children: [ 

              IconButton( // account settings button
              onPressed: () {
                Get.to(const AccountSettingsScreen());
              },
              icon: const Icon(
                Icons.settings,
                size: 30,
              ),
            ),
              
              IconButton( // sign out button
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.logout,
                size: 30,
              ),
            ),
            ],
          ) : Container(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Carousel(
                    indicatorBarColor: Colors.black.withOpacity(0.3),
                    autoScrollDuration: const Duration(seconds: 2),
                    animationPageDuration: const Duration(milliseconds: 500),
                    activateIndicatorColor: Colors.black,
                    animationPageCurve: Curves.easeIn,
                    indicatorBarHeight: 30,
                    indicatorHeight: 10,
                    indicatorWidth: 10,
                    unActivatedIndicatorColor: Colors.grey,
                    stopAtEnd: false,
                    autoScroll: false, // Prevents the screen from scrolling by itself; the user has to use their finger to scroll.
                    items: [ // Allows the user to upload up to 5 images.
                      Image.network(urlImage1, fit: BoxFit.cover),
                      Image.network(urlImage2, fit: BoxFit.cover),
                      Image.network(urlImage3, fit: BoxFit.cover),
                      Image.network(urlImage4, fit: BoxFit.cover),
                      Image.network(urlImage5, fit: BoxFit.cover),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              // Personal Info
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Personal Info: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),
              // Personal Info table data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table( // Displays the user details in a table format
                  children: [
                    TableRow( // Row for 'name' of the user
                      children: [
                        const Text( // Title for name
                          "Name: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'name' from the database
                          name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""), // An empty Text Widget creates a row
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'age' of the user
                      children: [
                        const Text( // Title for age
                          "Age: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'age' from the database
                          age,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'phone number' of the user
                      children: [
                        const Text( // Title for phone number
                          "Phone Number: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'phone number' from the database
                          phoneNumber,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'city' of the user
                      children: [
                        const Text( // Title for city
                          "City: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'city' from the database
                          city,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'country' of the user
                      children: [
                        const Text( // Title for country
                          "Country: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'country' from the database
                          country,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'seeking' of the user
                      children: [
                        const Text( // Title for seeking
                          "Seeking: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'seeking' from the database
                          lookingForInaPartner,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                  ],
                ),
              ),

              //appearance title
              const SizedBox(height: 30,),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Appearance: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),

              //appearance table data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    TableRow( // Row for 'height' of the user
                      children: [
                        const Text( // Title for seeking
                          "Height: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'height' from the database
                          height,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'weight' of the user
                      children: [
                        const Text( // Title for seeking
                          "Weight: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'weight' from the database
                          weight,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'body type' of the user
                      children: [
                        const Text( // Title for seeking
                          "Body Type: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'bodyType' from the database
                          bodyType,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                  ],
                ),
              ),

              //Life style title
              const SizedBox(height: 30,),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Life Style Title: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),


              //life style table data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    TableRow( // Row for 'Drink' of the user
                      children: [
                        const Text( // Title for seeking
                          "Drink: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'height' from the database
                          drink,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                    TableRow( // Row for 'smoke' of the user
                      children: [
                        const Text( // Title for smoke
                          "Smoke: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'smoke' from the database
                          smoke,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Marital Status' of the user
                      children: [
                        const Text( // Title for seeking
                          "Marital Status: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'marital status' from the database
                          maritalStatus,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'children' of the user
                      children: [
                        const Text( // Title for seeking
                          "Children: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'children' from the database
                          haveChildren,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Number of Children' of the user
                      children: [
                        const Text( // Title for seeking
                          "Number of Children: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Number of Children' from the database
                          numberOfChildren,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Profession' of the user
                      children: [
                        const Text( // Title for seeking
                          "Profession: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'height' from the database
                          profession,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),


                    TableRow( // Row for 'Income' of the user
                      children: [
                        const Text( // Title for seeking
                          "Income: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Income' from the database
                          income,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Willing to Relocate' of the user
                      children: [
                        const Text( // Title for seeking
                          "Willing to Relocate: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Willing to Relocate' from the database
                          willingToRelocate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Looking for' of the user
                      children: [
                        const Text( // Title for seeking
                          "Looking For: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Looking For' from the database
                          lookingForInaPartner,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                  ],
                ),
              ),
            
             //Background - Cultural Values title
              const SizedBox(height: 30,),
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Background - Cultural Values: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                color: Colors.white,
                thickness: 2,
              ),

              //Background - Cultural Values tables data
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  children: [
                    TableRow( // Row for 'Nationality' of the user
                      children: [
                        const Text( // Title for seeking
                          "Nationality: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Nationality' from the database
                          nationality,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Education' of the user
                      children: [
                        const Text( // Title for seeking
                          "Education: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Education' from the database
                          education,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Language Spoken' of the user
                      children: [
                        const Text( // Title for seeking
                          "Language Spoken: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Language' from the database
                          languageSpoken,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Religion' of the user
                      children: [
                        const Text( // Title for seeking
                          "Religion: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Religion' from the database
                          religion,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),

                    TableRow( // Row for 'Ethnicity' of the user
                      children: [
                        const Text( // Title for seeking
                          "Ethnicity: ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text( // Displays the 'Education' from the database
                          ethnicity,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const TableRow( // Extra row for spacing
                      children: [
                        Text(""),
                        Text(""),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
