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
    try {
      final prefs = await SharedPreferences.getInstance();
      _audioEnabled = prefs.getBool('audioEnabled') ?? true;
      _volume = prefs.getDouble('volumeGeral') ?? 1.0;

      // Pre-initialize players for common sounds to reduce delay on Web
      if (kIsWeb) {
        // Não usamos await aqui para não bloquear a inicialização se o browser barrar o áudio
        _preloadSfx('correct.mp3');
        _preloadSfx('incorrect.mp3');
        _preloadSfx('hint.mp3');
        _preloadSfx('jogo.mp3');
      }
    } catch (e) {
      debugPrint('Erro ao inicializar AudioService: $e');
    }
  }

  Future<void> _preloadSfx(String fileName) async {
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource('sounds/$fileName'));
      await player.setVolume(0); // Começa mudo para "aquecer"
      // No Web, o play() pode falhar sem interação do utilizador, por isso ignoramos erros aqui
      await player.play(AssetSource('sounds/$fileName')).catchError((e) => debugPrint('Preload play ignored: $e'));
      await player.stop();
      await player.setVolume(_volume);
      _sfxPlayers[fileName] = player;
    } catch (e) {
      debugPrint('Erro ao fazer preload de $fileName: $e');
    }
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
