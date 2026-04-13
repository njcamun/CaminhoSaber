// lib/providers/pomodoro_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

enum PomodoroStatus { foco, pausa, inativo }

class PomodoroProvider with ChangeNotifier {
  bool _isHabilitado = false;
  int _segundosRestantes = 1500; // 25 minutos
  PomodoroStatus _status = PomodoroStatus.inativo;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Stream para notificar eventos de mudança de estado (para exibir diálogos)
  final _eventController = StreamController<PomodoroStatus>.broadcast();
  Stream<PomodoroStatus> get onStatusChange => _eventController.stream;

  bool get isHabilitado => _isHabilitado;
  int get segundosRestantes => _segundosRestantes;
  PomodoroStatus get status => _status;

  PomodoroProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isHabilitado = prefs.getBool('pomodoroHabilitado') ?? false;
    if (_isHabilitado) {
      _startPomodoro(notify: false);
    }
    notifyListeners();
  }

  Future<void> togglePomodoro(bool value) async {
    _isHabilitado = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pomodoroHabilitado', value);
    
    if (_isHabilitado) {
      _startPomodoro();
    } else {
      _stopPomodoro();
    }
    notifyListeners();
  }

  void _startPomodoro({bool notify = true}) {
    _status = PomodoroStatus.foco;
    _segundosRestantes = 1500; // 25 min
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        _segundosRestantes--;
        notifyListeners();
      } else {
        _switchStatus();
      }
    });
    if (notify) _eventController.add(PomodoroStatus.foco);
  }

  void _stopPomodoro() {
    _status = PomodoroStatus.inativo;
    _timer?.cancel();
    _timer = null;
    _eventController.add(PomodoroStatus.inativo);
  }

  void _switchStatus() {
    if (_status == PomodoroStatus.foco) {
      _status = PomodoroStatus.pausa;
      _segundosRestantes = 300; // 5 min
      _playAlert();
      _eventController.add(PomodoroStatus.pausa);
    } else {
      _status = PomodoroStatus.foco;
      _segundosRestantes = 1500;
      _playAlert();
      _eventController.add(PomodoroStatus.foco);
    }
    notifyListeners();
  }

  void _playAlert() async {
    await _audioPlayer.play(AssetSource('sounds/hint.mp3'));
  }

  String get tempoFormatado {
    int minutos = _segundosRestantes ~/ 60;
    int segundos = _segundosRestantes % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _eventController.close();
    super.dispose();
  }
}
