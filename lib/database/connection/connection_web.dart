import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  debugPrint('[Drift] Web Connection V3: Initializing volatile storage (Memory Only)');
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}
