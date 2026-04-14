import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  return LazyDatabase(() async {
    try {
      return WebDatabase('caminho_do_saber');
    } catch (e) {
      return WebDatabase.withStorage(DriftWebStorage.volatile());
    }
  });
}
