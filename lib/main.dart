import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Neu: Firebase importieren
import 'firebase_options.dart'; // Neu: Von FlutterFire CLI generiert

import 'screens/start_screen.dart';
import 'screens/register_screen.dart';
import 'screens/restrictions_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/exercises_screen.dart';
import 'screens/login_screen.dart';

void main() async { // WICHTIG: main() muss async sein!
  // WidgetsFlutterBinding muss initialisiert werden, bevor Firebase.initializeApp() aufgerufen wird
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialisieren - DAS WAR DER FEHLENDE TEIL!
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Verwendet die richtige Konfiguration für Web/Android/iOS
    );
    print('Firebase erfolgreich initialisiert! ✅');
  } catch (e) {
    print('Fehler bei Firebase-Initialisierung: ❌ $e');
    // Im Fehlerfall trotzdem fortfahren, aber mit Warnung
  }

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