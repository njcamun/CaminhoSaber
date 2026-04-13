// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _parentUidMeta =
      const VerificationMeta('parentUid');
  @override
  late final GeneratedColumn<String> parentUid = GeneratedColumn<String>(
      'parent_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
      'nome', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarAssetPathMeta =
      const VerificationMeta('avatarAssetPath');
  @override
  late final GeneratedColumn<String> avatarAssetPath = GeneratedColumn<String>(
      'avatar_asset_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isMainProfileMeta =
      const VerificationMeta('isMainProfile');
  @override
  late final GeneratedColumn<bool> isMainProfile = GeneratedColumn<bool>(
      'is_main_profile', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_main_profile" IN (0, 1))'));
  static const VerificationMeta _totalPontosMeta =
      const VerificationMeta('totalPontos');
  @override
  late final GeneratedColumn<int> totalPontos = GeneratedColumn<int>(
      'total_pontos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalDiamantesMeta =
      const VerificationMeta('totalDiamantes');
  @override
  late final GeneratedColumn<int> totalDiamantes = GeneratedColumn<int>(
      'total_diamantes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uid,
        parentUid,
        nome,
        avatarAssetPath,
        isMainProfile,
        totalPontos,
        totalDiamantes,
        currentStreak
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('parent_uid')) {
      context.handle(_parentUidMeta,
          parentUid.isAcceptableOrUnknown(data['parent_uid']!, _parentUidMeta));
    } else if (isInserting) {
      context.missing(_parentUidMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
          _nomeMeta, nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta));
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('avatar_asset_path')) {
      context.handle(
          _avatarAssetPathMeta,
          avatarAssetPath.isAcceptableOrUnknown(
              data['avatar_asset_path']!, _avatarAssetPathMeta));
    } else if (isInserting) {
      context.missing(_avatarAssetPathMeta);
    }
    if (data.containsKey('is_main_profile')) {
      context.handle(
          _isMainProfileMeta,
          isMainProfile.isAcceptableOrUnknown(
              data['is_main_profile']!, _isMainProfileMeta));
    } else if (isInserting) {
      context.missing(_isMainProfileMeta);
    }
    if (data.containsKey('total_pontos')) {
      context.handle(
          _totalPontosMeta,
          totalPontos.isAcceptableOrUnknown(
              data['total_pontos']!, _totalPontosMeta));
    }
    if (data.containsKey('total_diamantes')) {
      context.handle(
          _totalDiamantesMeta,
          totalDiamantes.isAcceptableOrUnknown(
              data['total_diamantes']!, _totalDiamantesMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      parentUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_uid'])!,
      nome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nome'])!,
      avatarAssetPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}avatar_asset_path'])!,
      isMainProfile: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_main_profile'])!,
      totalPontos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pontos'])!,
      totalDiamantes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_diamantes'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String uid;
  final String parentUid;
  final String nome;
  final String avatarAssetPath;
  final bool isMainProfile;
  final int totalPontos;
  final int totalDiamantes;
  final int currentStreak;
  const Profile(
      {required this.id,
      required this.uid,
      required this.parentUid,
      required this.nome,
      required this.avatarAssetPath,
      required this.isMainProfile,
      required this.totalPontos,
      required this.totalDiamantes,
      required this.currentStreak});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    map['parent_uid'] = Variable<String>(parentUid);
    map['nome'] = Variable<String>(nome);
    map['avatar_asset_path'] = Variable<String>(avatarAssetPath);
    map['is_main_profile'] = Variable<bool>(isMainProfile);
    map['total_pontos'] = Variable<int>(totalPontos);
    map['total_diamantes'] = Variable<int>(totalDiamantes);
    map['current_streak'] = Variable<int>(currentStreak);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      uid: Value(uid),
      parentUid: Value(parentUid),
      nome: Value(nome),
      avatarAssetPath: Value(avatarAssetPath),
      isMainProfile: Value(isMainProfile),
      totalPontos: Value(totalPontos),
      totalDiamantes: Value(totalDiamantes),
      currentStreak: Value(currentStreak),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      parentUid: serializer.fromJson<String>(json['parentUid']),
      nome: serializer.fromJson<String>(json['nome']),
      avatarAssetPath: serializer.fromJson<String>(json['avatarAssetPath']),
      isMainProfile: serializer.fromJson<bool>(json['isMainProfile']),
      totalPontos: serializer.fromJson<int>(json['totalPontos']),
      totalDiamantes: serializer.fromJson<int>(json['totalDiamantes']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'parentUid': serializer.toJson<String>(parentUid),
      'nome': serializer.toJson<String>(nome),
      'avatarAssetPath': serializer.toJson<String>(avatarAssetPath),
      'isMainProfile': serializer.toJson<bool>(isMainProfile),
      'totalPontos': serializer.toJson<int>(totalPontos),
      'totalDiamantes': serializer.toJson<int>(totalDiamantes),
      'currentStreak': serializer.toJson<int>(currentStreak),
    };
  }

  Profile copyWith(
          {int? id,
          String? uid,
          String? parentUid,
          String? nome,
          String? avatarAssetPath,
          bool? isMainProfile,
          int? totalPontos,
          int? totalDiamantes,
          int? currentStreak}) =>
      Profile(
        id: id ?? this.id,
        uid: uid ?? this.uid,
        parentUid: parentUid ?? this.parentUid,
        nome: nome ?? this.nome,
        avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
        isMainProfile: isMainProfile ?? this.isMainProfile,
        totalPontos: totalPontos ?? this.totalPontos,
        totalDiamantes: totalDiamantes ?? this.totalDiamantes,
        currentStreak: currentStreak ?? this.currentStreak,
      );
  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('parentUid: $parentUid, ')
          ..write('nome: $nome, ')
          ..write('avatarAssetPath: $avatarAssetPath, ')
          ..write('isMainProfile: $isMainProfile, ')
          ..write('totalPontos: $totalPontos, ')
          ..write('totalDiamantes: $totalDiamantes, ')
          ..write('currentStreak: $currentStreak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uid, parentUid, nome, avatarAssetPath,
      isMainProfile, totalPontos, totalDiamantes, currentStreak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.parentUid == this.parentUid &&
          other.nome == this.nome &&
          other.avatarAssetPath == this.avatarAssetPath &&
          other.isMainProfile == this.isMainProfile &&
          other.totalPontos == this.totalPontos &&
          other.totalDiamantes == this.totalDiamantes &&
          other.currentStreak == this.currentStreak);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> uid;
  final Value<String> parentUid;
  final Value<String> nome;
  final Value<String> avatarAssetPath;
  final Value<bool> isMainProfile;
  final Value<int> totalPontos;
  final Value<int> totalDiamantes;
  final Value<int> currentStreak;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.parentUid = const Value.absent(),
    this.nome = const Value.absent(),
    this.avatarAssetPath = const Value.absent(),
    this.isMainProfile = const Value.absent(),
    this.totalPontos = const Value.absent(),
    this.totalDiamantes = const Value.absent(),
    this.currentStreak = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required String parentUid,
    required String nome,
    required String avatarAssetPath,
    required bool isMainProfile,
    this.totalPontos = const Value.absent(),
    this.totalDiamantes = const Value.absent(),
    this.currentStreak = const Value.absent(),
  })  : uid = Value(uid),
        parentUid = Value(parentUid),
        nome = Value(nome),
        avatarAssetPath = Value(avatarAssetPath),
        isMainProfile = Value(isMainProfile);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? parentUid,
    Expression<String>? nome,
    Expression<String>? avatarAssetPath,
    Expression<bool>? isMainProfile,
    Expression<int>? totalPontos,
    Expression<int>? totalDiamantes,
    Expression<int>? currentStreak,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (parentUid != null) 'parent_uid': parentUid,
      if (nome != null) 'nome': nome,
      if (avatarAssetPath != null) 'avatar_asset_path': avatarAssetPath,
      if (isMainProfile != null) 'is_main_profile': isMainProfile,
      if (totalPontos != null) 'total_pontos': totalPontos,
      if (totalDiamantes != null) 'total_diamantes': totalDiamantes,
      if (currentStreak != null) 'current_streak': currentStreak,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? uid,
      Value<String>? parentUid,
      Value<String>? nome,
      Value<String>? avatarAssetPath,
      Value<bool>? isMainProfile,
      Value<int>? totalPontos,
      Value<int>? totalDiamantes,
      Value<int>? currentStreak}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      parentUid: parentUid ?? this.parentUid,
      nome: nome ?? this.nome,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      isMainProfile: isMainProfile ?? this.isMainProfile,
      totalPontos: totalPontos ?? this.totalPontos,
      totalDiamantes: totalDiamantes ?? this.totalDiamantes,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (parentUid.present) {
      map['parent_uid'] = Variable<String>(parentUid.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (avatarAssetPath.present) {
      map['avatar_asset_path'] = Variable<String>(avatarAssetPath.value);
    }
    if (isMainProfile.present) {
      map['is_main_profile'] = Variable<bool>(isMainProfile.value);
    }
    if (totalPontos.present) {
      map['total_pontos'] = Variable<int>(totalPontos.value);
    }
    if (totalDiamantes.present) {
      map['total_diamantes'] = Variable<int>(totalDiamantes.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('parentUid: $parentUid, ')
          ..write('nome: $nome, ')
          ..write('avatarAssetPath: $avatarAssetPath, ')
          ..write('isMainProfile: $isMainProfile, ')
          ..write('totalPontos: $totalPontos, ')
          ..write('totalDiamantes: $totalDiamantes, ')
          ..write('currentStreak: $currentStreak')
          ..write(')'))
        .toString();
  }
}

class $ProgressoCapitulosTable extends ProgressoCapitulos
    with TableInfo<$ProgressoCapitulosTable, ProgressoCapitulo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProgressoCapitulosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _capituloIdMeta =
      const VerificationMeta('capituloId');
  @override
  late final GeneratedColumn<String> capituloId = GeneratedColumn<String>(
      'capitulo_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pontuacaoMeta =
      const VerificationMeta('pontuacao');
  @override
  late final GeneratedColumn<int> pontuacao = GeneratedColumn<int>(
      'pontuacao', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataConclusaoMeta =
      const VerificationMeta('dataConclusao');
  @override
  late final GeneratedColumn<DateTime> dataConclusao =
      GeneratedColumn<DateTime>('data_conclusao', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _profileUidMeta =
      const VerificationMeta('profileUid');
  @override
  late final GeneratedColumn<String> profileUid = GeneratedColumn<String>(
      'profile_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
      'tipo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, capituloId, pontuacao, dataConclusao, profileUid, tipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'progresso_capitulos';
  @override
  VerificationContext validateIntegrity(Insertable<ProgressoCapitulo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('capitulo_id')) {
      context.handle(
          _capituloIdMeta,
          capituloId.isAcceptableOrUnknown(
              data['capitulo_id']!, _capituloIdMeta));
    } else if (isInserting) {
      context.missing(_capituloIdMeta);
    }
    if (data.containsKey('pontuacao')) {
      context.handle(_pontuacaoMeta,
          pontuacao.isAcceptableOrUnknown(data['pontuacao']!, _pontuacaoMeta));
    } else if (isInserting) {
      context.missing(_pontuacaoMeta);
    }
    if (data.containsKey('data_conclusao')) {
      context.handle(
          _dataConclusaoMeta,
          dataConclusao.isAcceptableOrUnknown(
              data['data_conclusao']!, _dataConclusaoMeta));
    } else if (isInserting) {
      context.missing(_dataConclusaoMeta);
    }
    if (data.containsKey('profile_uid')) {
      context.handle(
          _profileUidMeta,
          profileUid.isAcceptableOrUnknown(
              data['profile_uid']!, _profileUidMeta));
    } else if (isInserting) {
      context.missing(_profileUidMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
          _tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProgressoCapitulo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProgressoCapitulo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      capituloId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}capitulo_id'])!,
      pontuacao: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pontuacao'])!,
      dataConclusao: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}data_conclusao'])!,
      profileUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_uid'])!,
      tipo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo']),
    );
  }

  @override
  $ProgressoCapitulosTable createAlias(String alias) {
    return $ProgressoCapitulosTable(attachedDatabase, alias);
  }
}

class ProgressoCapitulo extends DataClass
    implements Insertable<ProgressoCapitulo> {
  final int id;
  final String capituloId;
  final int pontuacao;
  final DateTime dataConclusao;
  final String profileUid;
  final String? tipo;
  const ProgressoCapitulo(
      {required this.id,
      required this.capituloId,
      required this.pontuacao,
      required this.dataConclusao,
      required this.profileUid,
      this.tipo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['capitulo_id'] = Variable<String>(capituloId);
    map['pontuacao'] = Variable<int>(pontuacao);
    map['data_conclusao'] = Variable<DateTime>(dataConclusao);
    map['profile_uid'] = Variable<String>(profileUid);
    if (!nullToAbsent || tipo != null) {
      map['tipo'] = Variable<String>(tipo);
    }
    return map;
  }

  ProgressoCapitulosCompanion toCompanion(bool nullToAbsent) {
    return ProgressoCapitulosCompanion(
      id: Value(id),
      capituloId: Value(capituloId),
      pontuacao: Value(pontuacao),
      dataConclusao: Value(dataConclusao),
      profileUid: Value(profileUid),
      tipo: tipo == null && nullToAbsent ? const Value.absent() : Value(tipo),
    );
  }

  factory ProgressoCapitulo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProgressoCapitulo(
      id: serializer.fromJson<int>(json['id']),
      capituloId: serializer.fromJson<String>(json['capituloId']),
      pontuacao: serializer.fromJson<int>(json['pontuacao']),
      dataConclusao: serializer.fromJson<DateTime>(json['dataConclusao']),
      profileUid: serializer.fromJson<String>(json['profileUid']),
      tipo: serializer.fromJson<String?>(json['tipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'capituloId': serializer.toJson<String>(capituloId),
      'pontuacao': serializer.toJson<int>(pontuacao),
      'dataConclusao': serializer.toJson<DateTime>(dataConclusao),
      'profileUid': serializer.toJson<String>(profileUid),
      'tipo': serializer.toJson<String?>(tipo),
    };
  }

  ProgressoCapitulo copyWith(
          {int? id,
          String? capituloId,
          int? pontuacao,
          DateTime? dataConclusao,
          String? profileUid,
          Value<String?> tipo = const Value.absent()}) =>
      ProgressoCapitulo(
        id: id ?? this.id,
        capituloId: capituloId ?? this.capituloId,
        pontuacao: pontuacao ?? this.pontuacao,
        dataConclusao: dataConclusao ?? this.dataConclusao,
        profileUid: profileUid ?? this.profileUid,
        tipo: tipo.present ? tipo.value : this.tipo,
      );
  @override
  String toString() {
    return (StringBuffer('ProgressoCapitulo(')
          ..write('id: $id, ')
          ..write('capituloId: $capituloId, ')
          ..write('pontuacao: $pontuacao, ')
          ..write('dataConclusao: $dataConclusao, ')
          ..write('profileUid: $profileUid, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, capituloId, pontuacao, dataConclusao, profileUid, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProgressoCapitulo &&
          other.id == this.id &&
          other.capituloId == this.capituloId &&
          other.pontuacao == this.pontuacao &&
          other.dataConclusao == this.dataConclusao &&
          other.profileUid == this.profileUid &&
          other.tipo == this.tipo);
}

class ProgressoCapitulosCompanion extends UpdateCompanion<ProgressoCapitulo> {
  final Value<int> id;
  final Value<String> capituloId;
  final Value<int> pontuacao;
  final Value<DateTime> dataConclusao;
  final Value<String> profileUid;
  final Value<String?> tipo;
  const ProgressoCapitulosCompanion({
    this.id = const Value.absent(),
    this.capituloId = const Value.absent(),
    this.pontuacao = const Value.absent(),
    this.dataConclusao = const Value.absent(),
    this.profileUid = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  ProgressoCapitulosCompanion.insert({
    this.id = const Value.absent(),
    required String capituloId,
    required int pontuacao,
    required DateTime dataConclusao,
    required String profileUid,
    this.tipo = const Value.absent(),
  })  : capituloId = Value(capituloId),
        pontuacao = Value(pontuacao),
        dataConclusao = Value(dataConclusao),
        profileUid = Value(profileUid);
  static Insertable<ProgressoCapitulo> custom({
    Expression<int>? id,
    Expression<String>? capituloId,
    Expression<int>? pontuacao,
    Expression<DateTime>? dataConclusao,
    Expression<String>? profileUid,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capituloId != null) 'capitulo_id': capituloId,
      if (pontuacao != null) 'pontuacao': pontuacao,
      if (dataConclusao != null) 'data_conclusao': dataConclusao,
      if (profileUid != null) 'profile_uid': profileUid,
      if (tipo != null) 'tipo': tipo,
    });
  }

  ProgressoCapitulosCompanion copyWith(
      {Value<int>? id,
      Value<String>? capituloId,
      Value<int>? pontuacao,
      Value<DateTime>? dataConclusao,
      Value<String>? profileUid,
      Value<String?>? tipo}) {
    return ProgressoCapitulosCompanion(
      id: id ?? this.id,
      capituloId: capituloId ?? this.capituloId,
      pontuacao: pontuacao ?? this.pontuacao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      profileUid: profileUid ?? this.profileUid,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (capituloId.present) {
      map['capitulo_id'] = Variable<String>(capituloId.value);
    }
    if (pontuacao.present) {
      map['pontuacao'] = Variable<int>(pontuacao.value);
    }
    if (dataConclusao.present) {
      map['data_conclusao'] = Variable<DateTime>(dataConclusao.value);
    }
    if (profileUid.present) {
      map['profile_uid'] = Variable<String>(profileUid.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProgressoCapitulosCompanion(')
          ..write('id: $id, ')
          ..write('capituloId: $capituloId, ')
          ..write('pontuacao: $pontuacao, ')
          ..write('dataConclusao: $dataConclusao, ')
          ..write('profileUid: $profileUid, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTableTable extends UserStatsTable
    with TableInfo<$UserStatsTableTable, UserStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileUidMeta =
      const VerificationMeta('profileUid');
  @override
  late final GeneratedColumn<String> profileUid = GeneratedColumn<String>(
      'profile_uid', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastActivityDateMeta =
      const VerificationMeta('lastActivityDate');
  @override
  late final GeneratedColumn<DateTime> lastActivityDate =
      GeneratedColumn<DateTime>('last_activity_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _highestStreakMeta =
      const VerificationMeta('highestStreak');
  @override
  late final GeneratedColumn<int> highestStreak = GeneratedColumn<int>(
      'highest_streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, profileUid, currentStreak, lastActivityDate, highestStreak];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserStatsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_uid')) {
      context.handle(
          _profileUidMeta,
          profileUid.isAcceptableOrUnknown(
              data['profile_uid']!, _profileUidMeta));
    } else if (isInserting) {
      context.missing(_profileUidMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    }
    if (data.containsKey('last_activity_date')) {
      context.handle(
          _lastActivityDateMeta,
          lastActivityDate.isAcceptableOrUnknown(
              data['last_activity_date']!, _lastActivityDateMeta));
    } else if (isInserting) {
      context.missing(_lastActivityDateMeta);
    }
    if (data.containsKey('highest_streak')) {
      context.handle(
          _highestStreakMeta,
          highestStreak.isAcceptableOrUnknown(
              data['highest_streak']!, _highestStreakMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_uid'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      lastActivityDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_activity_date'])!,
      highestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}highest_streak'])!,
    );
  }

  @override
  $UserStatsTableTable createAlias(String alias) {
    return $UserStatsTableTable(attachedDatabase, alias);
  }
}

class UserStatsTableData extends DataClass
    implements Insertable<UserStatsTableData> {
  final int id;
  final String profileUid;
  final int currentStreak;
  final DateTime lastActivityDate;
  final int highestStreak;
  const UserStatsTableData(
      {required this.id,
      required this.profileUid,
      required this.currentStreak,
      required this.lastActivityDate,
      required this.highestStreak});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_uid'] = Variable<String>(profileUid);
    map['current_streak'] = Variable<int>(currentStreak);
    map['last_activity_date'] = Variable<DateTime>(lastActivityDate);
    map['highest_streak'] = Variable<int>(highestStreak);
    return map;
  }

  UserStatsTableCompanion toCompanion(bool nullToAbsent) {
    return UserStatsTableCompanion(
      id: Value(id),
      profileUid: Value(profileUid),
      currentStreak: Value(currentStreak),
      lastActivityDate: Value(lastActivityDate),
      highestStreak: Value(highestStreak),
    );
  }

  factory UserStatsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatsTableData(
      id: serializer.fromJson<int>(json['id']),
      profileUid: serializer.fromJson<String>(json['profileUid']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      lastActivityDate: serializer.fromJson<DateTime>(json['lastActivityDate']),
      highestStreak: serializer.fromJson<int>(json['highestStreak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileUid': serializer.toJson<String>(profileUid),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'lastActivityDate': serializer.toJson<DateTime>(lastActivityDate),
      'highestStreak': serializer.toJson<int>(highestStreak),
    };
  }

  UserStatsTableData copyWith(
          {int? id,
          String? profileUid,
          int? currentStreak,
          DateTime? lastActivityDate,
          int? highestStreak}) =>
      UserStatsTableData(
        id: id ?? this.id,
        profileUid: profileUid ?? this.profileUid,
        currentStreak: currentStreak ?? this.currentStreak,
        lastActivityDate: lastActivityDate ?? this.lastActivityDate,
        highestStreak: highestStreak ?? this.highestStreak,
      );
  @override
  String toString() {
    return (StringBuffer('UserStatsTableData(')
          ..write('id: $id, ')
          ..write('profileUid: $profileUid, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('highestStreak: $highestStreak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileUid, currentStreak, lastActivityDate, highestStreak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatsTableData &&
          other.id == this.id &&
          other.profileUid == this.profileUid &&
          other.currentStreak == this.currentStreak &&
          other.lastActivityDate == this.lastActivityDate &&
          other.highestStreak == this.highestStreak);
}

class UserStatsTableCompanion extends UpdateCompanion<UserStatsTableData> {
  final Value<int> id;
  final Value<String> profileUid;
  final Value<int> currentStreak;
  final Value<DateTime> lastActivityDate;
  final Value<int> highestStreak;
  const UserStatsTableCompanion({
    this.id = const Value.absent(),
    this.profileUid = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.lastActivityDate = const Value.absent(),
    this.highestStreak = const Value.absent(),
  });
  UserStatsTableCompanion.insert({
    this.id = const Value.absent(),
    required String profileUid,
    this.currentStreak = const Value.absent(),
    required DateTime lastActivityDate,
    this.highestStreak = const Value.absent(),
  })  : profileUid = Value(profileUid),
        lastActivityDate = Value(lastActivityDate);
  static Insertable<UserStatsTableData> custom({
    Expression<int>? id,
    Expression<String>? profileUid,
    Expression<int>? currentStreak,
    Expression<DateTime>? lastActivityDate,
    Expression<int>? highestStreak,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileUid != null) 'profile_uid': profileUid,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (lastActivityDate != null) 'last_activity_date': lastActivityDate,
      if (highestStreak != null) 'highest_streak': highestStreak,
    });
  }

  UserStatsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileUid,
      Value<int>? currentStreak,
      Value<DateTime>? lastActivityDate,
      Value<int>? highestStreak}) {
    return UserStatsTableCompanion(
      id: id ?? this.id,
      profileUid: profileUid ?? this.profileUid,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      highestStreak: highestStreak ?? this.highestStreak,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileUid.present) {
      map['profile_uid'] = Variable<String>(profileUid.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (lastActivityDate.present) {
      map['last_activity_date'] = Variable<DateTime>(lastActivityDate.value);
    }
    if (highestStreak.present) {
      map['highest_streak'] = Variable<int>(highestStreak.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('profileUid: $profileUid, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('lastActivityDate: $lastActivityDate, ')
          ..write('highestStreak: $highestStreak')
          ..write(')'))
        .toString();
  }
}

class $UserFlashcardsTable extends UserFlashcards
    with TableInfo<$UserFlashcardsTable, UserFlashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _profileUidMeta =
      const VerificationMeta('profileUid');
  @override
  late final GeneratedColumn<String> profileUid = GeneratedColumn<String>(
      'profile_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentUidMeta =
      const VerificationMeta('parentUid');
  @override
  late final GeneratedColumn<String> parentUid = GeneratedColumn<String>(
      'parent_uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _disciplinaIdMeta =
      const VerificationMeta('disciplinaId');
  @override
  late final GeneratedColumn<String> disciplinaId = GeneratedColumn<String>(
      'disciplina_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _perguntaMeta =
      const VerificationMeta('pergunta');
  @override
  late final GeneratedColumn<String> pergunta = GeneratedColumn<String>(
      'pergunta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _respostaMeta =
      const VerificationMeta('resposta');
  @override
  late final GeneratedColumn<String> resposta = GeneratedColumn<String>(
      'resposta', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataCriacaoMeta =
      const VerificationMeta('dataCriacao');
  @override
  late final GeneratedColumn<DateTime> dataCriacao = GeneratedColumn<DateTime>(
      'data_criacao', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        profileUid,
        parentUid,
        disciplinaId,
        pergunta,
        resposta,
        dataCriacao
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_flashcards';
  @override
  VerificationContext validateIntegrity(Insertable<UserFlashcard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('profile_uid')) {
      context.handle(
          _profileUidMeta,
          profileUid.isAcceptableOrUnknown(
              data['profile_uid']!, _profileUidMeta));
    } else if (isInserting) {
      context.missing(_profileUidMeta);
    }
    if (data.containsKey('parent_uid')) {
      context.handle(_parentUidMeta,
          parentUid.isAcceptableOrUnknown(data['parent_uid']!, _parentUidMeta));
    } else if (isInserting) {
      context.missing(_parentUidMeta);
    }
    if (data.containsKey('disciplina_id')) {
      context.handle(
          _disciplinaIdMeta,
          disciplinaId.isAcceptableOrUnknown(
              data['disciplina_id']!, _disciplinaIdMeta));
    } else if (isInserting) {
      context.missing(_disciplinaIdMeta);
    }
    if (data.containsKey('pergunta')) {
      context.handle(_perguntaMeta,
          pergunta.isAcceptableOrUnknown(data['pergunta']!, _perguntaMeta));
    } else if (isInserting) {
      context.missing(_perguntaMeta);
    }
    if (data.containsKey('resposta')) {
      context.handle(_respostaMeta,
          resposta.isAcceptableOrUnknown(data['resposta']!, _respostaMeta));
    } else if (isInserting) {
      context.missing(_respostaMeta);
    }
    if (data.containsKey('data_criacao')) {
      context.handle(
          _dataCriacaoMeta,
          dataCriacao.isAcceptableOrUnknown(
              data['data_criacao']!, _dataCriacaoMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFlashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFlashcard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      profileUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_uid'])!,
      parentUid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_uid'])!,
      disciplinaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disciplina_id'])!,
      pergunta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pergunta'])!,
      resposta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resposta'])!,
      dataCriacao: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}data_criacao'])!,
    );
  }

  @override
  $UserFlashcardsTable createAlias(String alias) {
    return $UserFlashcardsTable(attachedDatabase, alias);
  }
}

class UserFlashcard extends DataClass implements Insertable<UserFlashcard> {
  final int id;
  final String profileUid;
  final String parentUid;
  final String disciplinaId;
  final String pergunta;
  final String resposta;
  final DateTime dataCriacao;
  const UserFlashcard(
      {required this.id,
      required this.profileUid,
      required this.parentUid,
      required this.disciplinaId,
      required this.pergunta,
      required this.resposta,
      required this.dataCriacao});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['profile_uid'] = Variable<String>(profileUid);
    map['parent_uid'] = Variable<String>(parentUid);
    map['disciplina_id'] = Variable<String>(disciplinaId);
    map['pergunta'] = Variable<String>(pergunta);
    map['resposta'] = Variable<String>(resposta);
    map['data_criacao'] = Variable<DateTime>(dataCriacao);
    return map;
  }

  UserFlashcardsCompanion toCompanion(bool nullToAbsent) {
    return UserFlashcardsCompanion(
      id: Value(id),
      profileUid: Value(profileUid),
      parentUid: Value(parentUid),
      disciplinaId: Value(disciplinaId),
      pergunta: Value(pergunta),
      resposta: Value(resposta),
      dataCriacao: Value(dataCriacao),
    );
  }

  factory UserFlashcard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFlashcard(
      id: serializer.fromJson<int>(json['id']),
      profileUid: serializer.fromJson<String>(json['profileUid']),
      parentUid: serializer.fromJson<String>(json['parentUid']),
      disciplinaId: serializer.fromJson<String>(json['disciplinaId']),
      pergunta: serializer.fromJson<String>(json['pergunta']),
      resposta: serializer.fromJson<String>(json['resposta']),
      dataCriacao: serializer.fromJson<DateTime>(json['dataCriacao']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'profileUid': serializer.toJson<String>(profileUid),
      'parentUid': serializer.toJson<String>(parentUid),
      'disciplinaId': serializer.toJson<String>(disciplinaId),
      'pergunta': serializer.toJson<String>(pergunta),
      'resposta': serializer.toJson<String>(resposta),
      'dataCriacao': serializer.toJson<DateTime>(dataCriacao),
    };
  }

  UserFlashcard copyWith(
          {int? id,
          String? profileUid,
          String? parentUid,
          String? disciplinaId,
          String? pergunta,
          String? resposta,
          DateTime? dataCriacao}) =>
      UserFlashcard(
        id: id ?? this.id,
        profileUid: profileUid ?? this.profileUid,
        parentUid: parentUid ?? this.parentUid,
        disciplinaId: disciplinaId ?? this.disciplinaId,
        pergunta: pergunta ?? this.pergunta,
        resposta: resposta ?? this.resposta,
        dataCriacao: dataCriacao ?? this.dataCriacao,
      );
  @override
  String toString() {
    return (StringBuffer('UserFlashcard(')
          ..write('id: $id, ')
          ..write('profileUid: $profileUid, ')
          ..write('parentUid: $parentUid, ')
          ..write('disciplinaId: $disciplinaId, ')
          ..write('pergunta: $pergunta, ')
          ..write('resposta: $resposta, ')
          ..write('dataCriacao: $dataCriacao')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, profileUid, parentUid, disciplinaId, pergunta, resposta, dataCriacao);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFlashcard &&
          other.id == this.id &&
          other.profileUid == this.profileUid &&
          other.parentUid == this.parentUid &&
          other.disciplinaId == this.disciplinaId &&
          other.pergunta == this.pergunta &&
          other.resposta == this.resposta &&
          other.dataCriacao == this.dataCriacao);
}

class UserFlashcardsCompanion extends UpdateCompanion<UserFlashcard> {
  final Value<int> id;
  final Value<String> profileUid;
  final Value<String> parentUid;
  final Value<String> disciplinaId;
  final Value<String> pergunta;
  final Value<String> resposta;
  final Value<DateTime> dataCriacao;
  const UserFlashcardsCompanion({
    this.id = const Value.absent(),
    this.profileUid = const Value.absent(),
    this.parentUid = const Value.absent(),
    this.disciplinaId = const Value.absent(),
    this.pergunta = const Value.absent(),
    this.resposta = const Value.absent(),
    this.dataCriacao = const Value.absent(),
  });
  UserFlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required String profileUid,
    required String parentUid,
    required String disciplinaId,
    required String pergunta,
    required String resposta,
    this.dataCriacao = const Value.absent(),
  })  : profileUid = Value(profileUid),
        parentUid = Value(parentUid),
        disciplinaId = Value(disciplinaId),
        pergunta = Value(pergunta),
        resposta = Value(resposta);
  static Insertable<UserFlashcard> custom({
    Expression<int>? id,
    Expression<String>? profileUid,
    Expression<String>? parentUid,
    Expression<String>? disciplinaId,
    Expression<String>? pergunta,
    Expression<String>? resposta,
    Expression<DateTime>? dataCriacao,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileUid != null) 'profile_uid': profileUid,
      if (parentUid != null) 'parent_uid': parentUid,
      if (disciplinaId != null) 'disciplina_id': disciplinaId,
      if (pergunta != null) 'pergunta': pergunta,
      if (resposta != null) 'resposta': resposta,
      if (dataCriacao != null) 'data_criacao': dataCriacao,
    });
  }

  UserFlashcardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? profileUid,
      Value<String>? parentUid,
      Value<String>? disciplinaId,
      Value<String>? pergunta,
      Value<String>? resposta,
      Value<DateTime>? dataCriacao}) {
    return UserFlashcardsCompanion(
      id: id ?? this.id,
      profileUid: profileUid ?? this.profileUid,
      parentUid: parentUid ?? this.parentUid,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      pergunta: pergunta ?? this.pergunta,
      resposta: resposta ?? this.resposta,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (profileUid.present) {
      map['profile_uid'] = Variable<String>(profileUid.value);
    }
    if (parentUid.present) {
      map['parent_uid'] = Variable<String>(parentUid.value);
    }
    if (disciplinaId.present) {
      map['disciplina_id'] = Variable<String>(disciplinaId.value);
    }
    if (pergunta.present) {
      map['pergunta'] = Variable<String>(pergunta.value);
    }
    if (resposta.present) {
      map['resposta'] = Variable<String>(resposta.value);
    }
    if (dataCriacao.present) {
      map['data_criacao'] = Variable<DateTime>(dataCriacao.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('profileUid: $profileUid, ')
          ..write('parentUid: $parentUid, ')
          ..write('disciplinaId: $disciplinaId, ')
          ..write('pergunta: $pergunta, ')
          ..write('resposta: $resposta, ')
          ..write('dataCriacao: $dataCriacao')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $ProgressoCapitulosTable progressoCapitulos =
      $ProgressoCapitulosTable(this);
  late final $UserStatsTableTable userStatsTable = $UserStatsTableTable(this);
  late final $UserFlashcardsTable userFlashcards = $UserFlashcardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profiles, progressoCapitulos, userStatsTable, userFlashcards];
}

typedef $$ProfilesTableInsertCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required String uid,
  required String parentUid,
  required String nome,
  required String avatarAssetPath,
  required bool isMainProfile,
  Value<int> totalPontos,
  Value<int> totalDiamantes,
  Value<int> currentStreak,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<String> uid,
  Value<String> parentUid,
  Value<String> nome,
  Value<String> avatarAssetPath,
  Value<bool> isMainProfile,
  Value<int> totalPontos,
  Value<int> totalDiamantes,
  Value<int> currentStreak,
});

class $$ProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableProcessedTableManager,
    $$ProfilesTableInsertCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder> {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProfilesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProfilesTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ProfilesTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> uid = const Value.absent(),
            Value<String> parentUid = const Value.absent(),
            Value<String> nome = const Value.absent(),
            Value<String> avatarAssetPath = const Value.absent(),
            Value<bool> isMainProfile = const Value.absent(),
            Value<int> totalPontos = const Value.absent(),
            Value<int> totalDiamantes = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
          }) =>
              ProfilesCompanion(
            id: id,
            uid: uid,
            parentUid: parentUid,
            nome: nome,
            avatarAssetPath: avatarAssetPath,
            isMainProfile: isMainProfile,
            totalPontos: totalPontos,
            totalDiamantes: totalDiamantes,
            currentStreak: currentStreak,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String uid,
            required String parentUid,
            required String nome,
            required String avatarAssetPath,
            required bool isMainProfile,
            Value<int> totalPontos = const Value.absent(),
            Value<int> totalDiamantes = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            id: id,
            uid: uid,
            parentUid: parentUid,
            nome: nome,
            avatarAssetPath: avatarAssetPath,
            isMainProfile: isMainProfile,
            totalPontos: totalPontos,
            totalDiamantes: totalDiamantes,
            currentStreak: currentStreak,
          ),
        ));
}

class $$ProfilesTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $ProfilesTable,
    Profile,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableProcessedTableManager,
    $$ProfilesTableInsertCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder> {
  $$ProfilesTableProcessedTableManager(super.$state);
}

class $$ProfilesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parentUid => $state.composableBuilder(
      column: $state.table.parentUid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avatarAssetPath => $state.composableBuilder(
      column: $state.table.avatarAssetPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isMainProfile => $state.composableBuilder(
      column: $state.table.isMainProfile,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalPontos => $state.composableBuilder(
      column: $state.table.totalPontos,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalDiamantes => $state.composableBuilder(
      column: $state.table.totalDiamantes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProfilesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get uid => $state.composableBuilder(
      column: $state.table.uid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parentUid => $state.composableBuilder(
      column: $state.table.parentUid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nome => $state.composableBuilder(
      column: $state.table.nome,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avatarAssetPath => $state.composableBuilder(
      column: $state.table.avatarAssetPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isMainProfile => $state.composableBuilder(
      column: $state.table.isMainProfile,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalPontos => $state.composableBuilder(
      column: $state.table.totalPontos,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalDiamantes => $state.composableBuilder(
      column: $state.table.totalDiamantes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ProgressoCapitulosTableInsertCompanionBuilder
    = ProgressoCapitulosCompanion Function({
  Value<int> id,
  required String capituloId,
  required int pontuacao,
  required DateTime dataConclusao,
  required String profileUid,
  Value<String?> tipo,
});
typedef $$ProgressoCapitulosTableUpdateCompanionBuilder
    = ProgressoCapitulosCompanion Function({
  Value<int> id,
  Value<String> capituloId,
  Value<int> pontuacao,
  Value<DateTime> dataConclusao,
  Value<String> profileUid,
  Value<String?> tipo,
});

class $$ProgressoCapitulosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProgressoCapitulosTable,
    ProgressoCapitulo,
    $$ProgressoCapitulosTableFilterComposer,
    $$ProgressoCapitulosTableOrderingComposer,
    $$ProgressoCapitulosTableProcessedTableManager,
    $$ProgressoCapitulosTableInsertCompanionBuilder,
    $$ProgressoCapitulosTableUpdateCompanionBuilder> {
  $$ProgressoCapitulosTableTableManager(
      _$AppDatabase db, $ProgressoCapitulosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProgressoCapitulosTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$ProgressoCapitulosTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$ProgressoCapitulosTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> capituloId = const Value.absent(),
            Value<int> pontuacao = const Value.absent(),
            Value<DateTime> dataConclusao = const Value.absent(),
            Value<String> profileUid = const Value.absent(),
            Value<String?> tipo = const Value.absent(),
          }) =>
              ProgressoCapitulosCompanion(
            id: id,
            capituloId: capituloId,
            pontuacao: pontuacao,
            dataConclusao: dataConclusao,
            profileUid: profileUid,
            tipo: tipo,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String capituloId,
            required int pontuacao,
            required DateTime dataConclusao,
            required String profileUid,
            Value<String?> tipo = const Value.absent(),
          }) =>
              ProgressoCapitulosCompanion.insert(
            id: id,
            capituloId: capituloId,
            pontuacao: pontuacao,
            dataConclusao: dataConclusao,
            profileUid: profileUid,
            tipo: tipo,
          ),
        ));
}

class $$ProgressoCapitulosTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $ProgressoCapitulosTable,
        ProgressoCapitulo,
        $$ProgressoCapitulosTableFilterComposer,
        $$ProgressoCapitulosTableOrderingComposer,
        $$ProgressoCapitulosTableProcessedTableManager,
        $$ProgressoCapitulosTableInsertCompanionBuilder,
        $$ProgressoCapitulosTableUpdateCompanionBuilder> {
  $$ProgressoCapitulosTableProcessedTableManager(super.$state);
}

class $$ProgressoCapitulosTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProgressoCapitulosTable> {
  $$ProgressoCapitulosTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get capituloId => $state.composableBuilder(
      column: $state.table.capituloId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get pontuacao => $state.composableBuilder(
      column: $state.table.pontuacao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dataConclusao => $state.composableBuilder(
      column: $state.table.dataConclusao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tipo => $state.composableBuilder(
      column: $state.table.tipo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ProgressoCapitulosTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProgressoCapitulosTable> {
  $$ProgressoCapitulosTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get capituloId => $state.composableBuilder(
      column: $state.table.capituloId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get pontuacao => $state.composableBuilder(
      column: $state.table.pontuacao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dataConclusao => $state.composableBuilder(
      column: $state.table.dataConclusao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tipo => $state.composableBuilder(
      column: $state.table.tipo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserStatsTableTableInsertCompanionBuilder = UserStatsTableCompanion
    Function({
  Value<int> id,
  required String profileUid,
  Value<int> currentStreak,
  required DateTime lastActivityDate,
  Value<int> highestStreak,
});
typedef $$UserStatsTableTableUpdateCompanionBuilder = UserStatsTableCompanion
    Function({
  Value<int> id,
  Value<String> profileUid,
  Value<int> currentStreak,
  Value<DateTime> lastActivityDate,
  Value<int> highestStreak,
});

class $$UserStatsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserStatsTableTable,
    UserStatsTableData,
    $$UserStatsTableTableFilterComposer,
    $$UserStatsTableTableOrderingComposer,
    $$UserStatsTableTableProcessedTableManager,
    $$UserStatsTableTableInsertCompanionBuilder,
    $$UserStatsTableTableUpdateCompanionBuilder> {
  $$UserStatsTableTableTableManager(
      _$AppDatabase db, $UserStatsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserStatsTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserStatsTableTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$UserStatsTableTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> profileUid = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<DateTime> lastActivityDate = const Value.absent(),
            Value<int> highestStreak = const Value.absent(),
          }) =>
              UserStatsTableCompanion(
            id: id,
            profileUid: profileUid,
            currentStreak: currentStreak,
            lastActivityDate: lastActivityDate,
            highestStreak: highestStreak,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String profileUid,
            Value<int> currentStreak = const Value.absent(),
            required DateTime lastActivityDate,
            Value<int> highestStreak = const Value.absent(),
          }) =>
              UserStatsTableCompanion.insert(
            id: id,
            profileUid: profileUid,
            currentStreak: currentStreak,
            lastActivityDate: lastActivityDate,
            highestStreak: highestStreak,
          ),
        ));
}

class $$UserStatsTableTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $UserStatsTableTable,
    UserStatsTableData,
    $$UserStatsTableTableFilterComposer,
    $$UserStatsTableTableOrderingComposer,
    $$UserStatsTableTableProcessedTableManager,
    $$UserStatsTableTableInsertCompanionBuilder,
    $$UserStatsTableTableUpdateCompanionBuilder> {
  $$UserStatsTableTableProcessedTableManager(super.$state);
}

class $$UserStatsTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastActivityDate => $state.composableBuilder(
      column: $state.table.lastActivityDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get highestStreak => $state.composableBuilder(
      column: $state.table.highestStreak,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserStatsTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserStatsTableTable> {
  $$UserStatsTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get currentStreak => $state.composableBuilder(
      column: $state.table.currentStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastActivityDate => $state.composableBuilder(
      column: $state.table.lastActivityDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get highestStreak => $state.composableBuilder(
      column: $state.table.highestStreak,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UserFlashcardsTableInsertCompanionBuilder = UserFlashcardsCompanion
    Function({
  Value<int> id,
  required String profileUid,
  required String parentUid,
  required String disciplinaId,
  required String pergunta,
  required String resposta,
  Value<DateTime> dataCriacao,
});
typedef $$UserFlashcardsTableUpdateCompanionBuilder = UserFlashcardsCompanion
    Function({
  Value<int> id,
  Value<String> profileUid,
  Value<String> parentUid,
  Value<String> disciplinaId,
  Value<String> pergunta,
  Value<String> resposta,
  Value<DateTime> dataCriacao,
});

class $$UserFlashcardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserFlashcardsTable,
    UserFlashcard,
    $$UserFlashcardsTableFilterComposer,
    $$UserFlashcardsTableOrderingComposer,
    $$UserFlashcardsTableProcessedTableManager,
    $$UserFlashcardsTableInsertCompanionBuilder,
    $$UserFlashcardsTableUpdateCompanionBuilder> {
  $$UserFlashcardsTableTableManager(
      _$AppDatabase db, $UserFlashcardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UserFlashcardsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UserFlashcardsTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$UserFlashcardsTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> profileUid = const Value.absent(),
            Value<String> parentUid = const Value.absent(),
            Value<String> disciplinaId = const Value.absent(),
            Value<String> pergunta = const Value.absent(),
            Value<String> resposta = const Value.absent(),
            Value<DateTime> dataCriacao = const Value.absent(),
          }) =>
              UserFlashcardsCompanion(
            id: id,
            profileUid: profileUid,
            parentUid: parentUid,
            disciplinaId: disciplinaId,
            pergunta: pergunta,
            resposta: resposta,
            dataCriacao: dataCriacao,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String profileUid,
            required String parentUid,
            required String disciplinaId,
            required String pergunta,
            required String resposta,
            Value<DateTime> dataCriacao = const Value.absent(),
          }) =>
              UserFlashcardsCompanion.insert(
            id: id,
            profileUid: profileUid,
            parentUid: parentUid,
            disciplinaId: disciplinaId,
            pergunta: pergunta,
            resposta: resposta,
            dataCriacao: dataCriacao,
          ),
        ));
}

class $$UserFlashcardsTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $UserFlashcardsTable,
    UserFlashcard,
    $$UserFlashcardsTableFilterComposer,
    $$UserFlashcardsTableOrderingComposer,
    $$UserFlashcardsTableProcessedTableManager,
    $$UserFlashcardsTableInsertCompanionBuilder,
    $$UserFlashcardsTableUpdateCompanionBuilder> {
  $$UserFlashcardsTableProcessedTableManager(super.$state);
}

class $$UserFlashcardsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $UserFlashcardsTable> {
  $$UserFlashcardsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get parentUid => $state.composableBuilder(
      column: $state.table.parentUid,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get disciplinaId => $state.composableBuilder(
      column: $state.table.disciplinaId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get pergunta => $state.composableBuilder(
      column: $state.table.pergunta,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get resposta => $state.composableBuilder(
      column: $state.table.resposta,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dataCriacao => $state.composableBuilder(
      column: $state.table.dataCriacao,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UserFlashcardsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $UserFlashcardsTable> {
  $$UserFlashcardsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get profileUid => $state.composableBuilder(
      column: $state.table.profileUid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parentUid => $state.composableBuilder(
      column: $state.table.parentUid,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get disciplinaId => $state.composableBuilder(
      column: $state.table.disciplinaId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get pergunta => $state.composableBuilder(
      column: $state.table.pergunta,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get resposta => $state.composableBuilder(
      column: $state.table.resposta,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dataCriacao => $state.composableBuilder(
      column: $state.table.dataCriacao,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$ProgressoCapitulosTableTableManager get progressoCapitulos =>
      $$ProgressoCapitulosTableTableManager(_db, _db.progressoCapitulos);
  $$UserStatsTableTableTableManager get userStatsTable =>
      $$UserStatsTableTableTableManager(_db, _db.userStatsTable);
  $$UserFlashcardsTableTableManager get userFlashcards =>
      $$UserFlashcardsTableTableManager(_db, _db.userFlashcards);
}
