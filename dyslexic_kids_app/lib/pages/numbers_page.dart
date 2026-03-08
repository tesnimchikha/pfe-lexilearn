import 'package:flutter/material.dart';
import 'dart:math';
import '../models/user_progress.dart';
import '../services/api_service.dart';

// ==================== SHARED POINTS HELPER ====================
Future<void> _awardNumberPoints({
  required int points,
  required int userId,
  required BuildContext context,
}) async {
  await UserProgress.addScore(points);
  await ApiService.saveGameSession(
    userId: userId,
    gameName: 'Numbers - Counting',
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
                color: Colors.blue.shade400,
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

// ==================== NUMBERS PAGE ====================
class NumbersPageDyslexic extends StatefulWidget {
  final int userId;
  const NumbersPageDyslexic({Key? key, required this.userId}) : super(key: key);

  @override
  State<NumbersPageDyslexic> createState() => _NumbersPageDyslexicState();
}

class _NumbersPageDyslexicState extends State<NumbersPageDyslexic> {
  int targetCount = 0;
  int score = 0;
  List<bool> selectedObjects = [];
  final Color backgroundColor = const Color(0xFFFAF8F3);
  final Color accentColor = const Color(0xFF6B9BD1);

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      targetCount = Random().nextInt(5) + 3;
      int totalObjects = targetCount + Random().nextInt(3) + 1;
      selectedObjects = List.filled(totalObjects, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedCount = selectedObjects.where((s) => s).length;
    bool isCorrect = selectedCount == targetCount;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            _buildScore(),
            const SizedBox(height: 20),
            Text(
              'Select exactly $targetCount objects!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: accentColor,
                fontFamily: 'OpenDyslexic',
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.yellow.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.shade700, width: 3),
              ),
              child: Text(
                '$targetCount',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Selected: $selectedCount',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildObjectsGrid(),
              ),
            ),
            if (isCorrect) ...[
              const SizedBox(height: 10),
              _buildCheckButton(),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: const Text(
              '🔢 Numbers',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.star, color: Colors.amber, size: 28),
      const SizedBox(width: 10),
      Text('$score', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor)),
    ]),
  );

  Widget _buildObjectsGrid() => Wrap(
    spacing: 15,
    runSpacing: 15,
    alignment: WrapAlignment.center,
    children: List.generate(
      selectedObjects.length,
      (index) => GestureDetector(
        onTap: () => setState(() => selectedObjects[index] = !selectedObjects[index]),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: selectedObjects[index] ? Colors.green.shade300 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selectedObjects[index] ? Colors.green : Colors.grey,
              width: 3,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Icon(
            selectedObjects[index] ? Icons.check : Icons.circle,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    ),
  );

  Widget _buildCheckButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ElevatedButton(
      onPressed: () {
        setState(() => score += 20);
        _awardNumberPoints(points: 20, userId: widget.userId, context: context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Perfect count!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(seconds: 2), _generateQuestion);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: const Text(
        '✓ Check Answer',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
  );
}