import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/controller/authentication_controller.dart';
import 'package:my_new_app/widgets/custom_text_field_widget.dart';

class RegisterationScreen extends StatefulWidget {
  const RegisterationScreen({super.key});

  @override
  State<RegisterationScreen> createState() => _RegisterationScreenState();
}

class _RegisterationScreenState extends State<RegisterationScreen> {
  // Personal info controllers
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController phoneNumberTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();
  TextEditingController profileHeadingTextEditingController = TextEditingController();
  TextEditingController lookingForInaPartnerTextEditingController = TextEditingController();

  // Appearance controllers
  TextEditingController heightTextEditingController = TextEditingController();
  TextEditingController weightTextEditingController = TextEditingController();
  TextEditingController bodyTypeTextEditingController = TextEditingController();

  // Lifestyle controllers
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

  // Background controllers
  TextEditingController nationalityTextEditingController = TextEditingController();
  TextEditingController educationTextEditingController = TextEditingController();
  TextEditingController languageTextEditingController = TextEditingController();
  TextEditingController religionTextEditingController = TextEditingController();
  TextEditingController ethnicityTextEditingController = TextEditingController();

  bool showProgressbar = false;

  final authenticationController = Get.find<AuthenticationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 100),

              // Display Profile Image
              Obx(() => authenticationController.profileImage == null
                  ? const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage("images/sample_user.png"),
                      backgroundColor: Colors.black,
                    )
                  : Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(authenticationController.profileImage!),
                        ),
                      ),
                    )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await authenticationController.pickImageFileFromGallery();
                    },
                    icon: const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      await authenticationController.captureImageFromPhoneCamera();
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 100),

              // Personal Info
              const Text(
                "Personal Info: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              buildCustomTextField(context, nameTextEditingController, "Name", Icons.person_outline),
              const SizedBox(height: 20),
              buildCustomTextField(context, emailTextEditingController, "Email", Icons.email_outlined),
              const SizedBox(height: 20),
              buildCustomTextField(context, passwordTextEditingController, "Password", Icons.lock_outline, isObscure: true),
              const SizedBox(height: 20),
              buildCustomTextField(context, ageTextEditingController, "Age", Icons.numbers),
              const SizedBox(height: 20),
              buildCustomTextField(context, genderTextEditingController, "Gender", Icons.person_pin),
              const SizedBox(height: 20),
              buildCustomTextField(context, phoneNumberTextEditingController, "Phone Number", Icons.phone),
              const SizedBox(height: 20),
              buildCustomTextField(context, cityTextEditingController, "City", Icons.location_city),
              const SizedBox(height: 20),
              buildCustomTextField(context, countryTextEditingController, "Country", Icons.location_city),
              const SizedBox(height: 20),
              buildCustomTextField(context, profileHeadingTextEditingController, "Profile Heading", Icons.text_fields),
              const SizedBox(height: 20),
              buildCustomTextField(context, lookingForInaPartnerTextEditingController, "Looking For in a Partner", Icons.face),
              const SizedBox(height: 20),

              // Appearance Info
              const Text(
                "Appearance: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              buildCustomTextField(context, heightTextEditingController, "Height", Icons.insert_chart),
              const SizedBox(height: 20),
              buildCustomTextField(context, weightTextEditingController, "Weight", Icons.table_chart),
              const SizedBox(height: 20),
              buildCustomTextField(context, bodyTypeTextEditingController, "Body Type", Icons.type_specimen),
              const SizedBox(height: 20),

              // Life Style Info
              const Text(
                "Life Style: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              buildCustomTextField(context, drinkTextEditingController, "Drink", Icons.local_drink_outlined),
              const SizedBox(height: 20),
              buildCustomTextField(context, smokeTextEditingController, "Smoke", Icons.smoking_rooms),
              const SizedBox(height: 20),
              buildCustomTextField(context, martialTextEditingController, "Marital Status", CupertinoIcons.person_2),
              const SizedBox(height: 20),
              buildCustomTextField(context, haveChildrenTextEditingController, "Do you have children?", CupertinoIcons.person_3_fill),
              const SizedBox(height: 20),
              buildCustomTextField(context, numberOfChildrenTextEditingController, "Number of Children", CupertinoIcons.person_2),
              const SizedBox(height: 20),
              buildCustomTextField(context, professionTextEditingController, "Profession", Icons.business_center),
              const SizedBox(height: 20),
              buildCustomTextField(context, employmentStatusTextEditingController, "Employment Status", CupertinoIcons.rectangle_stack_fill_badge_person_crop),
              const SizedBox(height: 20),
              buildCustomTextField(context, incomeTextEditingController, "Income", CupertinoIcons.money_dollar),
              const SizedBox(height: 20),
              buildCustomTextField(context, livingSituationTextEditingController, "Living Situation", CupertinoIcons.house),
              const SizedBox(height: 20),
              buildCustomTextField(context, willingToRelocateTextEditingController, "Willing to Relocate", CupertinoIcons.house),
              const SizedBox(height: 20),
              buildCustomTextField(context, relationshipYouAreLookingForTextEditingController, "Relationship Looking For", CupertinoIcons.person_2),
              const SizedBox(height: 20),

              // Background Info
              const Text(
                "Background: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              buildCustomTextField(context, nationalityTextEditingController, "Nationality", Icons.flag),
              const SizedBox(height: 20),
              buildCustomTextField(context, educationTextEditingController, "Education", Icons.history_edu),
              const SizedBox(height: 20),
              buildCustomTextField(context, languageTextEditingController, "Language Spoken", CupertinoIcons.globe),
              const SizedBox(height: 20),
              buildCustomTextField(context, religionTextEditingController, "Religion", CupertinoIcons.star),
              const SizedBox(height: 20),
              buildCustomTextField(context, ethnicityTextEditingController, "Ethnicity", CupertinoIcons.person),
              const SizedBox(height: 20),

              // Create Account Button
              Container(
                width: MediaQuery.of(context).size.width - 36,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    if (authenticationController.profileImage != null) {
                      if (validateFields()) {
                        setState(() {
                          showProgressbar = true;
                        });

                        await authenticationController.createUserAccount(
                          emailTextEditingController.text.trim(),
                          passwordTextEditingController.text.trim(),
                          authenticationController.profileImage!,
                          nameTextEditingController.text.trim(),
                          ageTextEditingController.text.trim(),
                          genderTextEditingController.text.trim(),
                          phoneNumberTextEditingController.text.trim(),
                          cityTextEditingController.text.trim(),
                          countryTextEditingController.text.trim(),
                          profileHeadingTextEditingController.text.trim(),
                          lookingForInaPartnerTextEditingController.text.trim(),
                          DateTime.now().millisecondsSinceEpoch,
                          heightTextEditingController.text.trim(),
                          weightTextEditingController.text.trim(),
                          bodyTypeTextEditingController.text.trim(),
                          drinkTextEditingController.text.trim(),
                          smokeTextEditingController.text.trim(),
                          martialTextEditingController.text.trim(),
                          haveChildrenTextEditingController.text.trim(),
                          numberOfChildrenTextEditingController.text.trim(),
                          professionTextEditingController.text.trim(),
                          employmentStatusTextEditingController.text.trim(),
                          incomeTextEditingController.text.trim(),
                          livingSituationTextEditingController.text.trim(),
                          willingToRelocateTextEditingController.text.trim(),
                          relationshipYouAreLookingForTextEditingController.text.trim(),
                          nationalityTextEditingController.text.trim(),
                          educationTextEditingController.text.trim(),
                          languageTextEditingController.text.trim(),
                          religionTextEditingController.text.trim(),
                          ethnicityTextEditingController.text.trim(),
                        );

                        setState(() {
                          showProgressbar = false;
                          authenticationController.pickedFile.value = null;
                        });
                      } else {
                        Get.snackbar("A Field is Empty", "Please fill out all fields.");
                      }
                    } else {
                      Get.snackbar("Image File Missing", "Please pick an image from Gallery or capture with Camera");
                    }
                  },
                  child: const Center(
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Already Have an Account? Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already Have an Account?",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      "Login Here",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Progress Bar
              showProgressbar == true
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomTextField(BuildContext context, TextEditingController controller, String labelText, IconData iconData, {bool isObscure = false}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 36,
      height: 50,
      child: CustomTextFieldWidget(
        editingController: controller,
        labelText: labelText,
        iconData: iconData,
        isObscure: isObscure,
      ),
    );
  }

  bool validateFields() {
    return emailTextEditingController.text.trim().isNotEmpty &&
        passwordTextEditingController.text.trim().isNotEmpty &&
        nameTextEditingController.text.trim().isNotEmpty &&
        ageTextEditingController.text.trim().isNotEmpty &&
        genderTextEditingController.text.trim().isNotEmpty &&
        phoneNumberTextEditingController.text.trim().isNotEmpty &&
        cityTextEditingController.text.trim().isNotEmpty &&
        countryTextEditingController.text.trim().isNotEmpty &&
        profileHeadingTextEditingController.text.trim().isNotEmpty &&
        lookingForInaPartnerTextEditingController.text.trim().isNotEmpty &&
        heightTextEditingController.text.trim().isNotEmpty &&
        weightTextEditingController.text.trim().isNotEmpty &&
        bodyTypeTextEditingController.text.trim().isNotEmpty &&
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
        nationalityTextEditingController.text.trim().isNotEmpty &&
        educationTextEditingController.text.trim().isNotEmpty &&
        languageTextEditingController.text.trim().isNotEmpty &&
        religionTextEditingController.text.trim().isNotEmpty &&
        ethnicityTextEditingController.text.trim().isNotEmpty;
  }
}
