// lib/services/content_provider_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentProviderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // URL Base do Firebase Storage
  static const String _baseUrl = "https://firebasestorage.googleapis.com/v0/b/caminhodosaber-93787.firebasestorage.app/o/data%2F";
  static const String _urlSuffix = "?alt=media";

  Map<String, dynamic>? _remoteVersionsCache;
  DateTime? _lastCacheUpdate;
  bool _isInitializing = false;

  /// Inicializa o cache de versões de forma assíncrona para não bloquear o arranque.
  Future<void> prefetchManifest() async {
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      debugPrint('[ContentProvider] Prefetching manifest...');
      // Reduzido para 2 segundos para o arranque ser instantâneo
      final doc = await _firestore.collection('content_metadata').doc('manifest').get()
          .timeout(const Duration(seconds: 2));
      if (doc.exists) {
        _remoteVersionsCache = doc.data();
        _lastCacheUpdate = DateTime.now();
        debugPrint('[ContentProvider] Manifest carregado com sucesso.');
      }
    } catch (e) {
      debugPrint('[ContentProvider] Falha ao pré-carregar manifest: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Obtém o conteúdo de um ficheiro JSON de forma ultra-rápida.
  Future<String> getContent(String fileName) async {
    // 1. Se já temos o ficheiro local (cache), entrega IMEDIATAMENTE
    if (await _hasLocalFile(fileName)) {
      debugPrint('[ContentProvider] Entrega rápida local: $fileName');
      
      // Agenda uma verificação de versão silenciosa para o futuro
      _updateInBackgroundTask(fileName);
      
      return await _readLocalFile(fileName);
    }

    // 2. Se não tem local, tenta Assets (Super rápido)
    try {
      final assetContent = await rootBundle.loadString('assets/data/$fileName');
      debugPrint('[ContentProvider] Entrega rápida Assets: $fileName');
      
      // Tenta baixar a versão da nuvem silenciosamente para a próxima utilização
      _updateInBackgroundTask(fileName);
      
      return assetContent;
    } catch (_) {
      // Se nem nos assets existir, então sim, tentamos download síncrono como última esperança
      debugPrint('[ContentProvider] Ficheiro crítico ausente em local e assets. Baixando...');
      final downloaded = await _downloadContent(fileName);
      if (downloaded != null) {
        await _saveLocalFile(fileName, downloaded);
        return downloaded;
      }
      throw Exception('Conteúdo não disponível: $fileName');
    }
  }

  /// Tenta baixar e atualizar o ficheiro em background sem bloquear o utilizador
  void _updateInBackgroundTask(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt('version_$fileName') ?? 0;
      
      final remoteVersion = await _getRemoteVersion(fileName);
      if (remoteVersion != null && remoteVersion > localVersion) {
        final content = await _downloadContent(fileName);
        if (content != null) {
          await _saveLocalFile(fileName, content);
          await prefs.setInt('version_$fileName', remoteVersion);
          debugPrint('[ContentProvider] Atualização silenciosa concluída: $fileName');
        }
      }
    } catch (_) {}
  }

  Future<int?> _getRemoteVersion(String fileName) async {
    // Se o cache for nulo ou expirar, tenta carregar
    if (_remoteVersionsCache == null || 
        _lastCacheUpdate == null || 
        DateTime.now().difference(_lastCacheUpdate!).inMinutes > 10) {
      await prefetchManifest();
    }
    
    final val = _remoteVersionsCache?[fileName];
    if (val is int) return val;
    if (val is String) return int.tryParse(val);
    return null;
  }

  Future<bool> _hasLocalFile(String fileName) async {
    final file = await _getLocalFile(fileName);
    return await file.exists();
  }

  Future<void> _saveLocalFile(String fileName, String content) async {
    final file = await _getLocalFile(fileName);
    await file.writeAsString(content);
  }

  Future<String> _readLocalFile(String fileName) async {
    final file = await _getLocalFile(fileName);
    return await file.readAsString();
  }

  Future<File> _getLocalFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/content_cache';
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    return File('$path/$fileName');
  }

  Future<String?> _downloadContent(String fileName) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$fileName$_urlSuffix'));
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }
    } catch (e) {
      debugPrint('[ContentProvider] Erro no download: $e');
    }
    return null;
  }
}
