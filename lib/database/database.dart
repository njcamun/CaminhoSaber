import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'database.g.dart';

class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()();
  TextColumn get parentUid => text()();
  TextColumn get nome => text()();
  TextColumn get avatarAssetPath => text()();
  BoolColumn get isMainProfile => boolean()();
  IntColumn get totalPontos => integer().withDefault(const Constant(0))();
  IntColumn get totalDiamantes => integer().withDefault(const Constant(0))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
}

class ProgressoCapitulos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get capituloId => text()();
  IntColumn get pontuacao => integer()();
  DateTimeColumn get dataConclusao => dateTime()();
  TextColumn get profileUid => text()();
  TextColumn get tipo => text().nullable()();
}

class UserStatsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileUid => text().unique()();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActivityDate => dateTime()();
  IntColumn get highestStreak => integer().withDefault(const Constant(0))();
}

class UserFlashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get profileUid => text()();
  TextColumn get parentUid => text()();
  TextColumn get disciplinaId => text()();
  TextColumn get pergunta => text()();
  TextColumn get resposta => text()();
  DateTimeColumn get dataCriacao => dateTime().withDefault(currentDateAndTime)();
}

class GlobalRanking extends Table {
  TextColumn get profileUid => text()();
  TextColumn get name => text()();
  TextColumn get avatarPath => text()();
  IntColumn get totalPoints => integer()();
  DateTimeColumn get lastUpdate => dateTime()();
  TextColumn get parentUid => text().nullable()();

  @override
  Set<Column> get primaryKey => {profileUid};
}

@DriftDatabase(tables: [Profiles, ProgressoCapitulos, UserStatsTable, UserFlashcards, GlobalRanking])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Adicionar a nova tabela de ranking global no upgrade para a versão 2
          await m.createTable(globalRanking);
        }
      },
    );
  }
}
