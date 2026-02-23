import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Frage 1: Fitness-Level & Erfahrung (Radio-Buttons)
  String? _selectedFitnessLevel;
  final List<Map<String, String>> _fitnessLevelOptions = [
    {
      'level': 'Anfänger',
      'description': 'Ich fange gerade erst mit Sport an.',
    },
    {
      'level': 'Moderat',
      'description': 'Ich habe eine lange Zeit keinen Sport/Übungen gemacht.',
    },
    {
      'level': 'Fortgeschritten',
      'description': 'Ich mache regelmäßig Übungen.',
    },
    {
      'level': 'Experte',
      'description': 'Ich bin sehr fit und suche neue Herausforderungen.',
    },
  ];

  // Frage 2: Deine Ziele (Mehrfachauswahl möglich)
  final Map<String, bool> _goals = {
    'Ausdauer verbessern': false,
    'Beweglichkeit & Dehnung': false,
    'Gewichtsreduktion': false,
    'Sicherheit in der alltäglichen Orientierung / Koordination': false,
  };

  void _submitAndContinue() {
    // Prüfen ob Fitness-Level ausgewählt wurde
    if (_selectedFitnessLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle dein Fitness-Level aus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prüfen ob mindestens ein Ziel ausgewählt wurde
    bool hasGoal = _goals.values.contains(true);
    if (!hasGoal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle mindestens ein Ziel aus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hier könntest du die Antworten speichern

    // Weiter zu Übungen
    Navigator.pushReplacementNamed(context, '/exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Präferenzen'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Fortschrittsanzeige
            LinearProgressIndicator(
              value: 0.66,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('Schritt 2 von 2: Deine Präferenzen'),

            const SizedBox(height: 20),

            // Frage 1: Fitness-Level & Erfahrung
            _buildQuestionBox(
              title: '1. Fitness-Level & Erfahrung',
              child: Column(
                children: _fitnessLevelOptions.map((option) {
                  return RadioListTile<String>(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['level']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          option['description']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    value: option['level']!,
                    groupValue: _selectedFitnessLevel,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedFitnessLevel = value;
                      });
                    },
                    activeColor: Colors.blue,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Frage 2: Deine Ziele
            _buildQuestionBox(
              title: '2. Deine Ziele',
              child: Column(
                children: _goals.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _goals[key],
                    onChanged: (bool? value) {
                      setState(() {
                        _goals[key] = value ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Weiter Button
            Center(
              child: ElevatedButton(
                onPressed: _submitAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text(
                  'Weiter zu den Übungen',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Hilfsfunktion für einheitliche blaue Boxen
  Widget _buildQuestionBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}