import 'package:flutter/material.dart';
import 'dart:math';
import '../models/user_progress.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class MathematicsPage extends StatefulWidget {
  final int userId;
  const MathematicsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MathematicsPage> createState() => _MathematicsPageState();
}

class _MathematicsPageState extends State<MathematicsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.yellow.shade50, Colors.green.shade50, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              const Text('🔢 Mathématique',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.green)),
              const SizedBox(height: 20),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AdditionTab(userId: widget.userId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(children: [
        IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: () => Navigator.pop(context)),
        const SizedBox(width: 10),
        const Text('Mathematics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.add), text: 'Addition'),
        ],
      ),
    );
  }
}

// ==================== SHARED POINTS HELPER ====================
Future<void> _awardMathPoints({
  required int points,
  required String subGame,
  required int userId,
  required BuildContext context,
  NotificationService? notif,
}) async {
  final result = await UserProgress.addScore(points);
  if (result['leveledUp'] == true) {
    notif?.showLevelUpNotification(result['level']);
  }
  await ApiService.saveGameSession(
    userId: userId,
    gameName: 'Mathematics - $subGame',
    pointsEarned: points,
  );
  _showPointsAnim(points, context);
}

void _showPointsAnim(int points, BuildContext context) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (ctx) => Positioned(
      top: MediaQuery.of(ctx).size.height * 0.3,
      left: MediaQuery.of(ctx).size.width * 0.5 - 50,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween(begin: 0.0, end: 1.0),
        onEnd: () { entry?.remove(); entry = null; },
        builder: (ctx, value, child) => Transform.translate(
          offset: Offset(0, -100 * value),
          child: Opacity(
            opacity: 1.0 - value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Text('+$points',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry!);
}

// ==================== ADDITION TAB ====================
class AdditionTab extends StatefulWidget {
  final int userId;
  const AdditionTab({Key? key, required this.userId}) : super(key: key);
  @override
  State<AdditionTab> createState() => _AdditionTabState();
}

class _AdditionTabState extends State<AdditionTab> {
  int number1 = 0, number2 = 0, correctAnswer = 0;
  int? userAnswer;
  int score = 0;
  final NotificationService _notificationService = NotificationService();
  List<int> answerOptions = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      number1 = Random().nextInt(5) + 1;
      number2 = Random().nextInt(5) + 1;
      correctAnswer = number1 + number2;
      userAnswer = null;
      answerOptions = [correctAnswer];
      while (answerOptions.length < 3) {
        int option = Random().nextInt(10) + 1;
        if (!answerOptions.contains(option)) answerOptions.add(option);
      }
      answerOptions.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 20),
        _buildScore(),
        const SizedBox(height: 30),
        const Text('Add the numbers!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 30),
        _buildVisualAddition(),
        const SizedBox(height: 30),
        _buildEquation(),
        const SizedBox(height: 40),
        _buildAnswerOptions(),
      ]),
    );
  }

  Widget _buildScore() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star, color: Colors.amber, size: 24),
      const SizedBox(width: 8),
      Text('Score: $score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );

  Widget _buildVisualAddition() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _buildObjectGroup(number1, Colors.red.shade300),
      const Text('+', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
      _buildObjectGroup(number2, Colors.blue.shade300),
    ]),
  );

  Widget _buildObjectGroup(int count, Color color) => Wrap(
    spacing: 8, runSpacing: 8,
    children: List.generate(count, (i) => Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: const Icon(Icons.circle, color: Colors.white, size: 20),
    )),
  );

  Widget _buildEquation() => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.yellow.shade100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.yellow.shade700, width: 3),
    ),
    child: Text('$number1 + $number2 = ?',
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.green)),
  );

  Widget _buildAnswerOptions() => Wrap(
    spacing: 15, runSpacing: 15, alignment: WrapAlignment.center,
    children: answerOptions.map((option) {
      bool isSelected = userAnswer == option;
      bool isCorrect = option == correctAnswer && userAnswer == option;
      bool isWrong = userAnswer == option && option != correctAnswer;
      return GestureDetector(
        onTap: userAnswer != null ? null : () => _checkAnswer(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green : (isWrong ? Colors.red : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: isSelected ? 3 : 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Center(
            child: Text('$option',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.green)),
          ),
        ),
      );
    }).toList(),
  );

  void _checkAnswer(int answer) {
    setState(() => userAnswer = answer);
    if (answer == correctAnswer) {
      setState(() => score += 20);
      _awardMathPoints(points: 20, subGame: 'Addition', userId: widget.userId, context: context, notif: _notificationService);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Correct! Great job!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
      Future.delayed(const Duration(seconds: 2), _generateQuestion);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🤔 Try again!'), backgroundColor: Colors.red, duration: Duration(seconds: 1)));
      Future.delayed(const Duration(seconds: 2), () => setState(() => userAnswer = null));
    }
  }
}