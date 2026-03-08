import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';

// CommunicationPage goes directly into Syllables game
class CommunicationPage extends StatelessWidget {
  final int userId;
  const CommunicationPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SyllablesGame(userId: userId);
  }
}

// ═══════════════════════════════════════════════════════════
// SYLLABLES GAME
// ═══════════════════════════════════════════════════════════
class _SyllablesGame extends StatefulWidget {
  final int userId;
  const _SyllablesGame({required this.userId});
  @override
  State<_SyllablesGame> createState() => _SyllablesGameState();
}

class _SyllablesGameState extends State<_SyllablesGame> {
  final FlutterTts _tts = FlutterTts();
  int _totalPointsEarned = 0, _currentIndex = 0, _score = 0;
  List<String> _dropped = [], _available = [];
  bool _completed = false;

  final List<Map<String, dynamic>> _questions = [
    {'word': 'RABBIT',   'syllables': ['RAB', 'BIT'],        'image': '🐰'},
    {'word': 'BUTTER',   'syllables': ['BUT', 'TER'],        'image': '🧈'},
    {'word': 'PENCIL',   'syllables': ['PEN', 'CIL'],        'image': '✏️'},
    {'word': 'FLOWER',   'syllables': ['FLOW', 'ER'],        'image': '🌸'},
    {'word': 'BALLOON',  'syllables': ['BAL', 'LOON'],       'image': '🎈'},
    {'word': 'DOLPHIN',  'syllables': ['DOL', 'PHIN'],       'image': '🐬'},
    {'word': 'PRESENT',  'syllables': ['PRE', 'SENT'],       'image': '🎁'},
    {'word': 'BUTTERFLY','syllables': ['BUT', 'TER', 'FLY'], 'image': '🦋'},
  ];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.4);
    _load();
  }

  void _load() {
    final s = List<String>.from(_questions[_currentIndex]['syllables']);
    s.shuffle();
    setState(() { _available = s; _dropped = []; _completed = false; });
  }

  void _add(String s) {
    if (_completed) return;
    setState(() { _available.remove(s); _dropped.add(s); });
    _check();
  }

  void _remove(String s) {
    if (_completed) return;
    setState(() { _dropped.remove(s); _available.add(s); });
  }

  void _check() async {
    final correct = List<String>.from(_questions[_currentIndex]['syllables']);
    if (_dropped.length == correct.length) {
      setState(() => _completed = true);
      bool ok = _dropped.join('') == correct.join('');
      if (ok) {
        _score++;
        await _awardPoints(25);
        await _tts.speak("Excellent! ${_questions[_currentIndex]['word']}!");
      } else {
        await _tts.speak("The correct word is ${_questions[_currentIndex]['word']}");
      }
      await Future.delayed(const Duration(seconds: 2));
      if (_currentIndex < _questions.length - 1) {
        setState(() => _currentIndex++);
        _load();
      } else {
        _showEnd();
      }
    }
  }

  Future<void> _awardPoints(int pts) async {
    setState(() => _totalPointsEarned += pts);
    await UserProgress.addScore(pts);
    await ApiService.saveGameSession(
        userId: widget.userId, gameName: 'Syllables', pointsEarned: pts);
  }

  void _showEnd() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('🎉 Well Done!', textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Score: $_score / ${_questions.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('⭐ +$_totalPointsEarned points earned!',
            style: TextStyle(fontSize: 18, color: Colors.amber.shade700)),
      ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() { _currentIndex = 0; _score = 0; _totalPointsEarned = 0; });
            _load();
          },
          child: const Text('Play Again 🔄', style: TextStyle(fontSize: 16)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quit', style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final correct = List<String>.from(q['syllables']);
    final isOk = _dropped.join('') == correct.join('');

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('🔠 Build the Word'),
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        actions: [
          if (_totalPointsEarned > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 18),
                  const SizedBox(width: 4),
                  Text('+$_totalPointsEarned',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Progress
          Column(children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: Colors.orange.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 6),
            Text('${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),
          // Image + hear button
          GestureDetector(
            onTap: () => _tts.speak(q['word']),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.orange.shade100, blurRadius: 10)],
              ),
              child: Column(children: [
                Text(q['image'], style: const TextStyle(fontSize: 70)),
                const SizedBox(height: 10),
                const Text('🔊 Tap to hear the word',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Assemble the syllables:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Drop zone
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: _completed
                  ? (isOk ? Colors.green.shade100 : Colors.red.shade100)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _completed
                    ? (isOk ? Colors.green : Colors.red)
                    : Colors.orange.shade300,
                width: 2,
              ),
            ),
            child: Wrap(
              spacing: 10,
              children: _dropped.isEmpty
                  ? [Text('...', style: TextStyle(fontSize: 24, color: Colors.grey.shade400))]
                  : _dropped.map((s) => GestureDetector(
                        onTap: () => _remove(s),
                        child: Chip(
                          label: Text(s,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.orange.shade200,
                        ),
                      )).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Available syllables:',
              style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _available.map((s) => GestureDetector(
              onTap: () => _add(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 6,
                      offset: const Offset(0, 3))],
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )).toList(),
          ),
        ]),
      ),
    );
  }
}