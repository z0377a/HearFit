import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final String? audioPath;
  final String description;
  final IconData icon;
  final int exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    this.audioPath,
    required this.description,
    required this.icon,
    required this.exerciseId,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _playAudio() async {
    if (widget.audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Für diese Übung ist noch kein Audio verfügbar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position == Duration.zero) {
          await _audioPlayer.play(AssetSource(widget.audioPath!));
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Abspielen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  Future<void> _seekAudio(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAudio = widget.audioPath != null;

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF265E43), // 🔴 NEUE FARBE
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Exercise Icon
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF265E43), width: 3), // 🔴 NEUE FARBE
                      ),
                      child: Icon(
                        widget.icon,
                        size: 80,
                        color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Exercise Name
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Audio Player Card
                    if (hasAudio) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Waveform Animation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(20, (index) {
                                return Container(
                                  width: 4,
                                  height: _isPlaying ? 20 + (index % 5) * 5.0 : 15,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 16),

                            // Time Display
                            if (_duration > Duration.zero)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(_position),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      _formatDuration(_duration),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                            // Progress Slider
                            if (_duration > Duration.zero)
                              Slider(
                                value: _position.inSeconds.toDouble(),
                                min: 0,
                                max: _duration.inSeconds.toDouble(),
                                onChanged: _seekAudio,
                                activeColor: const Color(0xFF265E43), // 🔴 NEUE FARBE
                                inactiveColor: Colors.grey.shade300,
                              ),

                            const SizedBox(height: 8),

                            // Play/Pause Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Stop Button
                                IconButton(
                                  icon: const Icon(Icons.stop, size: 32),
                                  color: Colors.red,
                                  onPressed: _isPlaying ? _stopAudio : null,
                                ),

                                const SizedBox(width: 20),

                                // Play/Pause Button
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF265E43), // 🔴 NEUE FARBE
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF265E43).withOpacity(0.3), // 🔴 NEUE FARBE
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _isLoading
                                      ? const Center(
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                      : IconButton(
                                    icon: Icon(
                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                    onPressed: _playAudio,
                                  ),
                                ),

                                const SizedBox(width: 20),

                                // Volume Control
                                PopupMenuButton<double>(
                                  icon: const Icon(Icons.volume_up, size: 28),
                                  color: Colors.white,
                                  onSelected: (value) {
                                    setState(() => _volume = value);
                                    _audioPlayer.setVolume(value);
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 1.0,
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_up, color: const Color(0xFF265E43)), // 🔴 NEUE FARBE
                                          const SizedBox(width: 8),
                                          const Text('100%'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 0.7,
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_down, color: const Color(0xFF265E43)), // 🔴 NEUE FARBE
                                          const SizedBox(width: 8),
                                          const Text('70%'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 0.5,
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_mute, color: const Color(0xFF265E43)), // 🔴 NEUE FARBE
                                          const SizedBox(width: 8),
                                          const Text('50%'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 0.0,
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_off, color: const Color(0xFF265E43)), // 🔴 NEUE FARBE
                                          const SizedBox(width: 8),
                                          const Text('Stumm'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Platzhalter für Übungen ohne Audio
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Für diese Übung ist noch kein Audio verfügbar',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Instructions
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF265E43).withOpacity(0.1), // 🔴 NEUE FARBE
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF265E43), width: 1), // 🔴 NEUE FARBE
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: const Color(0xFF265E43)), // 🔴 NEUE FARBE
                              const SizedBox(width: 8),
                              const Text(
                                'Anleitung:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Setze dich bequem hin oder stehe aufrecht\n'
                                '2. Höre dir die Audio-Anleitung genau an\n'
                                '3. Führe die Übung langsam und kontrolliert aus\n'
                                '4. Wiederhole die Übung 8-12 Mal pro Seite',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}