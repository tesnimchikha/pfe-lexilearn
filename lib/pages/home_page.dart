import 'package:flutter/material.dart';
import 'alphabets_page.dart';
import 'numbers_page.dart';
import 'colors_page.dart'; // contains PaintGamesPage (no userId needed)
import 'puzzles_page.dart';
import 'communication_page.dart';
import 'mathematics_page.dart';
import 'daily_challenge_page.dart';
import 'dashboard_page.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  final String username;
  final int selectedAvatar;
  final int userId;

  const HomePage({
    super.key,
    required this.username,
    required this.selectedAvatar,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotificationService _notificationService;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.scheduleDailyMotivation();
    await _notificationService.scheduleDailyChallenge();
  }

  void _toggleNotifications() {
    setState(() => _notificationsEnabled = !_notificationsEnabled);
    if (_notificationsEnabled) {
      _notificationService.scheduleDailyMotivation();
      _notificationService.scheduleDailyChallenge();
    } else {
      _notificationService.cancelAllNotifications();
    }
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    if (categoryName == 'Alphabets') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlphabetsPage(userId: widget.userId),
        ),
      );
    } else if (categoryName == 'Numbers') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NumbersPageDyslexic(userId: widget.userId),
        ),
      );
    } else if (categoryName == 'Colors') {
      Navigator.push(
        context,
        MaterialPageRoute(
       builder: (context) => PaintGamesPage(userId: widget.userId), // no userId needed
        ),
      );
    } else if (categoryName == 'Puzzles') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PuzzleGamesPage(userId: widget.userId),
        ),
      );
    } else if (categoryName == 'Communication') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunicationPage(userId: widget.userId),
        ),
      );
    } else if (categoryName == 'Mathematics') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MathematicsPage(userId: widget.userId),
        ),
      );
    }
  }

  void _showDashboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          username: widget.username,
          selectedAvatar: widget.selectedAvatar,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 25),
                _buildDailyChallengeCard(context),
                const SizedBox(height: 40),
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                const SizedBox(height: 20),
                _buildCategoriesGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showDashboard(context),
          child: Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.orangeAccent),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatars/avatar${widget.selectedAvatar}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${widget.username}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const Text(
                "Let's play, learn, and have fun!",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _toggleNotifications,
          child: Icon(
            _notificationsEnabled ? Icons.notifications : Icons.notifications_off,
            color: _notificationsEnabled ? Colors.orangeAccent : Colors.grey,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallengeCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 20,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(210, 60, 30, 150), Color.fromARGB(224, 119, 70, 243)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(35)),
              ),
            ),
          ),
          Positioned(
            left: 25,
            top: 45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily 👀',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const Text(
                  'challenge',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 0.9),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyChallengePage(userId: widget.userId),
                    ),
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      child: Text(
                        "let's go",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF8B5CFF)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -15,
            top: -5,
            child: Image.asset('assets/images/daily_puzzle.png', width: 230, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      {'name': 'Alphabets', 'image': 'alphabets.png'},
      {'name': 'Numbers', 'image': 'numbers.png'},
      {'name': 'Colors', 'image': 'colors.png'},
      {'name': 'Puzzles', 'image': 'puzzles.png'},
      {'name': 'Communication', 'image': 'communication.png'},
      {'name': 'Mathematics', 'image': 'mathematic.png'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const int crossAxisCount = 2;
        const double spacing = 15.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final imagePath = 'assets/images/categories/${cat['image']!}';
            return GestureDetector(
              onTap: () => _navigateToCategory(context, cat['name']!),
              child: Hero(
                tag: imagePath,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            );
          },
        );
      },
    );
  }
}