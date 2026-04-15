import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  // ESTRATÉGIA DE PRODUÇÃO WEB: Stateless & Memory-First.
  // Evitamos o sql.js que causa crashes se os binários (.wasm) não forem servidos corretamente.
  // O progresso é garantido pelo Firebase Cloud Sync no arranque e finalização.
  debugPrint('[Drift] Web Environment: Using Volatile storage for crash-proof operation.');
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}
