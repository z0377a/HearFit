import 'package:flutter/material.dart';
import 'exercise_detail_screen.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  // Übungen aus der Tabelle
  final List<Map<String, dynamic>> _exercises = [
    {
      'id': 1,
      'name': 'Kniebeuge',
      'category': 'Kraft',
      'tags': ['Mobilität', 'Stabilität'],
      'icon': Icons.fitness_center,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': 'audio/kniebeuge.mp3',
      'description': 'Kräftigt die Beinmuskulatur und verbessert die Stabilität im Alltag.',
    },
    {
      'id': 2,
      'name': 'Marschieren',
      'category': 'Aufwärmen',
      'tags': ['Mobilität', 'Kraft', 'Balance'],
      'icon': Icons.directions_walk,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': 'audio/marschieren.mp3',
      'description': 'Lockert die Gelenke und fördert die Durchblutung.',
    },
    {
      'id': 3,
      'name': 'Kräftigung seitliche Hüftmuskulatur',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': 'audio/huefte_seitlich.mp3',
      'description': 'Stärkt die seitliche Hüftmuskulatur und verbessert die Stabilität beim Gehen.',
    },
    {
      'id': 4,
      'name': 'Einbeinstand mit/ohne abstützen',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.accessibility,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Verbessert das Gleichgewicht und die Standfestigkeit.',
    },
    {
      'id': 5,
      'name': 'Fersen-Zehen Gang',
      'category': 'Balance',
      'tags': ['Mobilität'],
      'icon': Icons.straighten,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Trainiert die Koordination und das Gleichgewicht.',
    },
    {
      'id': 6,
      'name': 'Knie anheben/zusich ziehen',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.airline_seat_legroom_normal,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Stärkt die Hüftbeuger und verbessert die Beweglichkeit.',
    },
    {
      'id': 7,
      'name': 'Abwechselnde Boxschläge',
      'category': 'Kraft',
      'tags': ['Mobilität'],
      'icon': Icons.sports_mma,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Verbessert die Koordination und Reaktionsfähigkeit.',
    },
    {
      'id': 8,
      'name': 'Wadendehnung',
      'category': 'Dehnung',
      'tags': ['Mobilität', 'Stabilität'],
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Dehnt die Wadenmuskulatur und beugt Verspannungen vor.',
    },
    {
      'id': 9,
      'name': 'Dehnung Oberschenkelrückseite',
      'category': 'Dehnung',
      'tags': ['Mobilität', 'Stabilität'],
      'icon': Icons.self_improvement,
      'color': const Color(0xFF265E43), // 🔴 NEUE FARBE
      'audioPath': null,
      'description': 'Dehnt die Oberschenkelrückseite und verbessert die Beweglichkeit.',
    },
  ];

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erfolgreich ausgeloggt'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ausloggen'),
          content: const Text('Möchtest du dich wirklich ausloggen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Ausloggen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deine Übungen'),
        centerTitle: true,
        backgroundColor: const Color(0xFF265E43), // 🔴 NEUE FARBE
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _showLogoutDialog,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Überschrift
            const Text(
              'Deine Übungen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Übungen Liste
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return _buildExerciseCard(
                    exercise['id'],
                    exercise['name'],
                    exercise['category'],
                    exercise['tags'],
                    exercise['icon'],
                    exercise['color'],
                    exercise['audioPath'],
                    exercise['description'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      int id,
      String title,
      String category,
      List<String> tags,
      IconData icon,
      Color color,
      String? audioPath,
      String description,
      ) {
    final hasAudio = audioPath != null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF265E43), // 🔴 NEUE FARBE
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(
                exerciseId: id,
                exerciseName: title,
                audioPath: audioPath,
                description: description,
                icon: icon,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // ID-Anzeige
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF265E43), width: 1), // 🔴 NEUE FARBE
                ),
                child: Center(
                  child: Text(
                    '$id',
                    style: TextStyle(
                      color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Icon mit Audio-Indikator
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF265E43), size: 30), // 🔴 NEUE FARBE
                  ),
                  if (hasAudio)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF265E43), // 🔴 NEUE FARBE
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.music_note,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Titel und Tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasAudio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.audio_file,
                                  size: 12,
                                  color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Audio',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Kategorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Tags
                    Wrap(
                      spacing: 4,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Play Button
              Icon(
                Icons.play_circle_fill,
                color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}