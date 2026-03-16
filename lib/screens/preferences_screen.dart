import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  String? _selectedFitnessLevel;
  final List<Map<String, String>> _fitnessLevelOptions = [
    {'id': 'beginner', 'level': 'Anfänger', 'description': 'Ich fange gerade erst mit Sport an.'},
    {'id': 'moderate', 'level': 'Moderat', 'description': 'Ich habe eine lange Zeit keinen Sport/Übungen gemacht.'},
    {'id': 'advanced', 'level': 'Fortgeschritten', 'description': 'Ich mache regelmäßig Übungen.'},
    {'id': 'expert', 'level': 'Experte', 'description': 'Ich bin sehr fit und suche neue Herausforderungen.'},
  ];

  final List<Map<String, dynamic>> _goalsOptions = [
    {'id': 'endurance', 'label': 'Ausdauer verbessern', 'selected': false},
    {'id': 'flexibility', 'label': 'Beweglichkeit & Dehnung', 'selected': false},
    {'id': 'weight', 'label': 'Gewichtsreduktion', 'selected': false},
    {'id': 'safety', 'label': 'Sicherheit in der alltäglichen Orientierung / Koordination', 'selected': false},
  ];

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  Future<void> _saveAllQuestionnaireData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    DatabaseEvent tempEvent = await _database
        .child('users')
        .child(user.uid)
        .child('temp_questionnaire')
        .once();

    if (tempEvent.snapshot.value == null) {
      throw Exception('Keine Daten vom ersten Fragebogen gefunden');
    }

    Map<String, dynamic> tempData =
    Map<String, dynamic>.from(tempEvent.snapshot.value as Map);

    List<String> selectedGoals = [];
    for (var option in _goalsOptions) {
      if (option['selected'] == true) selectedGoals.add(option['label']);
    }

    Map<String, dynamic> completeData = {
      'visualImpairment': tempData['visualImpairment'] ?? '',
      'assistiveTools': tempData['assistiveTools'] ?? [],
      'safetyAspects': tempData['safetyAspects'] ?? [],
      'medicationDetails': tempData['medicationDetails'] ?? '',
      'fitnessLevel': _selectedFitnessLevel,
      'goals': selectedGoals,
      'completedAt': DateTime.now().toIso8601String(),
      'userId': user.uid,
    };

    await _database
        .child('users')
        .child(user.uid)
        .child('questionnaire')
        .set(completeData);

    await _database
        .child('users')
        .child(user.uid)
        .child('temp_questionnaire')
        .remove();
  }

  void _submitAndContinue() async {
    if (_selectedFitnessLevel == null) {
      _showError('Bitte wähle dein Fitness-Level aus');
      return;
    }

    bool hasGoal = false;
    for (var option in _goalsOptions) {
      if (option['selected'] == true) { hasGoal = true; break; }
    }
    if (!hasGoal) {
      _showError('Bitte wähle mindestens ein Ziel aus');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveAllQuestionnaireData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fragebogen erfolgreich abgeschlossen!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/exercises');
        });
      }
    } catch (e) {
      if (mounted) _showError('Fehler beim Speichern: ${e.toString()}');
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
                // Header with Back Button
                Container(
                  color: const Color(0xFF265E43),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Präferenzen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF265E43),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Schritt 2 von 2: Deine Präferenzen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Frage 1
                          _buildQuestionBox(
                            title: '1. Fitness-Level & Erfahrung',
                            child: Column(
                              children: _fitnessLevelOptions.map((option) {
                                return GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    setState(() => _selectedFitnessLevel = option['level']);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(right: 12, top: 2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedFitnessLevel == option['level']
                                                  ? const Color(0xFF265E43)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: _selectedFitnessLevel == option['level']
                                                ? const Color(0xFF265E43)
                                                : Colors.transparent,
                                          ),
                                          child: _selectedFitnessLevel == option['level']
                                              ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white))
                                              : null,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                option['level']!,
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                option['description']!,
                                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Frage 2
                          _buildQuestionBox(
                            title: '2. Deine Ziele',
                            child: Column(
                              children: List.generate(_goalsOptions.length, (index) {
                                final option = _goalsOptions[index];
                                return GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    setState(() {
                                      _goalsOptions[index]['selected'] = !_goalsOptions[index]['selected'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: option['selected']
                                                  ? const Color(0xFF265E43)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: option['selected'] ? const Color(0xFF265E43) : Colors.transparent,
                                          ),
                                          child: option['selected']
                                              ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white))
                                              : null,
                                        ),
                                        Expanded(
                                          child: Text(
                                            option['label'],
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Continue Button
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitAndContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF265E43),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                                    : const Text(
                                  'Weiter zu den Übungen',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Home Indicator
                Container(
                  color: const Color(0xFFE8E8E8),
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Center(
                    child: Container(
                      width: 128,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
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
                          const Text('Fragebogen wird gespeichert...'),
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

  Widget _buildQuestionBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF265E43).withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF265E43),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}