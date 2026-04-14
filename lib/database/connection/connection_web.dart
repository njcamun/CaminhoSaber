import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createConnection() {
  // Na Web, usamos o modo mais simples possível que não requer sql.js externo
  // Se falhar, ele usa armazenamento em memória que é imune a erros de ficheiros em falta
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}
