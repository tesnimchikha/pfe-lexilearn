import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════
// ColorsPage — "Color the Letter" Game
// For dyslexic children aged 5–8
// TTS says "Color the A in RED!" → child taps the correct color
// Teaches: colors + letter recognition simultaneously
// ═══════════════════════════════════════════════════════════

class PaintGamesPage extends StatefulWidget {
  final int userId;
  const PaintGamesPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PaintGamesPage> createState() => _PaintGamesPageState();
}

class _PaintGamesPageState extends State<PaintGamesPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // All color options
  final List<_ColorOption> _allColors = [
    _ColorOption(name: 'Red',    color: const Color(0xFFE53935)),
    _ColorOption(name: 'Blue',   color: const Color(0xFF1E88E5)),
    _ColorOption(name: 'Yellow', color: const Color(0xFFFDD835)),
    _ColorOption(name: 'Green',  color: const Color(0xFF43A047)),
    _ColorOption(name: 'Orange', color: const Color(0xFFFB8C00)),
    _ColorOption(name: 'Purple', color: const Color(0xFF8E24AA)),
    _ColorOption(name: 'Pink',   color: const Color(0xFFE91E8C)),
    _ColorOption(name: 'Brown',  color: const Color(0xFF6D4C41)),
  ];

  // All letters A–Z
  final List<String> _allLetters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  Color? _selectedColor;
  Color? _letterColor;       // current fill of the letter
  bool _answered = false;
  bool _gameOver = false;
  bool _isSpeaking = false;

  // 4 color choices shown per question
  late List<_ColorOption> _choices;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.40);
    _tts.setPitch(1.1);

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _initGame();
  }

  // ─────────── Game Logic ───────────

  void _initGame() {
    // Build 10 random questions: each = a letter + a target color
    final letters = List<String>.from(_allLetters)..shuffle();
    final questions = <Map<String, dynamic>>[];

    for (int i = 0; i < 10; i++) {
      final letter = letters[i % letters.length];
      final colorsCopy = List<_ColorOption>.from(_allColors)..shuffle();
      final correctColor = colorsCopy.first;
      final wrongColors = colorsCopy.skip(1).take(3).toList();
      questions.add({
        'letter': letter,
        'correctColor': correctColor,
        'wrongColors': wrongColors,
      });
    }

    setState(() {
      _questions = questions;
      _currentIndex = 0;
      _score = 0;
      _correctCount = 0;
      _gameOver = false;
    });
    _loadQuestion();
  }

  void _loadQuestion() {
    final q = _questions[_currentIndex];
    final correct = q['correctColor'] as _ColorOption;
    final wrong = q['wrongColors'] as List<_ColorOption>;
    final choices = [correct, ...wrong]..shuffle();

    setState(() {
      _choices = choices;
      _selectedColor = null;
      _letterColor = Colors.white; // start white/uncolored
      _answered = false;
    });

    // TTS reads the instruction after short delay
    Future.delayed(const Duration(milliseconds: 500), _speakInstruction);
  }

  Future<void> _speakInstruction() async {
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    final q = _questions[_currentIndex];
    final letter = q['letter'] as String;
    final color = (q['correctColor'] as _ColorOption).name;
    await _tts.speak("Color the letter $letter in $color!");
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _onColorTap(_ColorOption tapped) async {
    if (_answered) return;
    final correct = _questions[_currentIndex]['correctColor'] as _ColorOption;
    final letter = _questions[_currentIndex]['letter'] as String;

    setState(() {
      _selectedColor = tapped.color;
      _letterColor = tapped.color; // always fill letter with tapped color
      _answered = true;
    });

    if (tapped.name == correct.name) {
      _correctCount++;
      _score += 20;
      _bounceCtrl.forward(from: 0);
      await _tts.speak("${tapped.name}! The letter $letter is ${tapped.name}. Well done!");
      await _awardPoints(20);
    } else {
      await _tts.speak("Try again! Color the letter $letter in ${correct.name}!");
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _loadQuestion();
    } else {
      setState(() => _gameOver = true);
    }
  }

  Future<void> _awardPoints(int points) async {
    await UserProgress.addScore(points);
    await ApiService.saveGameSession(
      userId: widget.userId,
      gameName: 'Colors - Color the Letter',
      pointsEarned: points,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _bounceCtrl.dispose();
    super.dispose();
  }

  // ─────────── BUILD ───────────

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _buildEndScreen();
    final q = _questions[_currentIndex];
    final letter = q['letter'] as String;
    final correct = q['correctColor'] as _ColorOption;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildProgressBar(),
              const SizedBox(height: 16),
              _buildInstructionCard(letter, correct),
              const SizedBox(height: 20),
              _buildLetterDisplay(letter),
              const SizedBox(height: 24),
              const Text(
                'Pick the right color! 🎨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildColorGrid(correct)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '🎨 Color the Letter',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF333333)),
          ),
          const Spacer(),
          // Score badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                Text('$_score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.white.withOpacity(0.6),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_currentIndex + 1} of ${_questions.length}',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(String letter, _ColorOption correct) {
    return GestureDetector(
      onTap: _answered ? null : _speakInstruction,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.purple.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            // Speaker pulsing icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isSpeaking
                    ? Colors.purple.shade400
                    : Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSpeaking
                    ? Icons.volume_up
                    : Icons.volume_up_outlined,
                size: 24,
                color: _isSpeaking
                    ? Colors.white
                    : Colors.purple.shade300,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Color the letter...',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: letter,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF333333),
                            letterSpacing: 2,
                          ),
                        ),
                        const TextSpan(
                          text: '  in  ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: correct.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: correct.color,
                          ),
                        ),
                        const TextSpan(text: '!',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF333333))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.touch_app,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text('Tap to hear again',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterDisplay(String letter) {
    return AnimatedBuilder(
      animation: _bounceAnim,
      builder: (ctx, child) => Transform.scale(
        scale: _bounceAnim.value,
        child: child,
      ),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _letterColor == Colors.white
                ? Colors.grey.shade200
                : _letterColor!,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (_letterColor == Colors.white
                      ? Colors.grey
                      : _letterColor!)
                  .withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 110,
              fontWeight: FontWeight.w900,
              color: _letterColor == Colors.white
                  ? Colors.grey.shade200 // outline effect when uncolored
                  : _letterColor!,
              height: 1.0,
            ),
            child: Text(letter),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid(_ColorOption correct) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        shrinkWrap: true,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: _choices.map((colorOpt) {
          final isCorrect = colorOpt.name == correct.name;
          final isSelected = _selectedColor == colorOpt.color;

          // Border feedback after answering
          double borderWidth = 3;
          Color borderColor = colorOpt.color.withOpacity(0.3);

          if (_answered) {
            if (isCorrect) {
              borderColor = Colors.green;
              borderWidth = 4;
            } else if (isSelected) {
              borderColor = Colors.red;
              borderWidth = 4;
            }
          }

          return GestureDetector(
            onTap: () => _onColorTap(colorOpt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: colorOpt.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: [
                  BoxShadow(
                      color: colorOpt.color.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    colorOpt.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                  ),
                  if (_answered && isCorrect)
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  if (_answered && isSelected && !isCorrect)
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────── END SCREEN ───────────

  Widget _buildEndScreen() {
    String medal;
    String message;
    Color color;

    if (_correctCount >= 9) {
      medal = '🏆';
      message = 'Color master!';
      color = Colors.amber.shade600;
    } else if (_correctCount >= 7) {
      medal = '🌈';
      message = 'Colorful job!';
      color = Colors.purple.shade400;
    } else if (_correctCount >= 5) {
      medal = '🎨';
      message = 'Good colors!';
      color = Colors.blue.shade400;
    } else {
      medal = '💪';
      message = 'Keep painting!';
      color = Colors.orange.shade400;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(medal, style: const TextStyle(fontSize: 90)),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: color),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      children: [
                        // Color dots for answered questions (visual recap)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            _questions.length,
                            (i) {
                              final isCorrect = i < _correctCount;
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? (_questions[i]['correctColor']
                                              as _ColorOption)
                                          .color
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            Colors.black.withOpacity(0.1),
                                        blurRadius: 4)
                                  ],
                                ),
                                child: isCorrect
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 18)
                                    : const Icon(Icons.close,
                                        color: Colors.grey, size: 18),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '$_score points',
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _initGame()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Play Again',
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home),
                        label: const Text('Home',
                            style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────── Data class ───────────
class _ColorOption {
  final String name;
  final Color color;
  const _ColorOption({required this.name, required this.color});
}