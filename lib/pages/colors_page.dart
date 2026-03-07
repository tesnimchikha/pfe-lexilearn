import 'package:flutter/material.dart';

// ============================================================
// PaintGamesPage → va directement au jeu de traçage de lettres
// ============================================================
class PaintGamesPage extends StatelessWidget {
  final int userId;
  const PaintGamesPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LetterTracingGame();
  }
}

// ============================================================
// LETTER TRACING GAME
// Cible dyslexie : mémoire motrice des lettres (5-8 ans)
// L'enfant voit une lettre en gros et la trace avec le doigt
// Priorité : lettres miroirs b/d/p/q + lettres fréquentes
// ============================================================
class LetterTracingGame extends StatefulWidget {
  const LetterTracingGame({Key? key}) : super(key: key);
  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class _LetterTracingGameState extends State<LetterTracingGame>
    with SingleTickerProviderStateMixin {

  final List<Map<String, dynamic>> _letters = [
    {'letter': 'A', 'color': Colors.red,        'hint': '🍎 Apple'},
    {'letter': 'B', 'color': Colors.blue,        'hint': '🦋 Butterfly'},
    {'letter': 'C', 'color': Colors.orange,      'hint': '🐱 Cat'},
    {'letter': 'D', 'color': Colors.purple,      'hint': '🐬 Dolphin'},
    {'letter': 'E', 'color': Colors.green,       'hint': '🐘 Elephant'},
    {'letter': 'F', 'color': Colors.pink,        'hint': '🐸 Frog'},
    {'letter': 'b', 'color': Colors.indigo,      'hint': '🎈 Balloon'},
    {'letter': 'd', 'color': Colors.teal,        'hint': '🐶 Dog'},
    {'letter': 'p', 'color': Colors.amber,       'hint': '🐧 Penguin'},
    {'letter': 'q', 'color': Colors.cyan,        'hint': '👑 Queen'},
    {'letter': 'n', 'color': Colors.lime,        'hint': '🌙 Night'},
    {'letter': 'u', 'color': Colors.deepOrange,  'hint': '☂️ Umbrella'},
  ];

  int _currentIndex = 0;
  List<List<Offset>> _strokes = [[]];
  bool _showSuccess = false;
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _letters.shuffle();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut));
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _clear()    => setState(() => _strokes = [[]]);
  void _done()     { setState(() => _showSuccess = true); _anim.forward(from: 0); }
  void _next()     => setState(() { _showSuccess = false; _strokes = [[]]; _currentIndex = (_currentIndex + 1) % _letters.length; });

  @override
  Widget build(BuildContext context) {
    final cur   = _letters[_currentIndex];
    final Color col = cur['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(child: Column(children: [

        // ── Header ──
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
              child: IconButton(icon: const Icon(Icons.arrow_back, size: 28), onPressed: () => Navigator.pop(context)),
            ),
            const Spacer(),
            const Text('✏️ Trace la lettre',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5))),
            const Spacer(),
            const SizedBox(width: 48),
          ]),
        ),

        // ── Progress dots ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_letters.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _currentIndex ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentIndex ? col : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
        const SizedBox(height: 16),

        // ── Hint word ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(cur['hint'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: col)),
        ),
        const SizedBox(height: 16),

        // ── Canvas ──
        Expanded(
          child: Stack(alignment: Alignment.center, children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: col.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: GestureDetector(
                  onPanStart:  (d) => setState(() => _strokes.last.add(d.localPosition)),
                  onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
                  onPanEnd:    (_) => setState(() => _strokes.add([])),
                  child: CustomPaint(
                    painter: _TracingPainter(letter: cur['letter'], color: col, strokes: _strokes),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── Success popup ──
            if (_showSuccess)
              ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('⭐', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 10),
                    Text('Bravo !', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green.shade600)),
                    const SizedBox(height: 6),
                    Text('Tu as tracé la lettre ${cur['letter']} !',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Lettre suivante →',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ]),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Buttons ──
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn('Effacer', Icons.refresh, Colors.red.shade400, _clear),
          const SizedBox(width: 16),
          _btn('Terminé ✓', Icons.check_circle, Colors.green.shade500, _done),
        ]),
        const SizedBox(height: 24),
      ])),
    );
  }

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ),
      );
}

// ============================================================
// CUSTOM PAINTER — lettre guide en transparent + tracé de l'enfant
// ============================================================
class _TracingPainter extends CustomPainter {
  final String letter;
  final Color color;
  final List<List<Offset>> strokes;

  const _TracingPainter({required this.letter, required this.color, required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Lettre guide très claire (fond)
    _drawLetter(canvas, size, color.withOpacity(0.10), PaintingStyle.fill);
    // 2. Contour pointillé de la lettre
    _drawLetter(canvas, size, color.withOpacity(0.30), PaintingStyle.stroke, strokeWidth: 3.0);

    // 3. Tracé de l'enfant
    final paint = Paint()
      ..color = color
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
      for (final p in stroke) { canvas.drawCircle(p, 10, dotPaint); }
    }
  }

  void _drawLetter(Canvas canvas, Size size, Color col, PaintingStyle style, {double strokeWidth = 1.0}) {
    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: size.height * 0.62,
          fontWeight: FontWeight.w900,
          foreground: style == PaintingStyle.stroke
              ? (Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..color = col)
              : null,
          color: style == PaintingStyle.fill ? col : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant _TracingPainter old) => true;
}