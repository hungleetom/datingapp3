import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UpdateQuestionnaireScreen extends StatefulWidget {
  const UpdateQuestionnaireScreen({super.key});

  @override
  State<UpdateQuestionnaireScreen> createState() =>
      _UpdateQuestionnaireScreenState();
}

class _UpdateQuestionnaireScreenState extends State<UpdateQuestionnaireScreen> {
  List<Map<String, dynamic>> friendshipQuestions = [];
  List<Map<String, dynamic>> romanticQuestions = []; // Correctly define the variable
  Map<String, String> updatedAnswers = {};
  bool hasUnsavedChanges = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await fetchQuestions();
      await fetchCurrentAnswers();
      setState(() => isLoading = false);
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchQuestions() async {
    try {
      QuerySnapshot questionSnapshot =
          await FirebaseFirestore.instance.collection('questions').get();

      List<Map<String, dynamic>> allQuestions = questionSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        friendshipQuestions = allQuestions
            .where((q) => q['category']?.toString().toLowerCase() == 'friendship')
            .toList();

        romanticQuestions = allQuestions
            .where((q) => q['category']?.toString().toLowerCase() == 'romantic')
            .toList();
      });

      print("Friendship Questions: $friendshipQuestions");
      print("Romantic Questions: $romanticQuestions");
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  Future<void> fetchCurrentAnswers() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        final questionnaireAnswers = data['questionnaireAnswers'] as Map<String, dynamic>? ?? {};

        setState(() {
          updatedAnswers = {
            ...questionnaireAnswers['friendship'] ?? {},
            ...questionnaireAnswers['romantic'] ?? {},
          };
        });
      }
    } catch (e) {
      print('Error fetching answers: $e');
    }
  }

  Future<void> saveAnswers() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final groupedAnswers = {
      'friendship': {
        for (var question in friendshipQuestions)
          question['question']: updatedAnswers[question['question']] ?? '',
      },
      'romantic': {
        for (var question in romanticQuestions)
          question['question']: updatedAnswers[question['question']] ?? '',
      },
    };

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'questionnaireAnswers': groupedAnswers},
        SetOptions(merge: true),
      );
      Get.snackbar("Success", "Answers updated successfully");
      Get.offAllNamed('/home');
    } catch (e) {
      print('Error saving answers: $e');
      Get.snackbar("Error", "Failed to save answers");
    }
  }

  Widget _buildQuestionCard(
      String questionText, List<String> options, Color color) {
    String selectedAnswer = updatedAnswers[questionText] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            children: options.map((option) {
              bool isSelected = selectedAnswer == option;

              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    updatedAnswers[questionText] =
                        selected ? option : ''; // Clear if deselected
                    hasUnsavedChanges = true;
                  });
                },
                selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[300],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[800] : Colors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool canSubmit() {
    int filledFriendshipAnswers = friendshipQuestions
        .where((q) => updatedAnswers[q['question']]?.isNotEmpty ?? false)
        .length;
    int filledRomanticAnswers = romanticQuestions
        .where((q) => updatedAnswers[q['question']]?.isNotEmpty ?? false)
        .length;

    return filledFriendshipAnswers >= 3 && filledRomanticAnswers >= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Questionnaire'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Friendship Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...friendshipQuestions.map((question) {
                  return _buildQuestionCard(
                    question['question'],
                    List<String>.from(question['options']),
                    Colors.blueGrey.shade100,
                  );
                }),
                const SizedBox(height: 20),
                const Text(
                  'Romantic Questions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ...romanticQuestions.map((question) {
                  return _buildQuestionCard(
                    question['question'],
                    List<String>.from(question['options']),
                    Colors.pinkAccent.shade100,
                  );
                }),
              ],
            ),
      floatingActionButton: hasUnsavedChanges && canSubmit()
          ? FloatingActionButton.extended(
              onPressed: saveAnswers,
              label: const Text('Save Answers'),
              icon: const Icon(Icons.save),
            )
          : null,
    );
  }
}
