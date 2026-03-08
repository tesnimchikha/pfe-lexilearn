import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart'; // تأكد أن المسار صحيح لملف الـ API
import '../services/notification_service.dart'; // تأكد أن المسار صحيح

class AlphabetsPage extends StatefulWidget {
  final int userId; // المعرف الخاص بالمستخدم القادم من صفحة الـ Home
  
  const AlphabetsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<AlphabetsPage> createState() => _AlphabetsPageState();
}

class _AlphabetsPageState extends State<AlphabetsPage> {
  String currentLetter = 'A';
  int currentLetterIndex = 0;
  List<String> droppedCorrectItems = [];
  int score = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.1);
    // Announce the first letter when the game starts
    await Future.delayed(const Duration(milliseconds: 600));
    await _tts.speak("This is the letter ${currentLetter}");
  }

  Future<void> _speakLetter() async {
    await _tts.speak("This is the letter ${currentLetter}. Find the pictures that start with ${currentLetter}!");
  }

  Future<void> _speakCorrect(String itemName) async {
    await _tts.speak("${itemName} starts with ${currentLetter}. Correct!");
  }

  Future<void> _speakWrong(String itemName) async {
    await _tts.speak("${itemName} does not start with ${currentLetter}. Try again!");
  }

  Future<void> _speakComplete() async {
    await _tts.speak("Great job! You finished the letter ${currentLetter}!");
  }

  // All letters A to Z
  final List<String> allLetters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  // Items for drag and drop with proper image paths
  final Map<String, List<DraggableItem>> letterItems = {
    'A': [
      DraggableItem('Apple', 'assets/images/alphabets/apple.png', true,'' ),
      DraggableItem('Ant', 'assets/images/alphabets/ant.png', true, ''),
      DraggableItem('Ball', 'assets/images/alphabets/ball.png', false, ''),
      DraggableItem('Car', 'assets/images/alphabets/car.png', false, ''),
    ],
    'B': [
      DraggableItem('Ball', 'assets/images/alphabets/ball.png', true, ''),
      DraggableItem('Banana', 'assets/images/alphabets/banana.png', true, ''),
      DraggableItem('Apple', 'assets/images/alphabets/apple.png', false, ''),
      DraggableItem('Cat', 'assets/images/alphabets/cat.png', false, ''),
    ],
    'C': [
      DraggableItem('Cat', 'assets/images/alphabets/cat.png', true, ''),
      DraggableItem('Car', 'assets/images/alphabets/car.png', true, ''),
      DraggableItem('Ball', 'assets/images/alphabets/ball.png', false, ''),
      DraggableItem('Dog', 'assets/images/alphabets/dog.png', false, ''),
    ],
    'D': [
      DraggableItem('Dog', 'assets/images/alphabets/dog.png', true, ''),
      DraggableItem('Duck', 'assets/images/alphabets/duck.png', true, ''),
      DraggableItem('Cat', 'assets/images/alphabets/cat.png', false, ''),
      DraggableItem('Egg', 'assets/images/alphabets/egg.png', false, ''),
    ],
    'E': [
      DraggableItem('Egg', 'assets/images/alphabets/egg.png', true, ''),
      DraggableItem('Elephant', 'assets/images/alphabets/elephant.png', true, ''),
      DraggableItem('Dog', 'assets/images/alphabets/dog.png', false, ''),
      DraggableItem('Fish', 'assets/images/alphabets/fish.png', false, ''),
    ],
    'F': [
      DraggableItem('Fish', 'assets/images/alphabets/fish.png', true, ''),
      DraggableItem('Frog', 'assets/images/alphabets/frog.png', true, ''),
      DraggableItem('Egg', 'assets/images/alphabets/egg.png', false, ''),
      DraggableItem('Goat', 'assets/images/alphabets/goat.png', false, ''),
    ],
    'G': [
      DraggableItem('Goat', 'assets/images/alphabets/goat.png', true, ''),
      DraggableItem('Grapes', 'assets/images/alphabets/grapes.png', true, ''),
      DraggableItem('Fish', 'assets/images/alphabets/fish.png', false, ''),
      DraggableItem('Hat', 'assets/images/alphabets/hat.png', false, ''),
    ],
    'H': [
      DraggableItem('Hat', 'assets/images/alphabets/hat.png', true, ''),
      DraggableItem('Horse', 'assets/images/alphabets/horse.png', true, ''),
      DraggableItem('Grapes', 'assets/images/alphabets/grapes.png', false, ''),
      DraggableItem('Ice', 'assets/images/alphabets/ice.png', false, ''),
    ],
    'I': [
      DraggableItem('Ice', 'assets/images/alphabets/ice.png', true, ''),
      DraggableItem('Igloo', 'assets/images/alphabets/igloo.png', true, ''),
      DraggableItem('Hat', 'assets/images/alphabets/hat.png', false, ''),
      DraggableItem('Jam', 'assets/images/alphabets/jam.png', false, ''),
    ],
    'J': [
      DraggableItem('Jam', 'assets/images/alphabets/jam.png', true, ''),
      DraggableItem('Juice', 'assets/images/alphabets/juice.png', true, ''),
      DraggableItem('Ice', 'assets/images/alphabets/ice.png', false, ''),
      DraggableItem('Kite', 'assets/images/alphabets/kite.png', false, ''),
    ],
    'K': [
      DraggableItem('Kite', 'assets/images/alphabets/kite.png', true, ''),
      DraggableItem('Key', 'assets/images/alphabets/key.png', true, ''),
      DraggableItem('Jam', 'assets/images/alphabets/jam.png', false, ''),
      DraggableItem('Leaf', 'assets/images/alphabets/leaf.png', false, ''),
    ],
    'L': [
      DraggableItem('Leaf', 'assets/images/alphabets/leaf.png', true, ''),
      DraggableItem('Lion', 'assets/images/alphabets/lion.png', true, ''),
      DraggableItem('Kite', 'assets/images/alphabets/kite.png', false, ''),
      DraggableItem('Monkey', 'assets/images/alphabets/monkey.png', false, ''),
    ],
    'M': [
      DraggableItem('Monkey', 'assets/images/alphabets/monkey.png', true, ''),
      DraggableItem('Moon', 'assets/images/alphabets/moon.png', true, ''),
      DraggableItem('Leaf', 'assets/images/alphabets/leaf.png', false, ''),
      DraggableItem('Nest', 'assets/images/alphabets/nest.png', false, ''),
    ],
    'N': [
      DraggableItem('Nest', 'assets/images/alphabets/nest.png', true, ''),
      DraggableItem('Nut', 'assets/images/alphabets/nut.png', true, ''),
      DraggableItem('Monkey', 'assets/images/alphabets/monkey.png', false, ''),
      DraggableItem('Orange', 'assets/images/alphabets/orange.png', false, ''),
    ],
    'O': [
      DraggableItem('Orange', 'assets/images/alphabets/orange.png', true, ''),
      DraggableItem('Owl', 'assets/images/alphabets/owl.png', true, ''),
      DraggableItem('Nest', 'assets/images/alphabets/nest.png', false, ''),
      DraggableItem('Pizza', 'assets/images/alphabets/pizza.png', false, ''),
    ],
    'P': [
      DraggableItem('Pizza', 'assets/images/alphabets/pizza.png', true, ''),
      DraggableItem('Pen', 'assets/images/alphabets/pen.png', true, ''),
      DraggableItem('Orange', 'assets/images/alphabets/orange.png', false, ''),
      DraggableItem('Queen', 'assets/images/alphabets/queen.png', false, ''),
    ],
    'Q': [
      DraggableItem('Queen', 'assets/images/alphabets/queen.png', true, ''),
      DraggableItem('Quilt', 'assets/images/alphabets/quilt.png', true, ''),
      DraggableItem('Pen', 'assets/images/alphabets/pen.png', false, ''),
      DraggableItem('Rabbit', 'assets/images/alphabets/rabbit.png', false, ''),
    ],
    'R': [
      DraggableItem('Rabbit', 'assets/images/alphabets/rabbit.png', true, ''),
      DraggableItem('Ring', 'assets/images/alphabets/ring.png', true, ''),
      DraggableItem('Queen', 'assets/images/alphabets/queen.png', false, ''),
      DraggableItem('Sun', 'assets/images/alphabets/sun.png', false, ''),
    ],
    'S': [
      DraggableItem('Sun', 'assets/images/alphabets/sun.png', true, ''),
      DraggableItem('Star', 'assets/images/alphabets/star.png', true, ''),
      DraggableItem('Rabbit', 'assets/images/alphabets/rabbit.png', false, ''),
      DraggableItem('Tiger', 'assets/images/alphabets/tiger.png', false, ''),
    ],
    'T': [
      DraggableItem('Tiger', 'assets/images/alphabets/tiger.png', true, ''),
      DraggableItem('Tree', 'assets/images/alphabets/tree.png', true, ''),
      DraggableItem('Sun', 'assets/images/alphabets/sun.png', false, ''),
      DraggableItem('Umbrella', 'assets/images/alphabets/umbrella.png', false, ''),
    ],
    'U': [
      DraggableItem('Umbrella', 'assets/images/alphabets/umbrella.png', true, ''),
      DraggableItem('Unicorn', 'assets/images/alphabets/unicorn.png', true, ''),
      DraggableItem('Tree', 'assets/images/alphabets/tree.png', false, ''),
      DraggableItem('Violin', 'assets/images/alphabets/violin.png', false, ''),
    ],
    'V': [
      DraggableItem('Violin', 'assets/images/alphabets/violin.png', true, ''),
      DraggableItem('Van', 'assets/images/alphabets/van.png', true, ''),
      DraggableItem('Umbrella', 'assets/images/alphabets/umbrella.png', false, ''),
      DraggableItem('Whale', 'assets/images/alphabets/whale.png', false, ''),
    ],
    'W': [
      DraggableItem('Whale', 'assets/images/alphabets/whale.png', true, ''),
      DraggableItem('Watch', 'assets/images/alphabets/watch.png', true, ''),
      DraggableItem('Violin', 'assets/images/alphabets/violin.png', false, ''),
      DraggableItem('Xylophone', 'assets/images/alphabets/xylophone.png', false, ''),
    ],
    'X': [
      DraggableItem('Xylophone', 'assets/images/alphabets/xylophone.png', true, ''),
      DraggableItem('X-ray', 'assets/images/alphabets/xray.png', true, ''),
      DraggableItem('Watch', 'assets/images/alphabets/watch.png', false, ''),
      DraggableItem('Yak', 'assets/images/alphabets/yak.png', false, ''),
    ],
    'Y': [
      DraggableItem('Yak', 'assets/images/alphabets/yak.png', true, ''),
      DraggableItem('Yarn', 'assets/images/alphabets/yarn.png', true, ''),
      DraggableItem('Xylophone', 'assets/images/alphabets/xylophone.png', false, ''),
      DraggableItem('Zebra', 'assets/images/alphabets/zebra.png', false, ''),
    ],
    'Z': [
      DraggableItem('Zebra', 'assets/images/alphabets/zebra.png', true, ''),
      DraggableItem('Zoo', 'assets/images/alphabets/zoo.png', true, ''),
      DraggableItem('Yarn', 'assets/images/alphabets/yarn.png', false, ''),
      DraggableItem('Apple', 'assets/images/alphabets/apple.png', false, ''),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final items = letterItems[currentLetter] ?? [];
    final correctItemsCount = items.where((item) => item.isCorrect).length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade100,
              Colors.orange.shade100,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildScore(),
              const SizedBox(height: 20),
              _buildLetterDisplay(),
              const SizedBox(height: 20),
              Text(
                'Drag items that start with "$currentLetter"',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.grey.shade700
                ),
              ),
              const SizedBox(height: 20),
              _buildDropZone(correctItemsCount),
              const SizedBox(height: 20),
              Expanded(child: _buildDraggableItems(items)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Alphabet Game',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: Colors.orange, size: 30),
          const SizedBox(width: 8),
          Text(
            'Points: $score',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterDisplay() {
    return GestureDetector(
      onTap: () {
        _playLetterSound();
        _speakLetter(); // ← TTS reads the letter when tapped
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.pink.shade300,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8)
            )
          ],
        ),
        child: Center(
          child: Text(
            currentLetter,
            style: const TextStyle(
              fontSize: 50, 
              fontWeight: FontWeight.w900, 
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropZone(int correctItemsCount) {
    bool isComplete = droppedCorrectItems.length == correctItemsCount;

    return DragTarget<DraggableItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) async {
        final item = details.data;
        if (item.isCorrect && !droppedCorrectItems.contains(item.name)) {
          setState(() {
            droppedCorrectItems.add(item.name);
            score += 10;
          });

          // تحديث النقاط في قاعدة البيانات (MySQL)
          await ApiService.addPoints(widget.userId, 10); 

          _playCorrectSound();
          await _speakCorrect(item.name); // ← TTS confirms correct answer

          if (droppedCorrectItems.length == correctItemsCount) {
            await _speakComplete(); // ← TTS celebrates
            _showCompletionDialog();
          }
        } else if (!item.isCorrect) {
          _playErrorSound();
          await _speakWrong(item.name); // ← TTS explains the mistake
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: isComplete ? Colors.green.shade100 : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isComplete ? Colors.green : Colors.grey.shade400, 
              width: 3,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check_circle, color: Colors.green, size: 50)
                : Icon(Icons.move_to_inbox, size: 40, color: Colors.grey.shade400),
          ),
        );
      },
    );
  }

  Widget _buildDraggableItems(List<DraggableItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 20, 
        mainAxisSpacing: 20,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (droppedCorrectItems.contains(item.name)) return const SizedBox.shrink();

        return Draggable<DraggableItem>(
          data: item,
          feedback: Material(
            color: Colors.transparent, 
            child: _buildItemCard(item, isDragging: true)
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: _buildItemCard(item)),
          child: GestureDetector(
            onTap: () => _tts.speak(item.name), // ← tap = TTS says the item name
            child: _buildItemCard(item),
          ),
        );
      },
    );
  }

  Widget _buildItemCard(DraggableItem item, {bool isDragging = false}) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDragging ? 0.3 : 0.1), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(item.imagePath, width: 70, height: 70, fit: BoxFit.contain),
          const SizedBox(height: 10),
          Text(
            item.name, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  void _playLetterSound() {
    _audioPlayer.play(AssetSource('assets/audio/${currentLetter.toLowerCase()}.mp3'));
  }

  void _playCorrectSound() => _audioPlayer.play(AssetSource(''));
  void _playErrorSound() => _audioPlayer.play(AssetSource(''));

  void _showCompletionDialog() {
    _playCorrectSound();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Great Job!'),
        content: Text('You finished letter $currentLetter!'),
        actions: [
          TextButton(
            onPressed: () { 
              Navigator.pop(context); 
              _goToNextLetter(); 
            }, 
            child: const Text('Next Letter', style: TextStyle(fontSize: 18))
          )
        ],
      ),
    );
  }

  void _goToNextLetter() {
    setState(() {
      if (currentLetterIndex < allLetters.length - 1) {
        currentLetterIndex++;
        currentLetter = allLetters[currentLetterIndex];
      } else {
        _showFinalCompletionDialog();
        return;
      }
      droppedCorrectItems.clear();
    });
    // Announce new letter with TTS
    Future.delayed(const Duration(milliseconds: 400), () {
      _tts.speak("Now let's learn the letter ${currentLetter}!");
    });
  }

  void _showFinalCompletionDialog() {
    // إظهار تنبيه Level Up عند إكمال اللعبة بالكامل
    NotificationService().showLevelUpNotification(1); 
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(' Celebration!'),
        content: Text('You completed the whole alphabet!\nTotal Score: $score'),
        actions: [
          ElevatedButton(
            onPressed: () { 
              Navigator.pop(context); 
              Navigator.pop(context); 
            }, 
            child: const Text('Go Home')
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }
}

// كلاس البيانات الخاص بالعناصر
class DraggableItem {
  final String name;
  final String imagePath;
  final bool isCorrect;
  final String soundPath;
  DraggableItem(this.name, this.imagePath, this.isCorrect, this.soundPath);
}