// lib/services/disciplina_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:caminho_do_saber/models/conteudo_disciplina_model.dart';

class DisciplinaMetadata {
  final String id;
  final String nome;
  final int totalQuizzes;
  final int totalLeituras;

  DisciplinaMetadata({
    required this.id,
    required this.nome,
    required this.totalQuizzes,
    required this.totalLeituras,
  });
}

class DisciplinaService {
  List<DisciplinaMetadata>? _cachedMetadata;

  Future<List<DisciplinaMetadata>> getDisciplinasMetadata() async {
    if (_cachedMetadata != null) return _cachedMetadata!;

    final String response = await rootBundle.loadString('assets/data/disciplinas.json');
    final List<dynamic> data = json.decode(response);
    
    List<DisciplinaMetadata> metadataList = [];

    for (var item in data) {
      final id = item['id'] as String;
      int totalQuizzesCount = 0;
      int totalLeiturasCount = 0;

      // Conta Capítulos de Quiz
      try {
        final String detailResponse = await rootBundle.loadString('assets/data/$id.json');
        final Map<String, dynamic> detailData = json.decode(detailResponse);
        // O total de quizzes é a quantidade de itens na lista 'quizzes'
        totalQuizzesCount = (detailData['quizzes'] as List?)?.length ?? 0;
      } catch (e) {
        debugPrint('Aviso: Arquivo de quiz $id não encontrado.');
      }

      // Conta Capítulos de Leitura
      try {
        final String conteudoResponse = await rootBundle.loadString('assets/data/${id}_conteudo.json');
        final Map<String, dynamic> conteudoData = json.decode(conteudoResponse);
        totalLeiturasCount = (conteudoData['capitulos'] as List?)?.length ?? 0;
      } catch (e) {
        debugPrint('Aviso: Arquivo de conteúdo $id não encontrado.');
      }

      metadataList.add(DisciplinaMetadata(
        id: id,
        nome: item['nome'],
        totalQuizzes: totalQuizzesCount,
        totalLeituras: totalLeiturasCount,
      ));
    }

    _cachedMetadata = metadataList;
    return metadataList;
  }

  Future<List<ConteudoCapitulo>> getCapitulos(String disciplinaId) async {
    try {
      final String response = await rootBundle.loadString('assets/data/${disciplinaId}_conteudo.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> capitulosJson = data['capitulos'] ?? [];
      return capitulosJson.map((json) => ConteudoCapitulo.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  void clearCache() {
    _cachedMetadata = null;
  }
}
