import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionnaireService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   // Add a new question to the Firestore database if it doesn't already exist
  Future<void> createQuestion({
    required String category,
    required String question,
    required String type,
    required List<String> options,
  }) async {
    try {
      // Check if the question already exists
      final existingQuestion = await _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .where('question', isEqualTo: question)
          .limit(1)
          .get();

      if (existingQuestion.docs.isNotEmpty) {
        print('Question already exists in the database.');
        return; // Exit if the question already exists
      }

      // Add the new question if it doesn't exist
      await _firestore.collection('questions').add({
        'category': category,
        'question': question,
        'type': type,
        'options': options,
      });

      print('Question added successfully.');
    } catch (e) {
      print('Error adding question: $e');
    }
  }

  // Fetch questions by category (e.g., friendship, romantic)
  Future<List<Map<String, dynamic>>> fetchQuestions(String category) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // Fetch user's previous answers for all categories (e.g., friendship, romantic)
  Future<Map<String, Map<String, String>>> fetchUserAnswers(String userId) async {
    try {
      final responseSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('responses')
          .get();

      Map<String, Map<String, String>> answers = {};

      for (var doc in responseSnapshot.docs) {
        answers[doc.id] = Map<String, String>.from(doc.data());
      }

      return answers;
    } catch (e) {
      print('Error fetching user answers: $e');
      return {};
    }
  }


  // Save user's responses to Firestore
  Future<void> saveUserResponses({
    required String userId,
    required String category,
    required Map<String, String> responses,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('responses')
          .doc(category)
          .set(responses);
      print('User responses saved successfully');
    } catch (e) {
      print('Error saving user responses: $e');
    }
  }

  // Check if a user has answered a certain number of questions in each category
  Future<bool> hasAnsweredRequiredQuestions({
    required String userId,
    required int minQuestions,
  }) async {
    try {
      final friendshipDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('responses')
          .doc('friendship')
          .get();

      final romanticDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('responses')
          .doc('romantic')
          .get();

      bool hasFriendshipResponses = friendshipDoc.exists &&
          (friendshipDoc.data()?.length ?? 0) >= minQuestions;
      bool hasRomanticResponses = romanticDoc.exists &&
          (romanticDoc.data()?.length ?? 0) >= minQuestions;

      return hasFriendshipResponses && hasRomanticResponses;
    } catch (e) {
      print('Error checking required questions: $e');
      return false;
    }
  }

  Future<void> initializeDatabase(List<Map<String, dynamic>> questions) async {
  WriteBatch batch = _firestore.batch();

  try {
    for (var question in questions) {
      // Check if the question already exists
      final existingQuestion = await _firestore
          .collection('questions')
          .where('category', isEqualTo: question['category'])
          .where('question', isEqualTo: question['question'])
          .limit(1)
          .get();

      if (existingQuestion.docs.isEmpty) {
        // Add to the batch if the question doesn't exist
        final docRef = _firestore.collection('questions').doc();
        batch.set(docRef, question);
      }
    }

    await batch.commit();
    print('Database initialized with default questions.');
  } catch (e) {
    print('Error initializing database: $e');
  }
}


  // Get default list of questions
  List<Map<String, dynamic>> getDefaultQuestions() {
    return [
      // Friendship Questions
      {
        'category': 'friendship',
        'question': 'What kind of music do you listen to the most?',
        'type': 'multiple_choice',
        'options': [
          'A) Pop or mainstream',
          'B) Rock or alternative',
          'C) Hip-hop or R&B',
          'D) Indie or folk'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What’s more likely to make you laugh?',
        'type': 'multiple_choice',
        'options': [
          'A) Clever wordplay or puns',
          'B) Slapstick or physical comedy',
          'C) Sarcasm or witty banter',
          'D) Dark or dry humor'
        ],
      },
      {
        'category': 'friendship',
        'question': 'If you could live in any type of home, which would you choose?',
        'type': 'multiple_choice',
        'options': [
          'A) A city apartment',
          'B) A cozy cabin in the woods',
          'C) A beach house',
          'D) A suburban home'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What hobby do you enjoy the most?',
        'type': 'multiple_choice',
        'options': [
          'A) Playing sports or exercising',
          'B) Reading or writing',
          'C) Watching movies or TV shows',
          'D) Crafting or artistic activities'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What are you secretly proud of but don’t talk about much?',
        'type': 'multiple_choice',
        'options': [
          'A) A skill or talent you’ve mastered',
          'B) A kind gesture you did for someone',
          'C) Something you’ve achieved against the odds',
          'D) Your sense of humor or ability to make people laugh'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What do you dream about doing one day but haven’t had the chance yet?',
        'type': 'multiple_choice',
        'options': [
          'A) Traveling to a dream destination',
          'B) Starting a new hobby or learning a new skill',
          'C) Taking a big career leap',
          'D) Doing something adventurous like skydiving or road-tripping'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What kind of adventure would you be most excited to go on?',
        'type': 'multiple_choice',
        'options': [
          'A) A solo backpacking trip',
          'B) A cross-country road trip with friends',
          'C) A cultural exploration in a new city or country',
          'D) An adventurous outdoor activity, like hiking or rock climbing'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What do you value the most in a friendship?',
        'type': 'multiple_choice',
        'options': [
          'A) Loyalty',
          'B) Having fun together',
          'C) Being there when things get tough',
          'D) Sharing common interests or values'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What’s your go-to method for cheering yourself up when you’re feeling down?',
        'type': 'multiple_choice',
        'options': [
          'A) Watching a favorite movie or TV show',
          'B) Calling or texting a close friend',
          'C) Going for a walk or getting some fresh air',
          'D) Treating yourself to your favorite snack or drink'
        ],
      },
      {
        'category': 'friendship',
        'question': 'What quirky or random skill do you have that not many people know about?',
        'type': 'multiple_choice',
        'options': [
          'A) You can do a cool party trick (e.g., juggling or magic)',
          'B) You’re amazing at solving puzzles',
          'C) You can cook or bake something really specific and delicious',
          'D) You’re secretly great at impersonations or accents'
        ],
      },
      // Romantic Questions
      {
        'category': 'romantic',
        'question': 'What quality in a partner do you admire the most?',
        'type': 'multiple_choice',
        'options': [
          'A) Emotional support',
          'B) A sense of humor',
          'C) Ambition and drive',
          'D) Being open and communicative'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What’s something you’re afraid of in relationships?',
        'type': 'multiple_choice',
        'options': [
          'A) Losing emotional connection',
          'B) Being misunderstood',
          'C) Getting too comfortable or complacent',
          'D) Moving too fast or too slow'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What kind of date would you find most exciting?',
        'type': 'multiple_choice',
        'options': [
          'A) A romantic dinner',
          'B) An outdoor adventure, like hiking or biking',
          'C) A fun, spontaneous activity like a concert or festival',
          'D) A laid-back evening cooking or watching a movie at home'
        ],
      },
      {
        'category': 'romantic',
        'question': 'How do you prefer to show affection in a relationship?',
        'type': 'multiple_choice',
        'options': [
          'A) Physical touch (holding hands, hugging, etc.)',
          'B) Words of affirmation (compliments, sweet messages)',
          'C) Acts of service (doing thoughtful things for your partner)',
          'D) Giving small, meaningful gifts'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What would be your ideal way to spend a lazy weekend with your partner?',
        'type': 'multiple_choice',
        'options': [
          'A) Staying in and binge-watching movies or shows',
          'B) Going on a relaxing walk or exploring somewhere new',
          'C) Cooking or baking together',
          'D) Having a spontaneous, fun day with no set plans'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What would make you feel most appreciated in a relationship?',
        'type': 'multiple_choice',
        'options': [
          'A) Compliments and kind words',
          'B) Quality time together',
          'C) Doing something thoughtful for you',
          'D) Physical affection or touch'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What small gesture would you do to make your partner’s day better?',
        'type': 'multiple_choice',
        'options': [
          'A) Surprise them with their favorite snack',
          'B) Send a sweet message or call',
          'C) Plan a fun evening together',
          'D) Help with something they’ve been stressed about'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What do you choose for a fun couple’s activity?',
        'type': 'multiple_choice',
        'options': [
          'A) Going to a comedy show or concert',
          'B) Cooking a new recipe together',
          'C) Taking a weekend road trip',
          'D) Doing something adventurous like rock climbing or paddle boarding'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What fear do you want to conquer one day?',
        'type': 'multiple_choice',
        'options': [
          'A) Public speaking',
          'B) Trying something adventurous like skydiving',
          'C) Traveling to an unfamiliar place alone',
          'D) Expressing deeper emotions or vulnerability'
        ],
      },
      {
        'category': 'romantic',
        'question': 'What’s the most meaningful compliment or gesture a partner could give you?',
        'type': 'multiple_choice',
        'options': [
          'A) Complimenting your personality or character',
          'B) Telling you how much they appreciate something you’ve done',
          'C) Writing you a thoughtful note or letter',
          'D) Giving you their full attention during a conversation'
        ],
      },
    ];
  }
}

// Main function to initialize the database
Future<void> main() async {
  final questionnaireService = QuestionnaireService();

  // Fetch default questions from the service
  List<Map<String, dynamic>> defaultQuestions = questionnaireService.getDefaultQuestions();

  // Initialize the Firestore database with the default questions
  await questionnaireService.initializeDatabase(defaultQuestions);
}
