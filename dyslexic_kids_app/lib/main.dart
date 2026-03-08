import 'package:flutter/material.dart';
import 'pages/onboarding_page.dart'; 
import 'pages/login_page.dart';      
import 'pages/home_page.dart';       
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  await notificationService.scheduleDailyMotivation();
  await notificationService.scheduleDailyChallenge();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kids Learning App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'NotoSans', // ✅ Your font fix is here
        useMaterial3: true,
      ),
      // Starts the app on the Onboarding screen
      home: const OnboardingPage(), 

      // Handling named navigation routes
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (context) => const LoginPage());
        }
        
        if (settings.name == '/home') {
          // Extract the arguments sent during navigation
          final args = settings.arguments as Map<String, dynamic>;
          
          return MaterialPageRoute(
            builder: (context) => HomePage(
              username: args['username'],
              selectedAvatar: args['selectedAvatar'],
              userId: args['userId'], 
            ),
          );
        }
        return null;
      },
    );
  }
}