import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final int selectedAvatar;
  final int userId;
  const DashboardPage({super.key, required this.username, required this.selectedAvatar, required this.userId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _score = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Getters for automatic calculations
  int get level => (_score / 300).floor() + 1;
  double get progress => (_score % 300) / 300;
  int get remaining => 300 - (_score % 300);

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final resp = await http.get(
        Uri.parse('http://localhost:3000/user-stats/${widget.userId}'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        setState(() { 
          _score = jsonDecode(resp.body)['total_points'] ?? 0; 
          _isLoading = false; 
        });
      } else {
        setState(() { _isLoading = false; _error = 'Error: ${resp.statusCode}'; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _error = 'Connection Error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return _buildErrorUI();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context), color: Colors.black),
        elevation: 0, 
        backgroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 20),
            Text(widget.username, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            _buildLevelBadge(),
            const SizedBox(height: 40),
            _buildProgressSection(),
            const SizedBox(height: 30),
            _buildStatsCard(),
            // THE TEST BUTTON HAS BEEN REMOVED FROM HERE
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() => Container(
    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
    child: CircleAvatar(
      radius: 50, 
      backgroundColor: Colors.orange.shade200, 
      backgroundImage: AssetImage('assets/images/avatars/avatar${widget.selectedAvatar}.png')
    ),
  );

  Widget _buildLevelBadge() => Container(
    margin: const EdgeInsets.only(top: 10),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(20)),
    child: Text('LV.$level', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
  );

  Widget _buildProgressSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Level Progress', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('$_score / ${level * 300} pts', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 10),
      LinearProgressIndicator(
        value: progress, 
        backgroundColor: Colors.grey.shade200, 
        valueColor: const AlwaysStoppedAnimation(Colors.green), 
        minHeight: 12,
        borderRadius: BorderRadius.circular(10),
      ),
      const SizedBox(height: 8),
      Text('$remaining points to Level ${level + 1}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );

  Widget _buildStatsCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.blue.shade50, 
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: Colors.blue.shade100)
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _statItem(Icons.star, 'Total Score', '$_score', Colors.amber),
      _statItem(Icons.emoji_events, 'Trophies', '0', Colors.orange),
    ]),
  );

  Widget _statItem(IconData icon, String label, String val, Color col) => Column(children: [
    Icon(icon, color: col, size: 35),
    const SizedBox(height: 5),
    Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
    Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blue)),
  ]);

  Widget _buildErrorUI() => Scaffold(
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, size: 60, color: Colors.red),
      const SizedBox(height: 10),
      Text(_error!, style: const TextStyle(color: Colors.grey, fontSize: 18)),
      TextButton.icon(onPressed: _fetchData, icon: const Icon(Icons.refresh), label: const Text("Try Again"))
    ]))
  );
}