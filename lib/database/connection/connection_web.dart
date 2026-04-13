import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  debugPrint('[Drift] Initializing web database with IndexedDB');
  // Use simple IndexedDB backend for web - most stable option
  return LazyDatabase(() async {
    final db = WebDatabase('caminho_do_saber');
    debugPrint('[Drift] Web database initialized successfully');
    return db;
  });
}
