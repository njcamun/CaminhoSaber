import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  return LazyDatabase(() async {
    try {
      debugPrint('[Drift] Initializing web database...');
      // Volatile for full isolation of persistence errors during crash debugging
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    } catch (e) {
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    }
  });
}
