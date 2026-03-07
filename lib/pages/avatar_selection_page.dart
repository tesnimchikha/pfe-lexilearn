import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class AvatarSelectionPage extends StatefulWidget {
  final String username;
  final int userId;
  final String token; // FIX: receive token directly, no SharedPreferences timing issues

  const AvatarSelectionPage({
    Key? key,
    required this.username,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  int? _selectedAvatar;
  bool _isLoading = false;

  final List<String> avatarPaths = [
    'assets/images/avatars/avatar1.png',
    'assets/images/avatars/avatar2.png',
    'assets/images/avatars/avatar3.png',
    'assets/images/avatars/avatar4.png',
    'assets/images/avatars/avatar5.png',
    'assets/images/avatars/avatar6.png',
    'assets/images/avatars/avatar7.png',
    'assets/images/avatars/avatar8.png',
    'assets/images/avatars/avatar9.png',
  ];

  final List<Color> avatarBackgroundColors = [
    const Color(0xFFB8E6B8),
    const Color(0xFFFFD966),
    const Color(0xFFFFB84D),
    const Color(0xFFE4C1F9),
    const Color(0xFFFFB3BA),
    const Color(0xFF91D5FF),
    const Color(0xFFFFC6FF),
    const Color(0xFFFFE699),
    const Color(0xFFB4A7D6),
  ];

  Map<String, String> _authHeaders() {
    // FIX: use token passed directly as parameter — no async, no SharedPreferences
    print("🔑 Avatar token: ${widget.token.isEmpty ? 'EMPTY ❌' : 'OK ✅'}");
    return {
      "Content-Type": "application/json",
      if (widget.token.isNotEmpty) "Authorization": "Bearer ${widget.token}",
    };
  }

  Future<bool> _updateAvatarInDatabase(int avatarId) async {
    setState(() => _isLoading = true);
    try {
      if (widget.token.isEmpty) {
        print("❌ No token - cannot save avatar to server");
        return false;
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/update-avatar'),
        headers: _authHeaders(),
        body: jsonEncode({
          "userId": widget.userId,
          "avatarId": avatarId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Avatar saved to DB: $avatarId");
        return true;
      } else {
        print("❌ Server error ${response.statusCode}: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Connection error: $e");
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/registration_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Text(
                'choose your\navatar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange.shade500,
                  height: 1.2,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildAvatarGrid()),
              _buildPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('2 of 2',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.pink.shade300]),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 400,
            height: 600,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: avatarPaths.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedAvatar == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? avatarBackgroundColors[index]
                          : Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? avatarBackgroundColors[index]
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(avatarPaths[index], fit: BoxFit.contain),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: GestureDetector(
        onTap: (_selectedAvatar != null && !_isLoading)
            ? () async {
                final int chosenId = _selectedAvatar! + 1;

                // Save to SharedPreferences as local backup
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('avatarId', chosenId);
                print("💾 Avatar saved locally: $chosenId");

                // Save to server
                final saved = await _updateAvatarInDatabase(chosenId);
                if (!saved) {
                  print("⚠️ Server save failed, using local backup");
                }

                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      username: widget.username,
                      selectedAvatar: chosenId,
                      userId: widget.userId,
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          width: 200,
          height: 65,
          decoration: BoxDecoration(
            color: _selectedAvatar != null
                ? Colors.purple.shade300
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(35),
            boxShadow: _selectedAvatar != null
                ? [BoxShadow(
                    color: Colors.purple.shade300.withOpacity(0.5),
                    offset: const Offset(0, 8),
                    blurRadius: 10)]
                : [],
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('PLAY',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
        ),
      ),
    );
  }
}