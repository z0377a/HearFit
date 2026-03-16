import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RestrictionsScreen extends StatefulWidget {
  const RestrictionsScreen({super.key});

  @override
  State<RestrictionsScreen> createState() => _RestrictionsScreenState();
}

class _RestrictionsScreenState extends State<RestrictionsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _isLoading = false;

  String? _selectedVisualImpairment;
  final List<String> _visualImpairmentOptions = [
    'Vollständig blind',
    'Sehbehindert (starke Einschränkung trotz Brille)',
    'Farbenblindheit / Kontrastschwäche',
  ];

  final List<Map<String, dynamic>> _assistiveToolsOptions = [
    {'id': 'screenreader', 'label': 'Screenreader (VoiceOver / Talkback)', 'selected': false},
    {'id': 'zoom', 'label': 'Vergrößerungssoftware / Zoom-Funktion', 'selected': false},
    {'id': 'contrast', 'label': 'Hoher Kontrast / Umgekehrte Farben', 'selected': false},
    {'id': 'none', 'label': 'Keine speziellen digitalen Hilfsmittel', 'selected': false},
  ];

  final List<Map<String, dynamic>> _safetyAspectsOptions = [
    {'id': 'balance', 'label': 'Gleichgewichtsprobleme', 'selected': false},
    {'id': 'joint_pain', 'label': 'Gelenkschmerzen oder Vorerkrankungen', 'selected': false},
    {'id': 'medication', 'label': 'Einnahme von Medikamenten, die den Kreislauf beeinflussen', 'selected': false},
    {'id': 'none', 'label': 'Keine Einschränkungen', 'selected': false},
  ];

  final TextEditingController _medicationDetailsController = TextEditingController();
  bool _showMedicationField = false;

  Future<void> _saveRestrictionsData() async {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    List<String> selectedAssistiveTools = [];
    for (var option in _assistiveToolsOptions) {
      if (option['selected'] == true) selectedAssistiveTools.add(option['label']);
    }

    List<String> selectedSafetyAspects = [];
    for (var option in _safetyAspectsOptions) {
      if (option['selected'] == true) selectedSafetyAspects.add(option['label']);
    }

    await _database
        .child('users')
        .child(user.uid)
        .child('temp_questionnaire')
        .set({
      'visualImpairment': _selectedVisualImpairment,
      'assistiveTools': selectedAssistiveTools,
      'safetyAspects': selectedSafetyAspects,
      'medicationDetails': _medicationDetailsController.text,
      'step': 'restrictions_completed',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _submitAndContinue() async {
    if (_selectedVisualImpairment == null) {
      _showError('Bitte wähle deine Art der Sehbeeinträchtigung aus');
      return;
    }

    bool hasAssistiveTool = false;
    for (var option in _assistiveToolsOptions) {
      if (option['selected'] == true) { hasAssistiveTool = true; break; }
    }
    if (!hasAssistiveTool) {
      _showError('Bitte wähle mindestens ein Hilfsmittel aus');
      return;
    }

    bool hasSafetyAspect = false;
    for (var option in _safetyAspectsOptions) {
      if (option['selected'] == true) { hasSafetyAspect = true; break; }
    }
    if (!hasSafetyAspect) {
      _showError('Bitte wähle mindestens einen Sicherheitsaspekt aus');
      return;
    }

    bool medicationSelected = false;
    for (var option in _safetyAspectsOptions) {
      if (option['id'] == 'medication' && option['selected'] == true) {
        medicationSelected = true;
        break;
      }
    }

    if (medicationSelected && _medicationDetailsController.text.isEmpty) {
      _showError('Bitte gib nähere Informationen zu den Medikamenten ein');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _saveRestrictionsData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fragebogen Teil 1 gespeichert'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/preferences');
        });
      }
    } catch (e) {
      if (mounted) _showError('Fehler beim Speichern: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  void _handleAssistiveToolSelection(int index, bool? value) {
    setState(() {
      if (_assistiveToolsOptions[index]['id'] == 'none' && value == true) {
        for (int i = 0; i < _assistiveToolsOptions.length; i++) {
          if (_assistiveToolsOptions[i]['id'] != 'none') {
            _assistiveToolsOptions[i]['selected'] = false;
          }
        }
        _assistiveToolsOptions[index]['selected'] = true;
      } else if (_assistiveToolsOptions[index]['id'] != 'none' && value == true) {
        for (int i = 0; i < _assistiveToolsOptions.length; i++) {
          if (_assistiveToolsOptions[i]['id'] == 'none') {
            _assistiveToolsOptions[i]['selected'] = false;
            break;
          }
        }
        _assistiveToolsOptions[index]['selected'] = value;
      } else {
        _assistiveToolsOptions[index]['selected'] = value ?? false;
      }
    });
  }

  void _handleSafetyAspectSelection(int index, bool? value) {
    setState(() {
      if (_safetyAspectsOptions[index]['id'] == 'none' && value == true) {
        for (int i = 0; i < _safetyAspectsOptions.length; i++) {
          if (_safetyAspectsOptions[i]['id'] != 'none') {
            _safetyAspectsOptions[i]['selected'] = false;
          }
        }
        _safetyAspectsOptions[index]['selected'] = true;
        _showMedicationField = false;
      } else if (_safetyAspectsOptions[index]['id'] != 'none' && value == true) {
        for (int i = 0; i < _safetyAspectsOptions.length; i++) {
          if (_safetyAspectsOptions[i]['id'] == 'none') {
            _safetyAspectsOptions[i]['selected'] = false;
            break;
          }
        }
        _safetyAspectsOptions[index]['selected'] = value ?? false;
        if (_safetyAspectsOptions[index]['id'] == 'medication') {
          _showMedicationField = true;
        }
      } else {
        _safetyAspectsOptions[index]['selected'] = value ?? false;
        if (_safetyAspectsOptions[index]['id'] == 'medication' && value == false) {
          _showMedicationField = false;
          _medicationDetailsController.clear();
        }
      }
    });
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
                          'Einschränkungen',
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
                              widthFactor: 0.5,
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
                            'Schritt 1 von 2: Deine Angaben',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Frage 1
                          _buildQuestionBox(
                            title: '1. Art der Sehbeeinträchtigung',
                            child: Column(
                              children: _visualImpairmentOptions.map((option) {
                                return GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    setState(() => _selectedVisualImpairment = option);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(right: 12),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _selectedVisualImpairment == option
                                                  ? const Color(0xFF265E43)
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: _selectedVisualImpairment == option
                                                ? const Color(0xFF265E43)
                                                : Colors.transparent,
                                          ),
                                          child: _selectedVisualImpairment == option
                                              ? const Center(child: Icon(Icons.check, size: 16, color: Colors.white))
                                              : null,
                                        ),
                                        Expanded(child: Text(option, style: const TextStyle(fontSize: 16))),
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
                            title: '2. Nutzung von Hilfsmitteln',
                            child: Column(
                              children: List.generate(_assistiveToolsOptions.length, (index) {
                                final option = _assistiveToolsOptions[index];
                                return GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    _handleAssistiveToolSelection(index, !option['selected']);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
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
                                        Expanded(child: Text(option['label'], style: const TextStyle(fontSize: 16))),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Frage 3
                          _buildQuestionBox(
                            title: '3. Besondere Sicherheitsaspekte',
                            child: Column(
                              children: [
                                ...List.generate(_safetyAspectsOptions.length, (index) {
                                  final option = _safetyAspectsOptions[index];
                                  return GestureDetector(
                                    onTap: _isLoading ? null : () {
                                      _handleSafetyAspectSelection(index, !option['selected']);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
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
                                          Expanded(child: Text(option['label'], style: const TextStyle(fontSize: 16))),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                if (_showMedicationField) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextField(
                                      controller: _medicationDetailsController,
                                      maxLines: 3,
                                      enabled: !_isLoading,
                                      decoration: const InputDecoration(
                                        hintText: 'Bitte beschreibe, welche Medikamente du einnimmst...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
                                  'Weiter zu Präferenzen',
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

  @override
  void dispose() {
    _medicationDetailsController.dispose();
    super.dispose();
  }
}