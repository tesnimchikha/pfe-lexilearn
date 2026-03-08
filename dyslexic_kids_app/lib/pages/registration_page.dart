import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'avatar_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _userType = 'kid';
  bool _isLoading = false;
  String _savedToken = ''; // Store token here to pass it to the next page

  Future<int?> registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return null;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
          "role": _userType == 'kid' ? 'parent' : _userType,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print("✅ Success: ${responseData['message']}");

        // FIX: Extract token from the root of the response
        final String token = responseData['token'] ?? '';
        final int userId = responseData['user']['id'];

        if (token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('userId', userId);

          setState(() =>
              _savedToken = token); // Save to state to pass to next screen
          print("🎫 Token received: OK ✅");
        }

        return userId;
      } else {
        String error = responseData['error'] ?? "Registration failed";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return null;
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return null;
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text('1 of 2',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.orange.shade300,
                          Colors.pink.shade300
                        ]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'create your\naccount',
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
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6), width: 1),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField(_usernameController, 'username',
                                  Icons.person_outline),
                              const SizedBox(height: 20),
                              _buildTextField(_passwordController, 'password',
                                  Icons.lock_outline,
                                  isPassword: true),
                              const SizedBox(height: 20),
                              _buildTextField(_confirmPasswordController,
                                  'confirm password', Icons.lock_outline,
                                  isPassword: true),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildUserTypeButton('kid', 'Kid'),
                                  const SizedBox(width: 30),
                                  _buildUserTypeButton('teacher', 'Teacher'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () async {
                          int? userId = await registerUser();
                          if (userId != null && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AvatarSelectionPage(
                                  username: _usernameController.text,
                                  userId: userId,
                                  token:
                                      _savedToken, // Pass the token we just saved
                                ),
                              ),
                            );
                          }
                        },
                  child: Container(
                    width: 200,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade300,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade300.withOpacity(0.5),
                          offset: const Offset(0, 8),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('NEXT',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildUserTypeButton(String type, String label) {
    bool isSelected = _userType == type;
    return GestureDetector(
      onTap: () => setState(() => _userType = type),
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.purple),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}
