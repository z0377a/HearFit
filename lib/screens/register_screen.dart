import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _loadingMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );

    if (!email.contains('@') || !email.contains('.')) return false;
    if (email.startsWith('.') || email.endsWith('.')) return false;
    if (email.contains(' ')) return false;

    List<String> parts = email.split('@');
    if (parts.length != 2) return false;

    String localPart = parts[0];
    String domain = parts[1];

    if (localPart.isEmpty || domain.isEmpty) return false;
    if (localPart.length < 1 || domain.length < 3) return false;
    if (!domain.contains('.')) return false;
    if (domain.startsWith('.') || domain.endsWith('.')) return false;

    return emailRegex.hasMatch(email);
  }

  void _registerAndContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loadingMessage = 'Registrierung wird durchgeführt...';
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          String fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

          await _database.child('users').child(user.uid).set({
            'name': fullName,
            'email': _emailController.text.trim(),
            'createdAt': DateTime.now().toIso8601String(),
            'userType': 'registered',
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrierung erfolgreich!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pushReplacementNamed(context, '/restrictions');
            });
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = _getFirebaseErrorMessage(e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
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
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _loadingMessage = 'Gast-Zugang wird eingerichtet...';
      _isLoading = true;
    });

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
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getGuestErrorMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
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

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Diese Email wird bereits verwendet';
      case 'weak-password':
        return 'Das Passwort ist zu schwach (mind. 6 Zeichen)';
      case 'invalid-email':
        return 'Ungültige Email-Adresse';
      case 'operation-not-allowed':
        return 'Email/Passwort Registrierung ist nicht aktiviert';
      default:
        return 'Registrierung fehlgeschlagen: ${e.message}';
    }
  }

  String _getGuestErrorMessage(FirebaseAuthException e) {
    if (e.code == 'operation-not-allowed') {
      return 'Anonyme Anmeldung ist nicht aktiviert. Bitte in Firebase Console aktivieren.';
    }
    return 'Fehler beim Gast-Zugang: ${e.message}';
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-Mail',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.email_outlined, color: Colors.grey.shade600, size: 24),
              ),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'E-Mail',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bitte E-Mail eingeben';
                    if (!_isValidEmail(value)) return 'Bitte eine gültige E-Mail-Adresse eingeben';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(icon, color: Colors.grey.shade600, size: 24),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  enabled: !_isLoading,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passwort',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.lock, color: Colors.grey.shade600, size: 24),
              ),
              Expanded(
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Passwort',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
                    if (value.length < 6) return 'Passwort muss mindestens 6 Zeichen lang sein';
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                onPressed: _isLoading ? null : () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ],
          ),
        ),
      ],
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Registrieren',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Konto erstellen',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildLabeledField(
                                    label: 'Vorname',
                                    icon: Icons.person,
                                    controller: _firstNameController,
                                    placeholder: 'Vorname',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Bitte Vornamen eingeben';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildLabeledField(
                                    label: 'Nachname',
                                    icon: Icons.person,
                                    controller: _lastNameController,
                                    placeholder: 'Nachname',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Bitte Nachnamen eingeben';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildEmailField(),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerAndContinue,
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
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Registrieren',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Bereits ein Konto? ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _isLoading ? null : () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: Text(
                                    'Hier anmelden',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF265E43),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                          Text(_loadingMessage, style: const TextStyle(fontSize: 16)),
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}