import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/controller/profile_controller.dart';
import 'package:my_new_app/global.dart';
import 'package:my_new_app/tabScreens/user_details_screen.dart';

class SwippingScreen extends StatefulWidget {
  const SwippingScreen({super.key});

  @override
  State<SwippingScreen> createState() => _SwippingScreenState();
}

class _SwippingScreenState extends State<SwippingScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  String senderName = "";
  
  String? chosenGender;
  String? chosenCountry;
  String? chosenAge;

  startChatting() {
    // Implement chat functionality here
  }

  applyFilter() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setSetter) {
          return AlertDialog(
            title: const Text("Matching Filter"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("I am looking for a:"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DropdownButton<String>(
                    hint: const Text('Select gender'),
                    value: chosenGender,
                    underline: Container(),
                    items: ['Male', 'Female', 'Others'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setSetter(() {
                        chosenGender = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Who lives in:"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DropdownButton<String>(
                    hint: const Text('Select country'),
                    value: chosenCountry,
                    underline: Container(),
                    items: ['Spain', 'France', 'Germany', 'United Kingdom', 'Canada'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setSetter(() {
                        chosenCountry = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Whose age is equal to or above:"),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DropdownButton<String>(
                    hint: const Text('Select age'),
                    value: chosenAge,
                    underline: Container(),
                    items: ['18', '25', '30', '35'].map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setSetter(() {
                        chosenAge = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // Apply filters logic
                },
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }

  readCurrentUserData() async {
    await FirebaseFirestore.instance.collection("users").doc(currentUserID).get().then((dataSnapshot) {
      setState(() {
        senderName = dataSnapshot.data()!["name"].toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (profileController.allUserProfileList.isEmpty) {
          return const Center(
            child: Text(
              "No profiles available",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          );
        }

        return PageView.builder(
          itemCount: profileController.allUserProfileList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final eachProfileInfo = profileController.allUserProfileList[index];

            return DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(eachProfileInfo.imageProfile.toString()),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: IconButton(
                          onPressed: applyFilter,
                          icon: const Icon(
                            Icons.filter_list,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Navigate to user details
                        Get.to(UserDetailsScreen(userID: eachProfileInfo.uid!));  // Ensure the UID is non-null
                      },
                      child: Column(
                        children: [
                          Text(
                            eachProfileInfo.name.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${eachProfileInfo.age} ❤ ${eachProfileInfo.city}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  profileController.getResults();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  eachProfileInfo.profession.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  eachProfileInfo.religion.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  eachProfileInfo.country.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  eachProfileInfo.ethnicity.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            profileController.favoriteSentFavoriteReceived(
                              eachProfileInfo.uid ?? '',  // Use fallback value if null
                              senderName,
                            );
                          },
                          child: Image.asset(
                            "images/favorite.png",
                            width: 60,
                          ),
                        ),
                        GestureDetector(
                          onTap: startChatting,
                          child: Image.asset(
                            "images/chat.png",
                            width: 90,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            profileController.likeSentAndLikeReceived(
                              eachProfileInfo.uid ?? '',  // Use fallback value if null
                              senderName,
                            );
                          },
                          child: Image.asset(
                            "images/like.png",
                            width: 60,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
