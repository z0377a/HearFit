import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erfolgreich eingeloggt!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, '/exercises');
          });
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = _getLoginErrorMessage(e);
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

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte E-Mail für Passwort-Reset eingeben'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwort-Reset E-Mail wurde gesendet!'),
            backgroundColor: Colors.green,
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
    }
  }

  String _getLoginErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Kein Benutzer mit dieser E-Mail gefunden';
      case 'wrong-password':
        return 'Falsches Passwort';
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse';
      case 'user-disabled':
        return 'Dieser Benutzer wurde deaktiviert';
      case 'too-many-requests':
        return 'Zu viele fehlgeschlagene Versuche. Bitte später erneut versuchen';
      default:
        return 'Login fehlgeschlagen: ${e.message}';
    }
  }

  String _getGuestErrorMessage(FirebaseAuthException e) {
    if (e.code == 'operation-not-allowed') {
      return 'Anonyme Anmeldung ist nicht aktiviert';
    }
    return 'Fehler beim Gast-Zugang: ${e.message}';
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-Mail:',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade800, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bitte E-Mail eingeben';
                    if (!value.contains('@') || !value.contains('.')) return 'Ungültige E-Mail-Adresse';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 56),
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
          'Passwort:',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade800, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Bitte Passwort eingeben';
                    return null;
                  },
                ),
              ),
              Container(
                width: 56,
                child: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                  onPressed: _isLoading ? null : () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  padding: EdgeInsets.zero,
                ),
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
                          'Anmelden',
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
                    color: const Color(0xFFE8E8E8),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'E-Mail und\nPasswort eingeben:',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildEmailField(),
                            const SizedBox(height: 20),
                            _buildPasswordField(),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _resetPassword,
                                child: Text(
                                  'Passwort vergessen?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF265E43),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
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
                                  'Anmelden',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Column(
                                children: [
                                  const Text(
                                    'Noch kein Konto?',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: _isLoading ? null : () {
                                      Navigator.pushReplacementNamed(context, '/register');
                                    },
                                    child: Text(
                                      'Registrieren',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF265E43),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
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
                          const Text(
                            'Anmeldung wird durchgeführt...',
                            style: TextStyle(fontSize: 16),
                          ),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}