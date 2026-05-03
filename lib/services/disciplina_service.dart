// lib/services/disciplina_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:caminho_do_saber/models/conteudo_disciplina_model.dart';
import 'package:caminho_do_saber/services/content_provider_service.dart';

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
  final ContentProviderService _contentProvider;
  List<DisciplinaMetadata>? _cachedMetadata;

  DisciplinaService(this._contentProvider);

  Future<List<DisciplinaMetadata>> getDisciplinasMetadata() async {
    if (_cachedMetadata != null) return _cachedMetadata!;

    try {
      final String response = await _contentProvider.getContent('disciplinas.json');
      final List<dynamic> data = json.decode(response);
      
      List<DisciplinaMetadata> metadataList = [];

      for (var item in data) {
        final id = item['id'] as String;
        int totalQuizzesCount = 0;
        int totalLeiturasCount = 0;

        // Tenta carregar metadados dos ficheiros individuais (se já baixados ou via fallback)
        try {
          final String detailResponse = await _contentProvider.getContent('$id.json');
          final Map<String, dynamic> detailData = json.decode(detailResponse);
          totalQuizzesCount = (detailData['quizzes'] as List?)?.length ?? 0;
        } catch (e) {
          debugPrint('Aviso: Arquivo de quiz $id ainda não disponível.');
        }

        try {
          final String conteudoResponse = await _contentProvider.getContent('${id}_conteudo.json');
          final Map<String, dynamic> conteudoData = json.decode(conteudoResponse);
          totalLeiturasCount = (conteudoData['capitulos'] as List?)?.length ?? 0;
        } catch (e) {
          debugPrint('Aviso: Arquivo de conteúdo $id ainda não disponível.');
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
    } catch (e) {
      debugPrint('Erro ao carregar metadados: $e');
      return [];
    }
  }

  Future<List<ConteudoCapitulo>> getCapitulos(String disciplinaId) async {
    try {
      final String response = await _contentProvider.getContent('${disciplinaId}_conteudo.json');
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
