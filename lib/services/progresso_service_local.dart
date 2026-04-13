// lib/services/progresso_service_local.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProgressoServiceLocal with ChangeNotifier {
  static const String _progressoKey = 'progresso_quizzes';
  int _totalPontos = 0;
  Map<String, int> _progressoPorCapitulo = {};

  int get totalPontos => _totalPontos;
  Map<String, int> get progressoPorCapitulo => _progressoPorCapitulo;

  ProgressoServiceLocal() {
    _loadProgresso();
  }

  Future<void> _loadProgresso() async {
    final prefs = await SharedPreferences.getInstance();
    final progressoJson = prefs.getString(_progressoKey);
    final Map<String, dynamic> progressoMap = progressoJson != null
        ? json.decode(progressoJson) as Map<String, dynamic>
        : {};

    int total = 0;
    _progressoPorCapitulo = {};

    progressoMap.forEach((key, value) {
      total += value as int;
      _progressoPorCapitulo[key] = value;
    });
    _totalPontos = total;
    notifyListeners();
  }

  Future<void> saveProgresso(String capituloId, int pontuacao) async {
    final prefs = await SharedPreferences.getInstance();

    await _loadProgresso();

    if (_progressoPorCapitulo[capituloId] == null || pontuacao > (_progressoPorCapitulo[capituloId] ?? 0)) {
      if (_progressoPorCapitulo.containsKey(capituloId)) {
        _totalPontos -= _progressoPorCapitulo[capituloId]!;
      }
      _progressoPorCapitulo[capituloId] = pontuacao;
      _totalPontos += pontuacao;

      final progressoJson = json.encode(_progressoPorCapitulo);
      await prefs.setString(_progressoKey, progressoJson);
    }

    notifyListeners();
  }

  // NOVO: Método para obter o progresso de uma disciplina
  int getProgressoDisciplina(String disciplinaId) {
    int capitulosConcluidos = 0;
    for (var key in _progressoPorCapitulo.keys) {
      if (key.startsWith(disciplinaId)) {
        capitulosConcluidos++;
      }
    }
    return capitulosConcluidos;
  }

  // NOVO: Verifica se um capítulo foi concluído.
  bool isCapituloConcluido(String capituloId) {
    return _progressoPorCapitulo.containsKey(capituloId);
  }

  // NOVO: Método para obter o progresso de uma disciplina.
  Future<Map<String, int>> getProgresso(String disciplinaId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressoJson = prefs.getString(_progressoKey);
    final Map<String, dynamic> progressoMap = progressoJson != null
        ? json.decode(progressoJson) as Map<String, dynamic>
        : {};

    final Map<String, int> progressoPorDisciplina = {};
    progressoMap.forEach((key, value) {
      if (key.startsWith(disciplinaId)) {
        progressoPorDisciplina[key] = value as int;
      }
    });

    return progressoPorDisciplina;
  }
}
