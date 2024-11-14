import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_new_app/models/questionnaire_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_new_app/newUserScreens/mbti_selection_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  List<Map<String, dynamic>> friendshipQuestions = [];
  List<Map<String, dynamic>> romanticQuestions = [];

  Map<String, String> selectedFriendshipAnswers = {};
  Map<String, String> selectedRomanticAnswers = {};

  bool isLoading = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    loadQuestionsAndAnswers(); // Load both questions and user answers
  }

  Future<void> loadQuestionsAndAnswers() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Fetch friendship and romantic questions
      friendshipQuestions = await _questionnaireService.fetchQuestions('friendship');
      romanticQuestions = await _questionnaireService.fetchQuestions('romantic');

      // Fetch existing user answers
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userAnswers = await _questionnaireService.fetchUserAnswers(userId);
        selectedFriendshipAnswers = Map<String, String>.from(userAnswers['friendship'] ?? {});
        selectedRomanticAnswers = Map<String, String>.from(userAnswers['romantic'] ?? {});
      }

      // Ensure no duplicate questions
      friendshipQuestions = friendshipQuestions.toSet().toList();
      romanticQuestions = romanticQuestions.toSet().toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> submitAnswers() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId != null) {
    try {
      // Group answers by category
      final Map<String, dynamic> allAnswers = {
        'friendship': selectedFriendshipAnswers,
        'romantic': selectedRomanticAnswers,
      };

      // Save the grouped answers under 'questionnaireAnswers'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
        {'questionnaireAnswers': allAnswers},
        SetOptions(merge: true), // Prevent overwriting other user data
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answers submitted successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MbtiSelectionScreen()),
      );
    } catch (e) {
      print('Error saving answers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving answers')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error loading questions. Please try again.'),
                      ElevatedButton(
                        onPressed: loadQuestionsAndAnswers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSectionHeader('Friendship Questions', Colors.blueGrey),
                      ...buildQuestionList(friendshipQuestions, selectedFriendshipAnswers),
                      const SizedBox(height: 20),
                      buildSectionHeader('Romantic Questions', Colors.pinkAccent),
                      ...buildQuestionList(romanticQuestions, selectedRomanticAnswers),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: canSubmit() ? submitAnswers : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text(
                            'Submit Answers',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> buildQuestionList(
      List<Map<String, dynamic>> questions, Map<String, String> selectedAnswers) {
    return questions.map((question) {
      final String questionText = question['question'];
      final List<String> options = List<String>.from(question['options']);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...options.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswers[questionText],
                onChanged: (String? value) {
                  setState(() {
                    selectedAnswers[questionText] = value!;
                  });
                },
              );
            }),
          ],
        ),
      );
    }).toList();
  }

  bool canSubmit() {
    return selectedFriendshipAnswers.length >= 3 &&
        selectedRomanticAnswers.length >= 3;
  }
}
