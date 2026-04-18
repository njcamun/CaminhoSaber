import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

QueryExecutor createConnection() {
  // No Web, tentamos usar o armazenamento volátil (em memória).
  // Para evitar o erro do sql.js, usamos o WebDatabase de forma que ele 
  // não tente carregar bibliotecas externas obrigatoriamente no arranque.
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}
