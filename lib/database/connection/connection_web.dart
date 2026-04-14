import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  return LazyDatabase(() async {
    try {
      debugPrint('[Drift] Initializing web database with IndexedDB...');
      final storage = await DriftWebStorage.indexedDb('caminho_do_saber');
      final db = WebDatabase.withStorage(storage);
      debugPrint('[Drift] Web database initialized successfully');
      return db;
    } catch (e) {
      debugPrint('[Drift] Error initializing web database: $e. Falling back to volatile storage.');
      // Fallback to in-memory database to allow the app to run even if IndexedDB fails
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    }
  });
}
