import 'package:flutter/material.dart';

class RestrictionsScreen extends StatefulWidget {
  const RestrictionsScreen({super.key});

  @override
  State<RestrictionsScreen> createState() => _RestrictionsScreenState();
}

class _RestrictionsScreenState extends State<RestrictionsScreen> {
  // Frage 1: Art der Sehbeeinträchtigung
  String? _selectedVisualImpairment;
  final List<String> _visualImpairmentOptions = [
    'Vollständig blind',
    'Sehbehindert (starke Einschränkung trotz Brille)',
    'Farbenblindheit / Kontrastschwäche',
  ];

  // Frage 2: Nutzung von Hilfsmitteln (Mehrfachauswahl möglich)
  final Map<String, bool> _assistiveTools = {
    'Screenreader (VoiceOver / Talkback)': false,
    'Vergrößerungssoftware / Zoom-Funktion': false,
    'Hoher Kontrast / Umgekehrte Farben': false,
    'Keine speziellen digitalen Hilfsmittel': false,
  };

  // Frage 3: Besondere Sicherheitsaspekte (Mehrfachauswahl möglich)
  final Map<String, bool> _safetyAspects = {
    'Gleichgewichtsprobleme': false,
    'Gelenkschmerzen oder Vorerkrankungen': false,
    'Einnahme von Medikamenten, die den Kreislauf beeinflussen': false,
    'Keine Einschränkungen': false,
  };

  // Zusätzliches Textfeld für Medikamentendetails
  final TextEditingController _medicationDetailsController = TextEditingController();
  bool _showMedicationField = false;

  void _submitAndContinue() {
    // Prüfen ob Frage 1 beantwortet wurde
    if (_selectedVisualImpairment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle deine Art der Sehbeeinträchtigung aus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prüfen ob Frage 2 beantwortet wurde (mindestens eine Auswahl)
    bool hasAssistiveTool = _assistiveTools.values.contains(true);
    if (!hasAssistiveTool) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle mindestens ein Hilfsmittel aus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prüfen ob Frage 3 beantwortet wurde (mindestens eine Auswahl)
    bool hasSafetyAspect = _safetyAspects.values.contains(true);
    if (!hasSafetyAspect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wähle mindestens einen Sicherheitsaspekt aus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Prüfen ob Medikamentendetails eingegeben werden müssen
    if (_safetyAspects['Einnahme von Medikamenten, die den Kreislauf beeinflussen'] == true &&
        _medicationDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gib nähere Informationen zu den Medikamenten ein'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Hier könntest du die Antworten speichern

    // Weiter zu Präferenzen
    Navigator.pushReplacementNamed(context, '/preferences');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fragebogen'),
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
              value: 0.33,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('Schritt 1 von 2: Deine Angaben'),

            const SizedBox(height: 20),

            // Frage 1: Art der Sehbeeinträchtigung
            _buildQuestionBox(
              title: '1. Art der Sehbeeinträchtigung',
              child: Column(
                children: _visualImpairmentOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedVisualImpairment,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedVisualImpairment = value;
                      });
                    },
                    activeColor: Colors.blue,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Frage 2: Nutzung von Hilfsmitteln
            _buildQuestionBox(
              title: '2. Nutzung von Hilfsmitteln',
              child: Column(
                children: _assistiveTools.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _assistiveTools[key],
                    onChanged: (bool? value) {
                      setState(() {
                        _assistiveTools[key] = value ?? false;

                        // Wenn "Keine speziellen digitalen Hilfsmittel" ausgewählt wird,
                        // alle anderen Optionen deaktivieren
                        if (key == 'Keine speziellen digitalen Hilfsmittel' && value == true) {
                          for (var k in _assistiveTools.keys) {
                            if (k != 'Keine speziellen digitalen Hilfsmittel') {
                              _assistiveTools[k] = false;
                            }
                          }
                        }

                        // Wenn eine andere Option ausgewählt wird, "Keine speziellen digitalen Hilfsmittel" deaktivieren
                        if (key != 'Keine speziellen digitalen Hilfsmittel' && value == true) {
                          _assistiveTools['Keine speziellen digitalen Hilfsmittel'] = false;
                        }
                      });
                    },
                    activeColor: Colors.blue,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Frage 3: Besondere Sicherheitsaspekte
            _buildQuestionBox(
              title: '3. Besondere Sicherheitsaspekte',
              child: Column(
                children: [
                  ..._safetyAspects.keys.map((String key) {
                    return CheckboxListTile(
                      title: Text(key),
                      value: _safetyAspects[key],
                      onChanged: (bool? value) {
                        setState(() {
                          _safetyAspects[key] = value ?? false;

                          // Wenn "Keine Einschränkungen" ausgewählt wird,
                          // alle anderen Optionen deaktivieren
                          if (key == 'Keine Einschränkungen' && value == true) {
                            for (var k in _safetyAspects.keys) {
                              if (k != 'Keine Einschränkungen') {
                                _safetyAspects[k] = false;
                              }
                            }
                            _showMedicationField = false;
                          }

                          // Wenn eine andere Option ausgewählt wird, "Keine Einschränkungen" deaktivieren
                          if (key != 'Keine Einschränkungen' && value == true) {
                            _safetyAspects['Keine Einschränkungen'] = false;
                          }

                          // Medikamenten-Feld anzeigen wenn ausgewählt
                          if (key == 'Einnahme von Medikamenten, die den Kreislauf beeinflussen') {
                            _showMedicationField = value ?? false;
                          }
                        });
                      },
                      activeColor: Colors.blue,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  }).toList(),

                  // Zusätzliches Textfeld für Medikamentendetails
                  if (_showMedicationField) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Bitte beschreibe, welche Medikamente du einnimmst und wie lange/oft Pausen benötigt werden:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _medicationDetailsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'z.B. "Blutdrucksenker, alle 4 Stunden eine Pause nötig"',
                      ),
                    ),
                  ],
                ],
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
                  'Weiter zu Präferenzen',
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

  @override
  void dispose() {
    _medicationDetailsController.dispose();
    super.dispose();
  }
}