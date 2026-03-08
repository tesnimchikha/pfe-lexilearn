import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';
import 'dart:math';

// ============================================================
// SHARED POINTS HELPER
// ============================================================
Future<void> _awardPuzzlePoints(int points, {required int userId}) async {
  await UserProgress.addScore(points);
  await ApiService.saveGameSession(
    userId: userId,
    gameName: 'Puzzles - Son Initial',
    pointsEarned: points,
  );
}

// ============================================================
// PuzzleGamesPage → va directement au jeu Son Initial
// ============================================================
class PuzzleGamesPage extends StatelessWidget {
  final int userId;
  const PuzzleGamesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InitialSoundGame(userId: userId);
  }
}

// ============================================================
// INITIAL SOUND GAME
// Cible dyslexie : conscience phonologique (5-8 ans)
// L'enfant voit une image et choisit la lettre du son initial
// Ex: 🐱 → C   🍎 → A   🐬 → D
// ============================================================
class InitialSoundGame extends StatefulWidget {
  final int userId;
  const InitialSoundGame({Key? key, required this.userId}) : super(key: key);
  @override
  State<InitialSoundGame> createState() => _InitialSoundGameState();
}

class _InitialSoundGameState extends State<InitialSoundGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // Questions : image emoji + mot + lettre correcte + 3 distracteurs
  final List<Map<String, dynamic>> _allQuestions = [
    {
      'emoji': '🍎',
      'word': 'Apple',
      'correct': 'A',
      'wrong': ['B', 'D', 'P']
    },
    {
      'emoji': '🦋',
      'word': 'Butterfly',
      'correct': 'B',
      'wrong': ['D', 'P', 'Q']
    },
    {
      'emoji': '🐱',
      'word': 'Cat',
      'correct': 'C',
      'wrong': ['K', 'G', 'S']
    },
    {
      'emoji': '🐬',
      'word': 'Dolphin',
      'correct': 'D',
      'wrong': ['B', 'P', 'T']
    },
    {
      'emoji': '🐘',
      'word': 'Elephant',
      'correct': 'E',
      'wrong': ['A', 'I', 'O']
    },
    {
      'emoji': '🐸',
      'word': 'Frog',
      'correct': 'F',
      'wrong': ['V', 'B', 'P']
    },
    {
      'emoji': '🦒',
      'word': 'Giraffe',
      'correct': 'G',
      'wrong': ['J', 'C', 'D']
    },
    {
      'emoji': '🌺',
      'word': 'Hibiscus',
      'correct': 'H',
      'wrong': ['A', 'E', 'N']
    },
    {
      'emoji': '🦁',
      'word': 'Lion',
      'correct': 'L',
      'wrong': ['R', 'N', 'M']
    },
    {
      'emoji': '🌙',
      'word': 'Moon',
      'correct': 'M',
      'wrong': ['N', 'W', 'B']
    },
    {
      'emoji': '🎵',
      'word': 'Note',
      'correct': 'N',
      'wrong': ['M', 'U', 'H']
    },
    {
      'emoji': '🐧',
      'word': 'Penguin',
      'correct': 'P',
      'wrong': ['B', 'D', 'Q']
    },
    {
      'emoji': '👑',
      'word': 'Queen',
      'correct': 'Q',
      'wrong': ['P', 'B', 'D']
    },
    {
      'emoji': '🌈',
      'word': 'Rainbow',
      'correct': 'R',
      'wrong': ['L', 'N', 'W']
    },
    {
      'emoji': '⭐',
      'word': 'Star',
      'correct': 'S',
      'wrong': ['C', 'Z', 'T']
    },
    {
      'emoji': '🐯',
      'word': 'Tiger',
      'correct': 'T',
      'wrong': ['D', 'P', 'B']
    },
    {
      'emoji': '☂️',
      'word': 'Umbrella',
      'correct': 'U',
      'wrong': ['A', 'O', 'N']
    },
    {
      'emoji': '🌋',
      'word': 'Volcano',
      'correct': 'V',
      'wrong': ['W', 'F', 'B']
    },
    {
      'emoji': '🐺',
      'word': 'Wolf',
      'correct': 'W',
      'wrong': ['V', 'M', 'N']
    },
    {
      'emoji': '🦓',
      'word': 'Zebra',
      'correct': 'Z',
      'wrong': ['S', 'X', 'C']
    },
  ];

  late List<Map<String, dynamic>> _questions;
  late List<String> _options;
  int _currentIndex = 0;
  int _score = 0;
  int _totalPoints = 0;
  String? _selected;
  bool _answered = false;
  bool _gameOver = false;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.45);
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
    _initGame();
  }

  void _initGame() {
    _questions = List.from(_allQuestions)..shuffle();
    _questions = _questions.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _totalPoints = 0;
    _gameOver = false;
    _loadQuestion();
  }

  void _loadQuestion() {
    final q = _questions[_currentIndex];
    final List<String> opts = [q['correct'], ...q['wrong']];
    opts.shuffle();
    setState(() {
      _options = opts;
      _selected = null;
      _answered = false;
    });
  }

  Future<void> _speak(String word) => _tts.speak(word);

  Future<void> _answer(String letter) async {
    if (_answered) return;
    final correct = _questions[_currentIndex]['correct'];
    final word = _questions[_currentIndex]['word'];
    setState(() {
      _selected = letter;
      _answered = true;
    });

    if (letter == correct) {
      _score++;
      _totalPoints += 20;
      await _awardPuzzlePoints(20, userId: widget.userId);
      await _tts.speak("$word starts with $letter. Correct!");
    } else {
      _shakeCtrl.forward(from: 0);
      await _tts.speak("$word starts with $correct");
    }

    await Future.delayed(const Duration(seconds: 2));

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _loadQuestion();
    } else {
      setState(() => _gameOver = true);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _buildEndScreen();

    final q = _questions[_currentIndex];
    final cor = q['correct'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
          child: Column(children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () => Navigator.pop(context)),
            ),
            const Spacer(),
            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text('+$_totalPoints',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ]),
            ),
          ]),
        ),

        // ── Progress bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.orange.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 6),
            Text('${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Question card ──
        GestureDetector(
          onTap: () => _speak(q['word']),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(children: [
              Text(q['emoji'], style: const TextStyle(fontSize: 90)),
              const SizedBox(height: 14),
              const Text('Which letter does this word start with?',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.volume_up, color: Colors.orange.shade400, size: 20),
                const SizedBox(width: 6),
                Text(' Tap to hear the word',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade400,
                        fontStyle: FontStyle.italic)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 30),

        // ── Answer options ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
            children: _options.map((letter) {
              Color bgColor = Colors.white;
              Color textColor = Colors.grey.shade800;
              Color borderColor = Colors.grey.shade200;

              if (_answered) {
                if (letter == cor) {
                  bgColor = Colors.green.shade400;
                  textColor = Colors.white;
                  borderColor = Colors.green.shade400;
                } else if (letter == _selected) {
                  bgColor = Colors.red.shade400;
                  textColor = Colors.white;
                  borderColor = Colors.red.shade400;
                }
              }

              return GestureDetector(
                onTap: () => _answer(letter),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (ctx, child) {
                    double shake =
                        (letter == _selected && _answered && letter != cor)
                            ? sin(_shakeAnim.value * pi * 6) * 8
                            : 0;
                    return Transform.translate(
                      offset: Offset(shake, 0),
                      child: child,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Text(letter,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: textColor)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ])),
    );
  }

  Widget _buildEndScreen() => Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                  _score >= 8
                      ? '🏆'
                      : _score >= 5
                          ? '⭐'
                          : '💪',
                  style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Text(
                _score >= 8
                    ? 'Excellent !'
                    : _score >= 5
                        ? 'good job!'
                        : 'Continue !',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4F46E5)),
              ),
              const SizedBox(height: 12),
              Text('$_score / ${_questions.length} bonnes réponses',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text('⭐ +$_totalPoints points gagnés !',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _initGame());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Rejouer', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Accueil', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      );
}
