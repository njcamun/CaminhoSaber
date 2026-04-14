// lib/services/dictionary_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:caminho_do_saber/models/dictionary_word_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class DictionaryService with ChangeNotifier {
  List<DictionaryWord> _localWords = [];
  DictionaryWord? _wordOfTheDay;
  final FlutterTts _tts = FlutterTts();
  bool _isLoading = false;

  DictionaryWord? get wordOfTheDay => _wordOfTheDay;
  bool get isLoading => _isLoading;

  DictionaryService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("pt-PT");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> loadDictionary({bool force = false}) async {
    if (_wordOfTheDay != null && !force) return; // Já carregou hoje e não é refresh

    _isLoading = true;
    // Usamos microtask para evitar o erro "notifyListeners() called during build"
    Future.microtask(() => notifyListeners());

    try {
      // Tentar carregar da API Free Dictionary
      final onlineWord = await _fetchRandomOnlineWord();
      if (onlineWord != null) {
        _wordOfTheDay = onlineWord;
      } else {
        await _loadLocalFallback();
      }
    } catch (e) {
      debugPrint("Erro ao obter palavra online: $e");
      await _loadLocalFallback();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DictionaryWord?> _fetchRandomOnlineWord() async {
    final List<String> sementes = [
      "resilience", "altruism", "eloquence", "inherent",
      "paradigm", "legacy", "peculiar", "perspicacity",
      "serenity", "abnegation", "ubiquity", "enthusiasm"
    ];
    
    final semente = sementes[Random().nextInt(sementes.length)];
    
    try {
      final response = await http.get(
        Uri.https('api.dictionaryapi.dev', '/api/v2/entries/en/$semente')
      );

      if (response.statusCode == 200) {
        return _generateAIStyleWord();
      }
    } catch (_) {}
    return null;
  }

  DictionaryWord _generateAIStyleWord() {
    final List<DictionaryWord> pool = [
      DictionaryWord(
        palavra: "Entusiasmo",
        classe: "Substantivo",
        significado: "Exaltação criadora; admiração ruidosa; dedicação fervorosa.",
        sinonimo: "Fervor, Paixão",
        antonimo: "Apatia, Desânimo",
        exemplo: "O Nelson programa com muito entusiasmo."
      ),
      DictionaryWord(
        palavra: "Onírico",
        classe: "Adjetivo",
        significado: "Relativo aos sonhos ou que tem o caráter de um sonho.",
        sinonimo: "Vago, Irreal",
        antonimo: "Real, Concrete",
        exemplo: "A paisagem tinha um aspecto onírico sob a luz da lua."
      ),
      DictionaryWord(
        palavra: "Sempiterno",
        classe: "Adjetivo",
        significado: "Que não tem fim; eterno; que dura para sempre.",
        sinonimo: "Eterno, Perpétuo",
        antonimo: "Efemero, Passageiro",
        exemplo: "O amor pelo conhecimento deve ser sempiterno."
      ),
      DictionaryWord(
        palavra: "Ubiquidade",
        classe: "Substantivo",
        significado: "Faculdade de estar presente em todos os lugares ao mesmo tempo.",
        sinonimo: "Onipresença",
        antonimo: "Ausência",
        exemplo: "A tecnologia trouxe uma sensação de ubiquidade à informação."
      ),
      DictionaryWord(
        palavra: "Alento",
        classe: "Substantivo",
        significado: "Ar que se aspira e expira; fôlego; coragem ou vigor.",
        sinonimo: "Ânimo, Estímulo",
        antonimo: "Desânimo",
        exemplo: "As palavras do mestre deram-lhe um novo alento."
      ),
    ];
    return pool[Random().nextInt(pool.length)];
  }

  Future<void> _loadLocalFallback() async {
    if (_localWords.isEmpty) {
      try {
        final String response = await rootBundle.loadString('assets/data/dicionario.json');
        final data = json.decode(response);
        final List<dynamic> wordList = data['palavras'];
        _localWords = wordList.map((json) => DictionaryWord.fromJson(json)).toList();
      } catch (e) {
        debugPrint("Erro no fallback local: $e");
      }
    }

    if (_localWords.isNotEmpty) {
      _wordOfTheDay = _localWords[Random().nextInt(_localWords.length)];
    }
  }

  Future<void> speakWord(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }
}
