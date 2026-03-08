import 'package:flutter/material.dart';
// ignore: unused_import
import 'dart:math';
import '../models/user_progress.dart'; // تأكد من صحة المسار
import '../services/api_service.dart';  // تأكد من صحة المسار

class DailyChallengePage extends StatefulWidget {
  final int userId; // المعرّف الخاص بالمستخدم

  const DailyChallengePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  int currentQuestionIndex = 0;
  int score = 0;
  int stars = 0;
  List<ChallengeQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    List<ChallengeQuestion> allQuestions = [
      ChallengeQuestion(
        type: QuestionType.alphabet,
        question: 'Which letter comes after A?',
        options: ['B', 'C', 'D', 'E'],
        correctAnswer: 'B',
        emoji: '🔤',
      ),
      ChallengeQuestion(
        type: QuestionType.alphabet,
        question: 'Which letter does "Apple" start with?',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        emoji: '🍎',
      ),
      ChallengeQuestion(
        type: QuestionType.number,
        question: 'What is 2 + 3?',
        options: ['4', '5', '6', '7'],
        correctAnswer: '5',
        emoji: '🔢',
      ),
      ChallengeQuestion(
        type: QuestionType.number,
        question: 'Count the stars: ⭐⭐⭐',
        options: ['2', '3', '4', '5'],
        correctAnswer: '3',
        emoji: '⭐',
      ),
      ChallengeQuestion(
        type: QuestionType.color,
        question: 'What color is the sun?',
        options: ['Red', 'Blue', 'Yellow', 'Green'],
        correctAnswer: 'Yellow',
        emoji: '☀️',
      ),
      ChallengeQuestion(
        type: QuestionType.color,
        question: 'What color is grass?',
        options: ['Red', 'Blue', 'Yellow', 'Green'],
        correctAnswer: 'Green',
        emoji: '🌱',
      ),
      ChallengeQuestion(
        type: QuestionType.shape,
        question: 'What shape is a ball?',
        options: ['Circle', 'Square', 'Triangle', 'Star'],
        correctAnswer: 'Circle',
        emoji: '⚽',
      ),
      ChallengeQuestion(
        type: QuestionType.shape,
        question: 'How many sides does a triangle have?',
        options: ['2', '3', '4', '5'],
        correctAnswer: '3',
        emoji: '🔺',
      ),
      ChallengeQuestion(
        type: QuestionType.mirrorLetter,
        question: 'Which letter is this?',
        options: ['b', 'd', 'p', 'q'],
        correctAnswer: 'b',
        emoji: 'b',
      ),
      ChallengeQuestion(
        type: QuestionType.mirrorLetter,
        question: 'Which letter is this?',
        options: ['b', 'd', 'p', 'q'],
        correctAnswer: 'd',
        emoji: 'd',
      ),
    ];
    allQuestions.shuffle();
    setState(() {
      questions = allQuestions.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = currentQuestionIndex >= questions.length;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.pink.shade100,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: isComplete ? _buildCompletionScreen() : _buildQuestionScreen(),
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = questions[currentQuestionIndex];
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildProgress(),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(question.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 15),
            const Text(
              'Daily Challenge',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildQuestionCard(question),
                const SizedBox(height: 40),
                _buildAnswerOptions(question),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Question ${currentQuestionIndex + 1} of ${questions.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ChallengeQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(question.emoji, style: TextStyle(
            fontSize: question.type == QuestionType.mirrorLetter ? 120 : 60,
            fontWeight: question.type == QuestionType.mirrorLetter ? FontWeight.w900 : FontWeight.normal,
            color: question.type == QuestionType.mirrorLetter ? Colors.purple.shade700 : null,
          )),
          const SizedBox(height: 20),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(ChallengeQuestion question) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children: question.options.map((option) {
        return GestureDetector(
          onTap: () => _checkAnswer(option, question.correctAnswer),
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getColorForType(question.type).shade300,
                  _getColorForType(question.type).shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  MaterialColor _getColorForType(QuestionType type) {
    switch (type) {
      case QuestionType.alphabet:
        return Colors.purple;
      case QuestionType.number:
        return Colors.blue;
      case QuestionType.color:
        return Colors.pink;
      case QuestionType.shape:
        return Colors.orange;
      case QuestionType.mirrorLetter:
        return Colors.purple;
    }
  }

  // دالة الإجابة - تم تعديلها لتصبح async وتستخدم _awardPoints
  void _checkAnswer(String answer, String correctAnswer) async {
    bool isCorrect = answer == correctAnswer;
    if (isCorrect) {
      setState(() {
        score += 20;
        stars++;
      });

      // حفظ النقاط محلياً وعلى السيرفر
      await _awardPoints(20, 'Daily Challenge');

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                '🎉 Correct! +20 points!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Try again! Correct answer: $correctAnswer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Future.delayed(Duration(seconds: isCorrect ? 1 : 2), () {
      setState(() {
        currentQuestionIndex++;
      });
    });
  }

  // دالة مساعدة لحفظ النقاط محلياً وعلى السيرفر
  Future<void> _awardPoints(int points, String gameName) async {
    // حفظ محلي (اختياري حسب هيكلة مشروعك)
    await UserProgress.addScore(points);

    // حفظ على السيرفر عبر ApiService
    await ApiService.saveGameSession(
      userId: widget.userId,
      gameName: gameName,
      pointsEarned: points,
    );
  }

  Widget _buildCompletionScreen() {
    // تسجيل الجلسة عند الانتهاء (اختياري، النقاط سُجلت بالفعل)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (score > 0) {
        await ApiService.saveGameSession(
          userId: widget.userId,
          gameName: 'Daily Challenge - Complete',
          pointsEarned: 0,
        );
      }
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 100)),
            const SizedBox(height: 30),
            const Text(
              'Challenge Complete!',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 40),
                      const SizedBox(width: 15),
                      Text(
                        '$stars / ${questions.length} Stars',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Total Score: $score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex = 0;
                      score = 0;
                      stars = 0;
                      _generateQuestions();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum QuestionType { alphabet, number, color, shape, mirrorLetter }

class ChallengeQuestion {
  final QuestionType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String emoji;

  ChallengeQuestion({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.emoji,
  });
}