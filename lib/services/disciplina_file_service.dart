// lib/services/disciplina_file_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class UserCapitulo {
  final String id;
  final String capitulo;
  final String resumo;
  final String conteudo;

  UserCapitulo({
    required this.id,
    required this.capitulo,
    required this.resumo,
    required this.conteudo,
  });

  factory UserCapitulo.fromJson(Map<String, dynamic> json) {
    return UserCapitulo(
      id: json['id'] as String,
      capitulo: json['capitulo'] as String,
      resumo: json['resumo'] as String,
      conteudo: json['conteudo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'capitulo': capitulo,
      'resumo': resumo,
      'conteudo': conteudo,
    };
  }
}

class UserDisciplina {
  final String id;
  final String nome;
  final String descricao;
  final String animacao;
  final DateTime? dataCriacao;
  List<UserCapitulo> capitulos;

  UserDisciplina({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.animacao,
    this.dataCriacao,
    List<UserCapitulo>? capitulos,
  }) : capitulos = capitulos ?? [];

  factory UserDisciplina.fromJson(Map<String, dynamic> json) {
    var capitulosFromJson = json['capitulos'] as List?;
    List<UserCapitulo>? capituloList = capitulosFromJson?.map((i) => UserCapitulo.fromJson(i)).toList();

    return UserDisciplina(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      animacao: json['animacao'] as String,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao'] as String)
          : null,
      capitulos: capituloList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'animacao': animacao,
      'dataCriacao': dataCriacao?.toIso8601String(),
      'capitulos': capitulos.map((c) => c.toJson()).toList(),
    };
  }
}

class DisciplinaFileService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  Future<File> _getUserDisciplinasFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/minhasDisciplinas.json';
    return File(path);
  }

  Future<String> uploadDisciplinaImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum utilizador autenticado para fazer upload da imagem.');
    }

    try {
      final imageName = '${_uuid.v4()}.jpg';
      final storageRef = _storage.ref().child('disciplina_imagens/${user.uid}/$imageName');
      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      rethrow;
    }
  }

  Future<List<UserDisciplina>> loadUserDisciplinas() async {
    try {
      final file = await _getUserDisciplinasFile();
      if (!await file.exists()) {
        return [];
      }
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);
      return (data['disciplinas'] as List)
          .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar as disciplinas do utilizador: $e');
      return [];
    }
  }

  Future<void> addDisciplina(UserDisciplina newUserDisciplina) async {
    final file = await _getUserDisciplinasFile();
    List<UserDisciplina> disciplinas = [];

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);
      disciplinas = (data['disciplinas'] as List)
          .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    disciplinas.add(newUserDisciplina);

    final jsonContent = {
      'disciplinas': disciplinas.map((d) => d.toJson()).toList(),
    };
    final jsonString = json.encode(jsonContent);

    await file.writeAsString(jsonString);
  }

  Future<void> updateDisciplina(UserDisciplina updatedDisciplina) async {
    final file = await _getUserDisciplinasFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de disciplinas não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserDisciplina> disciplinas = (data['disciplinas'] as List)
        .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
        .toList();

    final index = disciplinas.indexWhere((d) => d.id == updatedDisciplina.id);
    if (index != -1) {
      disciplinas[index] = updatedDisciplina;
      final jsonContent = {'disciplinas': disciplinas.map((d) => d.toJson()).toList()};
      await file.writeAsString(json.encode(jsonContent));
    }
  }

  Future<void> deleteDisciplina(String disciplinaId) async {
    final file = await _getUserDisciplinasFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de disciplinas não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserDisciplina> disciplinas = (data['disciplinas'] as List)
        .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
        .toList();

    disciplinas.removeWhere((d) => d.id == disciplinaId);

    final jsonContent = {'disciplinas': disciplinas.map((d) => d.toJson()).toList()};
    await file.writeAsString(json.encode(jsonContent));
  }

  Future<void> addConteudoToDisciplina(String disciplinaId, UserCapitulo novoConteudo) async {
    final file = await _getUserDisciplinasFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de disciplinas não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserDisciplina> disciplinas = (data['disciplinas'] as List)
        .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
        .toList();

    final index = disciplinas.indexWhere((d) => d.id == disciplinaId);
    if (index != -1) {
      disciplinas[index].capitulos.add(novoConteudo);
      final jsonContent = {'disciplinas': disciplinas.map((d) => d.toJson()).toList()};
      await file.writeAsString(json.encode(jsonContent));
    }
  }

  Future<void> updateConteudoInDisciplina(String disciplinaId, UserCapitulo updatedConteudo) async {
    final file = await _getUserDisciplinasFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de disciplinas não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserDisciplina> disciplinas = (data['disciplinas'] as List)
        .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
        .toList();

    final disciplinaIndex = disciplinas.indexWhere((d) => d.id == disciplinaId);
    if (disciplinaIndex != -1) {
      final conteudoIndex = disciplinas[disciplinaIndex].capitulos.indexWhere((c) => c.id == updatedConteudo.id);
      if (conteudoIndex != -1) {
        disciplinas[disciplinaIndex].capitulos[conteudoIndex] = updatedConteudo;
        final jsonContent = {'disciplinas': disciplinas.map((d) => d.toJson()).toList()};
        await file.writeAsString(json.encode(jsonContent));
      }
    }
  }

  Future<void> deleteConteudoFromDisciplina(String disciplinaId, String conteudoId) async {
    final file = await _getUserDisciplinasFile();
    if (!await file.exists()) {
      throw Exception('Ficheiro de disciplinas não encontrado.');
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);
    List<UserDisciplina> disciplinas = (data['disciplinas'] as List)
        .map((item) => UserDisciplina.fromJson(item as Map<String, dynamic>))
        .toList();

    final disciplinaIndex = disciplinas.indexWhere((d) => d.id == disciplinaId);
    if (disciplinaIndex != -1) {
      disciplinas[disciplinaIndex].capitulos.removeWhere((c) => c.id == conteudoId);
      final jsonContent = {'disciplinas': disciplinas.map((d) => d.toJson()).toList()};
      await file.writeAsString(json.encode(jsonContent));
    }
  }

  Future<void> syncDisciplinas() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Nenhum utilizador autenticado para sincronizar.');
      return;
    }

    try {
      final file = await _getUserDisciplinasFile();

      if (!await file.exists()) {
        print('Ficheiro local de disciplinas não encontrado. Nenhuma sincronização necessária.');
        return;
      }

      final fileRef = _storage.ref('disciplinas/${user.uid}.json');

      await fileRef.putFile(file);
      print('Ficheiro de disciplinas sincronizado com sucesso!');
    } catch (e) {
      print('Erro ao sincronizar ficheiro de disciplinas: $e');
      rethrow;
    }
  }
}
