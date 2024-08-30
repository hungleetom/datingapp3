import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_new_app/global.dart';
import 'package:my_new_app/homeScreen/home_screen.dart';
import 'package:my_new_app/widgets/custom_text_field_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {

  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlsList = [];
  double val = 0;

  //personal info
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();
  TextEditingController profileHeadingTextEditingController = TextEditingController();
  TextEditingController lookingForInaPartnerTextEditingController = TextEditingController();
  
  //Appearance
  TextEditingController heightTextEditingController = TextEditingController();
  TextEditingController weightTextEditingController = TextEditingController();
  TextEditingController bodyTypeTextEditingController = TextEditingController();
  //Life Sytle
  TextEditingController drinkTextEditingController = TextEditingController();
  TextEditingController smokeTextEditingController = TextEditingController();
  TextEditingController martialTextEditingController = TextEditingController();
  TextEditingController haveChildrenTextEditingController = TextEditingController();
  TextEditingController numberOfChildrenTextEditingController = TextEditingController();
  TextEditingController professionTextEditingController = TextEditingController();
  TextEditingController employmentStatusTextEditingController = TextEditingController();
  TextEditingController incomeTextEditingController = TextEditingController();
  TextEditingController livingSituationTextEditingController = TextEditingController();
  TextEditingController willingToRelocateTextEditingController = TextEditingController();
  TextEditingController relationshipYouAreLookingForTextEditingController = TextEditingController();

  //Background - Cultural Values
  TextEditingController nationalityTextEditingController = TextEditingController();
  TextEditingController educationTextEditingController = TextEditingController();
  TextEditingController languageTextEditingController = TextEditingController();
  TextEditingController religionTextEditingController = TextEditingController();
  TextEditingController ethnicityTextEditingController = TextEditingController();


  // Personal Info
  String name = '';
  String age = '';
  String gender = '';
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


  chooseImage() async
  {
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _image.add(File(pickedFile!.path));
    });
  }

  uploadImages() async
  {
    int i = 1;

    for(var img in _image)
    {
      setState(() {
        val = i / _image.length;
      });
      var refImages = FirebaseStorage.instance.ref().child("images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");

      await refImages.putFile(img).whenComplete(() async
        {
          await refImages.getDownloadURL().then((urlImage)
          {
            urlsList.add(urlImage);
            i++;
          }
          );
        }
      );
    }
  }

  retrieveUserData() async{
    await FirebaseFirestore.instance.
    collection("users").
    doc(currentUserID).get().then((snapshot){
      if(snapshot.exists)
      {
        setState(() {
          // Personal Info
          name = snapshot.data()!['name'];
          nameTextEditingController.text = name;

          age = snapshot.data()!['age'].toString();
          ageTextEditingController.text = age;

          gender = snapshot.data()!['gender'].toString();
          genderTextEditingController.text = gender;

          phoneNumber = snapshot.data()!['phoneNumber'];
          phoneNumberTextEditingController.text = phoneNumber;

          city = snapshot.data()!['city'];
          cityTextEditingController.text = city;

          country = snapshot.data()!['country'];
          countryTextEditingController.text = country;

          profileHeading = snapshot.data()!['profileHeading'];
          profileHeadingTextEditingController.text = profileHeading;

          lookingForInaPartner = snapshot.data()!['lookingForInaPartner'];
          lookingForInaPartnerTextEditingController.text = lookingForInaPartner;

          // Appearance
          height = snapshot.data()!['height'];
          heightTextEditingController.text = height;

          weight = snapshot.data()!['weight'];
          weightTextEditingController.text = weight;

          bodyType = snapshot.data()!['bodyType'];
          bodyTypeTextEditingController.text = bodyType;

          // Life Style
          drink = snapshot.data()!['drink'];
          drinkTextEditingController.text = drink;

          smoke = snapshot.data()!['smoke'];
          smokeTextEditingController.text = smoke;

          maritalStatus = snapshot.data()!['maritalStatus'];
          martialTextEditingController.text = maritalStatus;

          haveChildren = snapshot.data()!['haveChildren'];
          haveChildrenTextEditingController.text = haveChildren;

          numberOfChildren = snapshot.data()!['numberOfChildren'];
          numberOfChildrenTextEditingController.text = numberOfChildren;

          profession = snapshot.data()!['profession'];
          professionTextEditingController.text = profession;

          employmentStatus = snapshot.data()!['employmentStatus'];
          employmentStatusTextEditingController.text = employmentStatus;

          income = snapshot.data()!['income'];
          incomeTextEditingController.text = income;

          livingSituation = snapshot.data()!['livingSituation'];
          livingSituationTextEditingController.text = livingSituation;

          willingToRelocate = snapshot.data()!['willingToRelocate'];
          willingToRelocateTextEditingController.text = willingToRelocate;

          relationshipYouAreLookingFor = snapshot.data()!['relationshipYouAreLookingFor'];
          relationshipYouAreLookingForTextEditingController.text = relationshipYouAreLookingFor;

          // Background - Cultural View
          nationality = snapshot.data()!['nationality'];
          nationalityTextEditingController.text = nationality;

          education = snapshot.data()!['education'];
          educationTextEditingController.text = education;

          languageSpoken = snapshot.data()!['languageSpoken'];
          languageTextEditingController.text = languageSpoken;

          religion = snapshot.data()!['religion'];
          religionTextEditingController.text = religion;

          ethnicity = snapshot.data()!['ethnicity'];
          ethnicityTextEditingController.text = ethnicity;



        });
      }
    });
  }

  updateUserDataToFirestoreDatabase(
    String name,
    String age,
    String gender,
    String phoneNumber,
    String city,
    String country,
    String profileHeading,
    String lookingForInaPartner,
    int publishedDateTime,

    String height,
    String weight,
    String bodyType,

    String drink,
    String smoke,
    String maritalStatus,
    String haveChildren,
    String numberOfChildren,
    String profession,
    String employmentStatus,
    String income,
    String livingSituation,
    String willingToRelocate,
    String relationshipYouAreLookingFor,

    String nationality,
    String education,
    String languageSpoken,
    String religion,
    String ethnicity,
  ) async
  {
    showDialog(
                context: context
              , builder: (context)
              {
                return const AlertDialog(
                  content:  SizedBox(
                    height: 200,
                    child: Center(
                      child:Column(
                       children: [
                         CircularProgressIndicator(),
                         SizedBox(
                          height: 10,
                         ),
                         Text("uploading images..."),
                       ],
                     )),
                  ),
                );
              });
              await uploadImages();

             await FirebaseFirestore.instance.collection("users")
              .doc(currentUserID).update({
                'name' : name,
                'age' : int.parse(age),
                'gender' : gender.toLowerCase(),
                'phoneNumber' : phoneNumber,
                'city' : city,
                'country' : country,
                'profileHeading' : profileHeading,
                'lookingForInaPartner' : lookingForInaPartner,
                'publishedDateTime' : publishedDateTime,

                'height' : height,
                'weight' : weight,
                'bodyType' : bodyType,

                'drink' : drink,
                'smoke' : smoke,
                'maritalStatus' : maritalStatus,
                'haveChildren' : haveChildren,
                'numberOfChildren' : numberOfChildren,
                'profession' : profession,
                'employmentStatus' : employmentStatus,
                'income' : income,
                'livingSituation' : livingSituation,
                'willingToRelocate' : willingToRelocate,
                'relationshipYouAreLookingFor' : relationshipYouAreLookingFor,

                'nationality' : nationality,
                'education' : education,
                'languageSpoken' : languageSpoken,
                'religion' : religion,
                'ethnicity' : ethnicity,


                'urlImage1' : urlsList[0].toString(),
                'urlImage2' : urlsList[1].toString(),
                'urlImage3' : urlsList[2].toString(),
                'urlImage4' : urlsList[3].toString(),
                'urlImage5' : urlsList[4].toString(),
                


              });

              Get.snackbar("Updated", "Your account has been updated successfully");

              Get.to(const HomeScreen());

              setState(() {
                uploading = false;
                _image.clear();
                urlsList.clear();
              });

          
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          next ? "Profile Information" : "Choose 5 Images", //If the user is True then it shows profile information. However, if the user is False, then they have to upload 5 images
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          next ? Container()
          : IconButton(
            onPressed: ()
            {
              if(_image.length == 5)
              {
                setState(() {
                  uploading = false;
                  next = true;
                });
              }
              else
              {
                Get.snackbar("5 Images", "Please choose 5 images");
              }
            },
           icon: const Icon(Icons.navigate_next_outlined))
        ],
      ),
      body: next ? 
       SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 2,
              ),
              


                //personal info
                const Text(
                  "Personal Info: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(
                  height: 12,
                ),

                 //name
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: nameTextEditingController,
                    labelText: "Name",
                    iconData: Icons.person_outline,
                    isObscure: false,
                  ),
                ),
               
                
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //age
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: ageTextEditingController,
                    labelText: "Age",
                    iconData: Icons.numbers,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //gender
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: genderTextEditingController,
                    labelText: "Gender",
                    iconData: Icons.person_pin,
                    isObscure: false,
                  ),
                ),
               
                
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //phoneNumber
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: phoneNumberTextEditingController,
                    labelText: "Phone Nubmer",
                    iconData: Icons.phone,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //city
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: cityTextEditingController,
                    labelText: "City",
                    iconData: Icons.location_city,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //country
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: countryTextEditingController,
                    labelText: "Country",
                    iconData: Icons.location_city,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //profileHeading
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: profileHeadingTextEditingController,
                    labelText: "Profile",
                    iconData: Icons.text_fields,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //whatyouarelookingforinapartner
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: lookingForInaPartnerTextEditingController,
                    labelText: "What you're looking for in a partner",
                    iconData: Icons.face,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //Appearance
                const Text(
                  "Appearance: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                 //height
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: heightTextEditingController,
                    labelText: "Height",
                    iconData: Icons.insert_chart,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //weight
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: weightTextEditingController,
                    labelText: "Weight",
                    iconData: Icons.table_chart,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //Body Type
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: bodyTypeTextEditingController,
                    labelText: "Body Type",
                    iconData: Icons.type_specimen,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //Life SYtle
                const Text(
                  "Life Style: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                 //drink
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: drinkTextEditingController,
                    labelText: "Drink",
                    iconData: Icons.local_drink_outlined,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //smoke
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: smokeTextEditingController,
                    labelText: "Smoke",
                    iconData: Icons.smoking_rooms,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //marital status
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: martialTextEditingController,
                    labelText: "Marital Status",
                    iconData: CupertinoIcons.person_2,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //havechildren
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: haveChildrenTextEditingController,
                    labelText: "Do you have children?",
                    iconData: CupertinoIcons.person_3_fill,
                    isObscure: false,
                  ),
                ),

                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //Number of Children
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: numberOfChildrenTextEditingController,
                    labelText: "Number of Children",
                    iconData: CupertinoIcons.person_2,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //profession
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: professionTextEditingController,
                    labelText: "Profession",
                    iconData: Icons.business_center,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //employment status
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: employmentStatusTextEditingController,
                    labelText: "Employment Status",
                    iconData: CupertinoIcons.rectangle_stack_fill_badge_person_crop,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //income
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: incomeTextEditingController,
                    labelText: "Income",
                    iconData: CupertinoIcons.money_dollar,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //living situation
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: livingSituationTextEditingController,
                    labelText: "Living Situation",
                    iconData: CupertinoIcons.house,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //willing to relocate
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: willingToRelocateTextEditingController,
                    labelText: "Are you Willing to Relocate",
                    iconData: CupertinoIcons.house,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),


                //What you are looking for
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: relationshipYouAreLookingForTextEditingController,
                    labelText: "What relationship are you looking for?",
                    iconData: CupertinoIcons.person_2,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //Background - Cultural Values

                const Text(
                  "Background: ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                 //Nathionality
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: nationalityTextEditingController,
                    labelText: "Nathionality",
                    iconData: Icons.flag,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
                //Education
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: educationTextEditingController,
                    labelText: "Education",
                    iconData: Icons.history_edu,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //Language Spoken
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: languageTextEditingController,
                    labelText: "Language Spoken",
                    iconData: CupertinoIcons.globe,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //religion
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: religionTextEditingController,
                    labelText: "Religion",
                    iconData: CupertinoIcons.star,
                    isObscure: false,
                  ),
                ),

                //space between email and password
                const SizedBox(
                  height: 20,
                ),

                //Ethnicity
                SizedBox(
                  width: MediaQuery.of(context).size.width - 36, //This will get the screen size of the device and it will adjust it's size based on the screen size
                  height: 50,
                  child: CustomTextFieldWidget(
                    editingController: ethnicityTextEditingController,
                    labelText: "Ethnicity",
                    iconData: CupertinoIcons.person,
                    isObscure: false,
                  ),
                ),
                //space between email and password
                const SizedBox(
                  height: 20,
                ),
              Container( //You can decorate using Container, but not with SizeBox
                  width: MediaQuery.of(context).size.width - 36,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                  ),
                  child: InkWell(
                    onTap: () async
                    {
                      if(
                          //Personal Info
                          nameTextEditingController.text.trim().isNotEmpty &&
                          ageTextEditingController.text.trim().isNotEmpty &&
                          genderTextEditingController.text.trim().isNotEmpty &&
                          phoneNumberTextEditingController.text.trim().isNotEmpty &&
                          cityTextEditingController.text.trim().isNotEmpty &&
                          countryTextEditingController.text.trim().isNotEmpty &&
                          profileHeadingTextEditingController.text.trim().isNotEmpty &&
                          lookingForInaPartnerTextEditingController.text.trim().isNotEmpty &&

                          //Appearance
                          heightTextEditingController.text.trim().isNotEmpty &&
                          weightTextEditingController.text.trim().isNotEmpty &&
                          bodyTypeTextEditingController.text.trim().isNotEmpty &&

                          //Life Style
                          drinkTextEditingController.text.trim().isNotEmpty &&
                          smokeTextEditingController.text.trim().isNotEmpty &&
                          martialTextEditingController.text.trim().isNotEmpty &&
                          haveChildrenTextEditingController.text.trim().isNotEmpty &&
                          numberOfChildrenTextEditingController.text.trim().isNotEmpty &&
                          professionTextEditingController.text.trim().isNotEmpty &&
                          employmentStatusTextEditingController.text.trim().isNotEmpty &&
                          incomeTextEditingController.text.trim().isNotEmpty &&
                          livingSituationTextEditingController.text.trim().isNotEmpty &&
                          willingToRelocateTextEditingController.text.trim().isNotEmpty &&
                          relationshipYouAreLookingForTextEditingController.text.trim().isNotEmpty &&

                          //Background
                          nationalityTextEditingController.text.trim().isNotEmpty &&
                          educationTextEditingController.text.trim().isNotEmpty &&
                          languageTextEditingController.text.trim().isNotEmpty &&
                          religionTextEditingController.text.trim().isNotEmpty &&
                          ethnicityTextEditingController.text.trim().isNotEmpty
                        )
                        {
                         
                          _image.isNotEmpty ? 
                          await updateUserDataToFirestoreDatabase(
                            
                            nameTextEditingController.text.trim(),            // String name
                            ageTextEditingController.text.trim(),             // String age
                            genderTextEditingController.text.trim(),
                            phoneNumberTextEditingController.text.trim(),     // String phoneNumber
                            cityTextEditingController.text.trim(),            // String city
                            countryTextEditingController.text.trim(),         // String country
                            profileHeadingTextEditingController.text.trim(),  // String profileHeading
                            lookingForInaPartnerTextEditingController.text.trim(), // String lookingForInaPartner
                            DateTime.now().millisecondsSinceEpoch,            // int publishedDateTime

                            heightTextEditingController.text.trim(),          // String height
                            weightTextEditingController.text.trim(),          // String weight
                            bodyTypeTextEditingController.text.trim(),        // String bodyType

                            drinkTextEditingController.text.trim(),           // String drink
                            smokeTextEditingController.text.trim(),           // String smoke
                            martialTextEditingController.text.trim(),         // String maritalStatus
                            haveChildrenTextEditingController.text.trim(),    // String haveChildren
                            numberOfChildrenTextEditingController.text.trim(), // String numberOfChildren
                            professionTextEditingController.text.trim(),      // String profession
                            employmentStatusTextEditingController.text.trim(), // String employmentStatus
                            incomeTextEditingController.text.trim(),          // String income
                            livingSituationTextEditingController.text.trim(), // String livingSituation
                            willingToRelocateTextEditingController.text.trim(), // String willingToRelocate
                            relationshipYouAreLookingForTextEditingController.text.trim(), // String relationshipYouAreLookingFor

                            nationalityTextEditingController.text.trim(),     // String nationality
                            educationTextEditingController.text.trim(),       // String education
                            languageTextEditingController.text.trim(),        // String languageSpoken
                            religionTextEditingController.text.trim(),        // String religion
                            ethnicityTextEditingController.text.trim(),       // String ethnicity
                          ) : null; //This translates to "else, do nothing(null)"
                
                        }
                        else
                        {
                          Get.snackbar("A Field is Empty", "Please fill out all field in text fields.");
                        }

                    },
                    child: const Center(
                      child: Text(
                        "Update Account",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                    )
                  ),
                ),

              //space between login button and signup button
                const SizedBox(
                  height: 20,
                ),

            ],
          ),
          ),
      )
       : 
       Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              itemCount: _image.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3
                ), //display 3 images in a row
              itemBuilder: (context, index)
              {
                return index == 0 
                ? Container(
                  color: Colors.white30,
                  child: Center(
                    child: IconButton(
                      onPressed: ()
                      {
                        if(_image.length < 6)
                        {
                          !uploading ? chooseImage() : null;
                        }
                        else
                        {
                          setState(() {
                            uploading == true;
                          });
                        }
                      },
                       icon: const Icon(Icons.add)),
                  ),
                ) 
                : Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                      _image[index - 1]
                    ),
                    fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          )
        ],
       ),
    );
  }
}