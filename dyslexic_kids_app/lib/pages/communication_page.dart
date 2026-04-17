import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════
// CommunicationPage — "Listen & Find" Game
// For dyslexic children aged 5–8
// TTS speaks a word → child taps the correct image from 4 choices
// Uses real assets from assets/images/alphabets/
// ═══════════════════════════════════════════════════════════

class _Question {
  final String word;
  final String correctImage;
  final List<String> wrongImages;
  _Question({
    required this.word,
    required this.correctImage,
    required this.wrongImages,
  });
}

class CommunicationPage extends StatefulWidget {
  final int userId;
  const CommunicationPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  // All questions using real images from assets/images/alphabets/
  final List<_Question> _allQuestions = [
    _Question(word: 'Apple',    correctImage: 'apple.png',    wrongImages: ['banana.png', 'cat.png', 'dog.png']),
    _Question(word: 'Banana',   correctImage: 'banana.png',   wrongImages: ['apple.png', 'fish.png', 'hat.png']),
    _Question(word: 'Cat',      correctImage: 'cat.png',      wrongImages: ['dog.png', 'fish.png', 'lion.png']),
    _Question(word: 'Dog',      correctImage: 'dog.png',      wrongImages: ['cat.png', 'duck.png', 'horse.png']),
    _Question(word: 'Duck',     correctImage: 'duck.png',     wrongImages: ['dog.png', 'fish.png', 'frog.png']),
    _Question(word: 'Elephant', correctImage: 'elephant.png', wrongImages: ['horse.png', 'goat.png', 'lion.png']),
    _Question(word: 'Fish',     correctImage: 'fish.png',     wrongImages: ['frog.png', 'duck.png', 'cat.png']),
    _Question(word: 'Frog',     correctImage: 'frog.png',     wrongImages: ['fish.png', 'duck.png', 'goat.png']),
    _Question(word: 'Goat',     correctImage: 'goat.png',     wrongImages: ['horse.png', 'dog.png', 'lion.png']),
    _Question(word: 'Grapes',   correctImage: 'grapes.png',   wrongImages: ['apple.png', 'banana.png', 'orange.png']),
    _Question(word: 'Hat',      correctImage: 'hat.png',      wrongImages: ['key.png', 'kite.png', 'ring.png']),
    _Question(word: 'Horse',    correctImage: 'horse.png',    wrongImages: ['dog.png', 'goat.png', 'elephant.png']),
    _Question(word: 'Igloo',    correctImage: 'igloo.png',    wrongImages: ['ice.png', 'kite.png', 'hat.png']),
    _Question(word: 'Jam',      correctImage: 'jam.png',      wrongImages: ['juice.png', 'pizza.png', 'orange.png']),
    _Question(word: 'Kite',     correctImage: 'kite.png',     wrongImages: ['key.png', 'hat.png', 'star.png']),
    _Question(word: 'Key',      correctImage: 'key.png',      wrongImages: ['kite.png', 'ring.png', 'star.png']),
    _Question(word: 'Leaf',     correctImage: 'leaf.png',     wrongImages: ['tree.png', 'grapes.png', 'moon.png']),
    _Question(word: 'Lion',     correctImage: 'lion.png',     wrongImages: ['tiger.png', 'horse.png', 'goat.png']),
    _Question(word: 'Monkey',   correctImage: 'monkey.png',   wrongImages: ['lion.png', 'rabbit.png', 'goat.png']),
    _Question(word: 'Moon',     correctImage: 'moon.png',     wrongImages: ['sun.png', 'star.png', 'leaf.png']),
    _Question(word: 'Orange',   correctImage: 'orange.png',   wrongImages: ['apple.png', 'banana.png', 'grapes.png']),
    _Question(word: 'Owl',      correctImage: 'owl.png',      wrongImages: ['duck.png', 'frog.png', 'rabbit.png']),
    _Question(word: 'Pizza',    correctImage: 'pizza.png',    wrongImages: ['jam.png', 'orange.png', 'egg.png']),
    _Question(word: 'Rabbit',   correctImage: 'rabbit.png',   wrongImages: ['monkey.png', 'cat.png', 'duck.png']),
    _Question(word: 'Ring',     correctImage: 'ring.png',     wrongImages: ['key.png', 'hat.png', 'star.png']),
    _Question(word: 'Star',     correctImage: 'star.png',     wrongImages: ['sun.png', 'moon.png', 'ring.png']),
    _Question(word: 'Sun',      correctImage: 'sun.png',      wrongImages: ['star.png', 'moon.png', 'tree.png']),
    _Question(word: 'Tiger',    correctImage: 'tiger.png',    wrongImages: ['lion.png', 'horse.png', 'dog.png']),
    _Question(word: 'Tree',     correctImage: 'tree.png',     wrongImages: ['leaf.png', 'grapes.png', 'umbrella.png']),
    _Question(word: 'Umbrella', correctImage: 'umbrella.png', wrongImages: ['unicorn.png', 'van.png', 'kite.png']),
    _Question(word: 'Violin',   correctImage: 'violin.png',   wrongImages: ['van.png', 'watch.png', 'key.png']),
    _Question(word: 'Whale',    correctImage: 'whale.png',    wrongImages: ['fish.png', 'frog.png', 'duck.png']),
    _Question(word: 'Zebra',    correctImage: 'zebra.png',    wrongImages: ['tiger.png', 'horse.png', 'lion.png']),
  ];

  late List<_Question> _questions;
  late List<String> _options;

  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  String? _selected;
  bool _answered = false;
  bool _gameOver = false;
  bool _isSpeaking = false;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  static String _imgPath(String filename) =>
      'assets/images/alphabets/$filename';

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.38);
    _tts.setPitch(1.1);

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
    );

    _initGame();
  }

  void _initGame() {
    final shuffled = List<_Question>.from(_allQuestions)..shuffle();
    _questions = shuffled.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _correctCount = 0;
    _gameOver = false;
    _loadQuestion();
  }

  void _loadQuestion() {
    final q = _questions[_currentIndex];
    final opts = [q.correctImage, ...q.wrongImages]..shuffle();
    setState(() {
      _options = opts;
      _selected = null;
      _answered = false;
    });
    Future.delayed(const Duration(milliseconds: 600), _speakWord);
  }

  Future<void> _speakWord() async {
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    await _tts.speak("Find... ${_questions[_currentIndex].word}");
    if (mounted) setState(() => _isSpeaking = false);
  }

  Future<void> _onTap(String imgFile) async {
    if (_answered) return;
    final correct = _questions[_currentIndex].correctImage;
    final word = _questions[_currentIndex].word;

    setState(() {
      _selected = imgFile;
      _answered = true;
    });

    if (imgFile == correct) {
      _correctCount++;
      _score += 20;
      _bounceCtrl.forward(from: 0);
      await _tts.speak("Yes! That is $word! Great job!");
      await _awardPoints(20);
    } else {
      await _tts.speak("Try again! Find $word.");
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
      gameName: 'Communication - Listen & Find',
      pointsEarned: points,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameOver) return _buildEndScreen();
    final q = _questions[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFFFF9C4), Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildProgressBar(),
              const SizedBox(height: 20),
              _buildListenCard(q),
              const SizedBox(height: 24),
              const Text(
                'Find it! 👆',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF555555)),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildOptionsGrid(q.correctImage)),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '🎧 Listen & Find',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF333333)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade400,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 18),
                const SizedBox(width: 5),
                Text('$_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF26C6DA)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_currentIndex + 1} of ${_questions.length}',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildListenCard(_Question q) {
    return GestureDetector(
      onTap: _answered ? null : _speakWord,
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (ctx, child) => Transform.scale(
          scale: (_answered && _selected == q.correctImage) ? _bounceAnim.value : 1.0,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFF26C6DA).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _isSpeaking ? const Color(0xFF26C6DA) : const Color(0xFFE0F7FA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                  size: 28,
                  color: _isSpeaking ? Colors.white : const Color(0xFF26C6DA),
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Listen carefully!',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    q.word.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF333333),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.touch_app, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text('Tap to hear again',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(String correctImage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _options.map((imgFile) {
          Color borderColor = Colors.transparent;
          Color bgColor = Colors.white;
          Widget? badge;

          if (_answered) {
            if (imgFile == correctImage) {
              borderColor = Colors.green.shade400;
              bgColor = Colors.green.shade50;
              badge = Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              );
            } else if (imgFile == _selected) {
              borderColor = Colors.red.shade400;
              bgColor = Colors.red.shade50;
              badge = Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              );
            }
          }

          return GestureDetector(
            onTap: () => _onTap(imgFile),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      _imgPath(imgFile),
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(top: 8, right: 8, child: badge),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEndScreen() {
    String medal;
    Color color;
    if (_correctCount >= 9) { medal = '🏆'; color = Colors.amber.shade600; }
    else if (_correctCount >= 7) { medal = '⭐'; color = Colors.green.shade500; }
    else if (_correctCount >= 5) { medal = '👍'; color = Colors.blue.shade400; }
    else { medal = '💪'; color = Colors.orange.shade400; }

    final messages = {'🏆': 'Amazing listener!', '⭐': 'Great job!', '👍': 'Good work!', '💪': 'Keep practicing!'};

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFFFF9C4), Color(0xFFFCE4EC)],
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
                  Text(messages[medal]!,
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            const SizedBox(width: 12),
                            Text('$_correctCount / ${_questions.length}',
                                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 28),
                            const SizedBox(width: 8),
                            Text('$_score points',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                        label: const Text('Play Again', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26C6DA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.home),
                        label: const Text('Home', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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