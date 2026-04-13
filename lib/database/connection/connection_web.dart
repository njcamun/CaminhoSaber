import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor createConnection() {
  return WebDatabase('caminho_do_saber');
}
