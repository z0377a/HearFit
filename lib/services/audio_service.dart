import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudio;

  // Singleton Zugriff
  static AudioService get instance => _instance;

  // Audio abspielen
  Future<void> playAudio(String assetPath, { VoidCallback? onComplete }) async {
    try {
      // Stoppe vorherige Wiedergabe
      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      // Lade und spiele Audio
      await _audioPlayer.play(AssetSource(assetPath));
      _isPlaying = true;
      _currentAudio = assetPath;

      // Überwache wann die Wiedergabe endet
      _audioPlayer.onPlayerComplete.listen((event) {
        _isPlaying = false;
        _currentAudio = null;
        if (onComplete != null) {
          onComplete();
        }
      });

      print('Spiele Audio: $assetPath');
    } catch (e) {
      print('Fehler beim Abspielen: $e');
    }
  }

  // Audio pausieren
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  // Audio fortsetzen
  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  // Audio stoppen
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentAudio = null;
  }

  // Prüfen ob gerade ein Audio läuft
  bool get isPlaying => _isPlaying;

  // Aktuelles Audio
  String? get currentAudio => _currentAudio;

  // Lautstärke setzen (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
  }
}