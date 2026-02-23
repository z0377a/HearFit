import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  void _registerAndContinue() {
    if (_formKey.currentState!.validate()) {
      // Hier könntest du die Daten speichern (SharedPreferences oder Datenbank)

      // Erfolgsmeldung
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrierung erfolgreich!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      // Weiter zum Fragebogen (Einschränkungen)
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacementNamed(context, '/restrictions');
      });
    }
  }

  void _continueAsGuest() {
    // Gast direkt zu den Übungen ohne Fragebogen
    Navigator.pushReplacementNamed(context, '/exercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrieren'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Überschrift
              const Center(
                child: Text(
                  'Konto erstellen',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Vor- und Nachname
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vor- und Nachname *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Max Mustermann',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihren Namen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Alter
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ihr Alter *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                  hintText: 'z.B. 25',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihr Alter ein';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Bitte eine gültige Zahl eingeben';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Passwort-Feld
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Ihr Passwort',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie ein Passwort ein';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Registrieren Button
              Center(
                child: ElevatedButton(
                  onPressed: _registerAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Registrieren',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Gast-Option (ohne ODER-Trennlinie)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.shade300, width: 2),
                ),
                child: InkWell(
                  onTap: _continueAsGuest,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Als Gast fortfahren?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Direkt zu den Übungen - ohne Fragebogen',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Login Link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Bereits ein Konto? Hier anmelden',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}