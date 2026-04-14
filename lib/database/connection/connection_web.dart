import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  return LazyDatabase(() async {
    try {
      debugPrint('[Drift] Web Environment: Using Volatile storage for stability.');
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    } catch (e) {
      debugPrint('[Drift] Web database fallback error: $e');
      // Final attempt: a very basic web executor that drift provides
      return WebDatabase('caminho_do_saber_backup');
    }
  });
}
