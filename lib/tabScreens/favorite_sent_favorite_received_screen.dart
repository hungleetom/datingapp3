import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_new_app/global.dart';

class FavoriteSentFavoriteReceivedScreen extends StatefulWidget {
  const FavoriteSentFavoriteReceivedScreen({super.key});

  @override
  State<FavoriteSentFavoriteReceivedScreen> createState() => _FavoriteSentFavoriteReceivedScreenState();
}

class _FavoriteSentFavoriteReceivedScreenState extends State<FavoriteSentFavoriteReceivedScreen> {
  
  bool isFavoriteSentClicked = true;
  List<String> favoriteSentList = [];
  List<String> favoriteReceivedList = [];
  List favoriteList = [];
  
  getFavoriteListKeys() async 
  {
    if(isFavoriteSentClicked)
    {
      var favoritesSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString()).collection("favoriteSent")
          .get();

      for(int i = 0; i < favoritesSentDocument.docs.length; i++){
        favoriteSentList.add(favoritesSentDocument.docs[i].id);
      }

      print("favoriteSentList = $favoriteSentList");
      getKeysDataFromUsersCollection(favoriteSentList);
    }
    else
    {
      var favoriteReceivedDocument= await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString()).collection("favoriteReceived")
          .get();

      for(int i = 0; i < favoriteReceivedDocument.docs.length; i++){
        favoriteReceivedList.add(favoriteReceivedDocument.docs[i].id);
      }
      print("favoriteReceivedList = $favoriteReceivedList");
      getKeysDataFromUsersCollection(favoriteReceivedList);
    }



    
    getKeysDataFromUsersCollection(favoriteSentList);
  }
  
  getKeysDataFromUsersCollection(List<String> keysList) async
  {
    var allUsersDocument = await FirebaseFirestore.instance.collection("users").get();

    for(int i = 0; i < allUsersDocument.docs.length; i++){
      for(int k = 0; k < keysList.length; k++){
        if(((allUsersDocument.docs[i].data() as dynamic)["uid"]) == keysList[k])
        {
          favoriteList.add(allUsersDocument.docs[i].data());
        }
      }
    }

    setState(() {
      favoriteList;
    });

    print("favoriteList = $favoriteList");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFavoriteListKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: ()
              {
                favoriteSentList.clear();
                favoriteSentList = [];
                favoriteReceivedList.clear();
                favoriteReceivedList = [];
                favoriteList = [];

                setState(() {
                  isFavoriteSentClicked = true;
                });
                getFavoriteListKeys();
              },
              child: Text(
                "My Favorite",
                style: TextStyle(
                  color: isFavoriteSentClicked ? Colors.white : Colors.grey,
                  fontWeight: isFavoriteSentClicked ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),

            const Text(
              "  |  ",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            TextButton(
              onPressed: ()
              {
                favoriteSentList.clear();
                favoriteSentList = [];
                favoriteReceivedList.clear();
                favoriteReceivedList = [];
                favoriteList = [];

                setState(() {
                  isFavoriteSentClicked = true;
                });
                getFavoriteListKeys();
              },
              child: Text(
                "I'm their Favorite",
                style: TextStyle(
                  color: isFavoriteSentClicked ? Colors.grey : Colors.white,
                  fontWeight: isFavoriteSentClicked ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: favoriteList.isEmpty 
      ? const Center(
        child: Icon(
          Icons.person_off_sharp,
          color: Colors.white,
          size: 60,
        ),
      ) 
      : GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(8),
        children: List.generate(favoriteList.length, (index)
        {
          return GridTile(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                color: Colors.blue.shade200,
                child: GestureDetector(
                  onTap: ()
                  {

                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(favoriteList[index]["imageProfile"],),
                      fit: BoxFit.cover,
                      ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Spacer(),
                              //name age

                               Text (
                                    "${favoriteList[index]["name"]} | ${favoriteList[index]["age"]}",
                                    maxLines: 2,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  //icon city country
                                Row(
                                  children: [

                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.grey,
                                      size: 16,
                                    ),

                                    Expanded(                              
                                      child: Text  (
                                        "${favoriteList[index]["city"]} | ${favoriteList[index]["country"]}",
                                        maxLines: 2,
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                              
                            ],
                          ),
                        ),
                        ),
                    ),
                    ),
                ),
              ),
              );
        }),
      ),
    );
  }
}