import 'package:flutter/material.dart';

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
      'color': Colors.blue,
      'videoUrl': 'assets/videos/kniebeuge.mp4',
    },
    {
      'id': 2,
      'name': 'Marschieren',
      'category': 'Aufwärmen',
      'tags': ['Mobilität', 'Kraft', 'Balance'],
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'videoUrl': 'assets/videos/marschieren.mp4',
    },
    {
      'id': 3,
      'name': 'Kräftigung seitliche Hüftmuskulatur',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.accessibility_new,
      'color': Colors.orange,
      'videoUrl': 'assets/videos/huefte.mp4',
    },
    {
      'id': 4,
      'name': 'Einbeinstand mit/ohne abstützen',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.accessibility,
      'color': Colors.purple,
      'videoUrl': 'assets/videos/einbeinstand.mp4',
    },
    {
      'id': 5,
      'name': 'Fersen-Zehen Gang',
      'category': 'Balance',
      'tags': ['Mobilität'],
      'icon': Icons.straighten,
      'color': Colors.teal,
      'videoUrl': 'assets/videos/fersen-zehen.mp4',
    },
    {
      'id': 6,
      'name': 'Knie anheben/zusich ziehen',
      'category': 'Kraft',
      'tags': ['Balance', 'Mobilität'],
      'icon': Icons.airline_seat_legroom_normal,
      'color': Colors.red,
      'videoUrl': 'assets/videos/knie-anheben.mp4',
    },
    {
      'id': 7,
      'name': 'Abwechselnde Boxschläge',
      'category': 'Kraft',
      'tags': ['Mobilität'],
      'icon': Icons.sports_mma,
      'color': Colors.brown,
      'videoUrl': 'assets/videos/boxschlage.mp4',
    },
    {
      'id': 8,
      'name': 'Wadendehnung',
      'category': 'Dehnung',
      'tags': ['Mobilität', 'Stabilität'],
      'icon': Icons.accessibility_new,
      'color': Colors.pink,
      'videoUrl': 'assets/videos/wadendehnung.mp4',
    },
    {
      'id': 9,
      'name': 'Dehnung Oberschenkelrückseite',
      'category': 'Dehnung',
      'tags': ['Mobilität', 'Stabilität'],
      'icon': Icons.self_improvement,
      'color': Colors.indigo,
      'videoUrl': 'assets/videos/oberschenkel.mp4',
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
        backgroundColor: Colors.blue,
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Logout als Text in rot
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
                    exercise['videoUrl'],
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
      String videoUrl,
      ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showExerciseVideo(id, title, category, tags, videoUrl),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 1),
                ),
                child: Center(
                  child: Text(
                    '$id',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 12),

              // Titel und Tags
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Kategorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
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
                color: color,
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseVideo(int id, String title, String category, List<String> tags, String videoUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Griff zum Ziehen
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ID und Titel
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$id',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Video-Container (Platzhalter)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      child: Text(
                        'Video-Demo (noch nicht verfügbar)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Kategorie
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tags
              const Text(
                'Tags:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Beschreibung
              const Text(
                'Beschreibung:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hier kommt die detaillierte Beschreibung für Übung #$id: $title. '
                    'Diese Übung trainiert $category und verbessert '
                    '${tags.join(" und ")}.',
                style: const TextStyle(fontSize: 14),
              ),

              const Spacer(),

              // Hinweis
              Center(
                child: Text(
                  '⚠️ Video folgt in der nächsten Version',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}