// lib/services/conteudo_file_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserConteudo {
  final String id;
  final String titulo;
  final String resumo;
  final String conteudo;
  final DateTime? dataCriacao;

  UserConteudo({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.conteudo,
    this.dataCriacao,
  });

  factory UserConteudo.fromJson(Map<String, dynamic> json) {
    return UserConteudo(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      resumo: json['resumo'] as String,
      conteudo: json['conteudo'] as String,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'resumo': resumo,
      'conteudo': conteudo,
      'dataCriacao': dataCriacao?.toIso8601String(),
    };
  }
}

class ConteudoFileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<File> _getConteudoFile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum utilizador autenticado.');
    }
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/conteudos_${user.uid}.json';
    return File(path);
  }

  Future<List<UserConteudo>> loadConteudos() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final fileRef = _storage.ref('conteudos/${user.uid}.json');
      final file = await _getConteudoFile();

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);
        return (data['conteudos'] as List)
            .map((item) => UserConteudo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        final downloadUrl = await fileRef.getDownloadURL();
        final response = await http.get(Uri.parse(downloadUrl));
        final String jsonString = utf8.decode(response.bodyBytes);
        final data = json.decode(jsonString);
        await file.writeAsString(jsonString);
        return (data['conteudos'] as List)
            .map((item) => UserConteudo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return [];
      }
      rethrow;
    } catch (e) {
      print('Erro ao carregar conteúdos: $e');
      return [];
    }
  }

  Future<void> addConteudo(UserConteudo newUserConteudo) async {
    final file = await _getConteudoFile();
    List<UserConteudo> conteudos = [];

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);
      conteudos = (data['conteudos'] as List)
          .map((item) => UserConteudo.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    conteudos.add(newUserConteudo);

    final jsonContent = {
      'conteudos': conteudos.map((f) => f.toJson()).toList(),
    };
    final jsonString = json.encode(jsonContent);

    await file.writeAsString(jsonString);
  }

  Future<void> updateConteudo(UserConteudo updatedConteudo) async {
    final file = await _getConteudoFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de conteúdos não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserConteudo> conteudos = (data['conteudos'] as List)
        .map((item) => UserConteudo.fromJson(item as Map<String, dynamic>))
        .toList();

    final index = conteudos.indexWhere((card) => card.id == updatedConteudo.id);
    if (index != -1) {
      conteudos[index] = updatedConteudo;
      final jsonContent = {'conteudos': conteudos.map((f) => f.toJson()).toList()};
      await file.writeAsString(json.encode(jsonContent));
    }
  }

  Future<void> deleteConteudo(String conteudoId) async {
    final file = await _getConteudoFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de conteúdos não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserConteudo> conteudos = (data['conteudos'] as List)
        .map((item) => UserConteudo.fromJson(item as Map<String, dynamic>))
        .toList();

    conteudos.removeWhere((card) => card.id == conteudoId);

    final jsonContent = {'conteudos': conteudos.map((f) => f.toJson()).toList()};
    await file.writeAsString(json.encode(jsonContent));
  }

  Future<void> syncConteudos() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Nenhum utilizador autenticado para sincronizar.');
      return;
    }

    try {
      final file = await _getConteudoFile();

      if (!await file.exists()) {
        print('Ficheiro local de conteúdos não encontrado. Nenhuma sincronização necessária.');
        return;
      }

      final fileRef = _storage.ref('conteudos/${user.uid}.json');

      await fileRef.putFile(file);
      print('Ficheiro de conteúdos sincronizado com sucesso!');
    } catch (e) {
      print('Erro ao sincronizar ficheiro de conteúdos: $e');
      rethrow;
    }
  }
}
