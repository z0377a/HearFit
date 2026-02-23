import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/register_screen.dart';
import 'screens/restrictions_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HearFit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/restrictions': (context) => const RestrictionsScreen(),
        '/preferences': (context) => const PreferencesScreen(),
        '/exercises': (context) => const ExercisesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}