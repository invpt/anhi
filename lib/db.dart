import 'package:anhi/secret.dart';
import 'package:sqflite/sqflite.dart';

const _secretsTable = 'secrets';
const _mnemonicColumn = 'mnemonic';
const _hashColumn = 'hash';
const _reviewStageColumn = 'reviewStage';
const _reviewTimeColumn = 'reviewTime';

class AnhiDatabase {
  static final AnhiDatabase instance = AnhiDatabase._();
  static Database? _db;

  AnhiDatabase._();

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    return await openDatabase('anhi-secrets.db', onCreate: _create, version: 1);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_secretsTable(
        $_mnemonicColumn TEXT NOT NULL PRIMARY KEY,
        $_hashColumn TEXT NOT NULL,
        $_reviewStageColumn INTEGER NOT NULL,
        $_reviewTimeColumn INTEGER NOT NULL
      );
    ''');
  }

  Future<Iterable<Secret>> getAllSecrets() async {
    var queryResult = await (await db).query(_secretsTable, columns: <String>[
      _mnemonicColumn,
      _hashColumn,
      _reviewStageColumn,
      _reviewTimeColumn
    ]);

    return queryResult.map((e) => Secret.fromRaw(
        mnemonic: e[_mnemonicColumn]! as String,
        hash: e[_hashColumn]! as String,
        reviewStage: e[_reviewStageColumn]! as int,
        reviewTime:
            DateTime.fromMillisecondsSinceEpoch(e[_reviewTimeColumn]! as int)));
  }

  Future<void> addSecret(Secret secret) async {
    await (await db).insert(
        _secretsTable,
        {
          _mnemonicColumn: secret.mnemonic,
          _hashColumn: secret.hash,
          _reviewStageColumn: secret.reviewStage,
          _reviewTimeColumn: secret.reviewTime.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> secretExists(String mnemonic) async {
    var result = await (await db).query(_secretsTable,
        columns: [], where: '$_mnemonicColumn = ?', whereArgs: [mnemonic]);

    return result.isNotEmpty;
  }
}
