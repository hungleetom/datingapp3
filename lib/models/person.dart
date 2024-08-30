import 'package:cloud_firestore/cloud_firestore.dart';

class Person{

  //personal info
  String? uid;
  String? email;
  String? password;
  String? imageProfile;
  String? name;
  int? age;
  String? gender;
  String? phoneNumber;
  String? city;
  String? country;
  String? profileHeading;
  String? lookingForInaPartner;
  int? publishedDateTime;
  
  
  //Appearance
  String? height;
  String? weight;
  String? bodyType;

  //Life style
  String? drink;
  String? smoke;
  String? maritalStatus;
  String? haveChildren;
  String? numberOfChildren;
  String? profession;
  String? employmentStatus;
  String? income;
  String? livingSituation;
  String? willingToRelocate;
  String? relationshipYouAreLookingFor;
  

  //Background - Cultural View
  String? nationality;
  String? education;
  String? languageSpoken;
  String? religion;
  String? ethnicity;


  Person({
    //personal info
    this.uid,
    this.email,
    this.password,
    this.imageProfile,
    this.name,
    this.age,
    this.gender,
    this.phoneNumber,
    this.city,
    this.country,
    this.profileHeading,
    this.lookingForInaPartner,
    this.publishedDateTime,

    //appearance
    this.height,
    this.weight,
    this.bodyType,

    //life style
    this.drink,
    this.smoke,
    this.maritalStatus,
    this.haveChildren,
    this.numberOfChildren,
    this.profession,
    this.employmentStatus,
    this.income,
    this.livingSituation,
    this.willingToRelocate,
    this.relationshipYouAreLookingFor,

    //background cultural value
    this.nationality,
    this.education,
    this.languageSpoken,
    this.religion,
    this.ethnicity,
    
  });

  static Person fromDataSnapshot(DocumentSnapshot snapshot){
    
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    return Person(
      //personal info
      uid: dataSnapshot["uid"],
      email: dataSnapshot["email"],
      password: dataSnapshot["password"],
      name: dataSnapshot["name"],
      imageProfile: dataSnapshot["imageProfile"],
      age: dataSnapshot["age"],
      gender: dataSnapshot["gender"],
      phoneNumber: dataSnapshot["phoneNumber"],
      city: dataSnapshot["city"],
      country: dataSnapshot["country"],
      profileHeading: dataSnapshot["profileHeading"],
      lookingForInaPartner: dataSnapshot["lookingForInaPartner"],
      publishedDateTime: dataSnapshot["publishedDateTime"],

      //appearance
      height: dataSnapshot["height"],
      weight: dataSnapshot["weight"],
      bodyType: dataSnapshot["bodyType"],

      //life style
      drink: dataSnapshot["drink"],
      smoke: dataSnapshot["smoke"],
      maritalStatus: dataSnapshot["maritalStatus"],
      haveChildren: dataSnapshot["haveChildren"],
      numberOfChildren: dataSnapshot["numberOfChildren"],
      profession: dataSnapshot["profession"],
      employmentStatus: dataSnapshot["employmentStatus"],
      income: dataSnapshot["income"],
      livingSituation: dataSnapshot["livingSituation"],
      willingToRelocate: dataSnapshot["willingToRelocate"],
      relationshipYouAreLookingFor: dataSnapshot["relationshipYouAreLookingFor"],

      //background - clutural value
      nationality: dataSnapshot["nationality"],
      education: dataSnapshot["education"],
      languageSpoken: dataSnapshot["languageSpoken"],
      religion: dataSnapshot["religion"],
      ethnicity: dataSnapshot["ethnicity"],
      
    );

  }
  Map<String, dynamic> toJson()=>
  {
    //personal info
    "uid" : uid,
    "email" : email,
    "password" : password,
    "imageProfile" : imageProfile,
    "name" : name,
    "age" : age,
    "gender" : gender,
    "phoneNumber" : phoneNumber,
    "city" : city,
    "country" : country,
    "profileHeading" : profileHeading,
    "lookingForInaPartner" : lookingForInaPartner,
    "publishedDateTime" : publishedDateTime,

    //appearance
    "height" : height,
    "weight" : weight,
    "bodyType" : bodyType,

    //lifestyle
    "drink" : drink,
    "smoke" : smoke,
    "maritalStatus" : maritalStatus,
    "haveChildren" : haveChildren,
    "numberOfChildren" : numberOfChildren,
    "profession" : profession,
    "employmentStatus" : employmentStatus,
    "income" : income,
    "livingSituation" : livingSituation,
    "willingToRelocate" : willingToRelocate,
    "relationshipYouAreLookingFor" : relationshipYouAreLookingFor,


    //background cultural values
    "nationality" : nationality,
    "education" : education,
    "languageSpoken" : languageSpoken,
    "religion" : religion,
    "ethnicity" : ethnicity,
    
  };  
  
}