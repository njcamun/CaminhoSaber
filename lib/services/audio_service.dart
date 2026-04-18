import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Map<String, AudioPlayer> _sfxPlayers = {};
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  bool _audioEnabled = true;
  double _volume = 1.0;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _audioEnabled = prefs.getBool('audioEnabled') ?? true;
    _volume = prefs.getDouble('volumeGeral') ?? 1.0;

    // Pre-initialize players for common sounds to reduce delay on Web
    if (kIsWeb) {
      await _preloadSfx('acerto.mp3');
      await _preloadSfx('erro.mp3');
      await _preloadSfx('hint.mp3');
      await _preloadSfx('jogo.mp3');
    }
  }

  Future<void> _preloadSfx(String fileName) async {
    final player = AudioPlayer();
    await player.setSource(AssetSource('sounds/$fileName'));
    _sfxPlayers[fileName] = player;
  }

  Future<void> playSfx(String fileName) async {
    if (!_audioEnabled) return;

    try {
      if (_sfxPlayers.containsKey(fileName)) {
        final player = _sfxPlayers[fileName]!;
        await player.stop();
        await player.resume();
      } else {
        // Fallback for sounds not preloaded
        final player = AudioPlayer();
        await player.setVolume(_volume);
        await player.play(AssetSource('sounds/$fileName'));
        player.onPlayerComplete.listen((_) => player.dispose());
      }
    } catch (e) {
      debugPrint('Error playing SFX $fileName: $e');
    }
  }

  Future<void> playMusic(String fileName, {bool loop = true}) async {
    if (!_audioEnabled) return;

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(_volume * 0.6);
      if (loop) {
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      }
      await _musicPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('Error playing music $fileName: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  void updateSettings(bool enabled, double volume) {
    _audioEnabled = enabled;
    _volume = volume;
    _musicPlayer.setVolume(enabled ? volume * 0.6 : 0);
    for (var player in _sfxPlayers.values) {
      player.setVolume(enabled ? volume : 0);
    }
  }
}
