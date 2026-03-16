import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  Future<void> _createDefaultGuestData(String uid) async {
    await _database.child('users').child(uid).set({
      'name': 'Gast (Experte)',
      'email': 'gast@hearfit.de',
      'userType': 'guest',
      'createdAt': DateTime.now().toIso8601String(),
      'questionnaire': {
        'visualImpairment': 'Vollständig blind',
        'assistiveTools': ['Screenreader (VoiceOver / Talkback)'],
        'safetyAspects': ['Keine Einschränkungen'],
        'medicationDetails': '',
        'fitnessLevel': 'Experte',
        'goals': [
          'Ausdauer verbessern',
          'Beweglichkeit & Dehnung',
          'Gewichtsreduktion',
          'Sicherheit in der alltäglichen Orientierung / Koordination'
        ],
        'completedAt': DateTime.now().toIso8601String(),
      }
    });
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        DatabaseEvent event = await _database
            .child('users')
            .child(user.uid)
            .child('questionnaire')
            .once();

        if (event.snapshot.value == null) {
          await _createDefaultGuestData(user.uid);
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/exercises');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Status Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.wifi, size: 16, color: Colors.black),
                          const SizedBox(width: 4),
                          Icon(Icons.battery_full, size: 16, color: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 192,
                        height: 192,
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8E8E8),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/erasebg-transformed (1).png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF265E43).withOpacity(0.1),
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 96,
                                  color: const Color(0xFF265E43),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Welcome Text
                      const Text(
                        'Willkommen bei',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'HearFit',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Buttons Container
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF265E43),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Registrieren',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF265E43),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Guest Link
                      TextButton(
                        onPressed: _isLoading ? null : _continueAsGuest,
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : Text(
                          'Als Gast Fortfahren',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF265E43),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Home Indicator
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: Container(
                      width: 128,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF265E43)),
                          ),
                          const SizedBox(height: 16),
                          const Text('Gast-Zugang wird eingerichtet...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}