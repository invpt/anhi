import 'dart:async';

import 'package:anhi/secret.dart';
import 'package:sqflite/sqflite.dart';

/// Wraps exceptions thrown by SQLite.
class StorageException implements Exception {
  final DatabaseException _cause;
  
  StorageException._(this._cause);
}

/// Abstracts storage of secrets.
class SecretStorage {
  /// The current saved database instance to be used by `_getCurrentDb`.
  _SecretDatabase? _dbInstance;
  
  /// A future with the property that all current (at the time of getting the
  /// value of the variable) pending database operations  will be complete after
  /// it is awaited. New operations may begin while a future read from this
  /// variable at a specific point in time is being awaited.
  Future<void> _finishUpdates = Future.value(null);

  /// The list of secrets.
  List<_StoredSecret> _secrets = [];
  
  /// Gets the current list of secrets.
  ///
  /// NOTE: This list is unmodifiable!
  List<Secret> get storedSecrets {
    return List.unmodifiable(_secrets);
  }

  /// This function is called whenever the list of stored secrets is updated outside
  /// of the context of a modification method call.
  final void Function() onAsyncUpdate;

  SecretStorage({ required this.onAsyncUpdate }) {
    // Load the preexisting secrets stored on-device.
    _syncDbThen((db) async {
      final all = await db.selectAll();
      _secrets.addAll(all);
      onAsyncUpdate();
    });
  }

  /// Adds a secret to the beginning of the list.
  void add(Secret secret) {
    final storedSecret = _StoredSecret.fromSecret(secret);
    _secrets.insert(0, storedSecret);

    _syncDbThen((db) async {
      // Insert the secret into the DB without an index.
      final id = await db.insert(secret);
      // Set the ID of the item we added to _secrets earlier now that it's actually in the DB.
      storedSecret.id = id;
      // Update the ordering, since the secret didn't have an index when we inserted it.
      await _updateOrdering(db);
    });
  }

  /// Reorders the secret at index `from` to the index `to`.
  void reorder(int from, int to) {
    final secret = _secrets.removeAt(from);
    _secrets.insert(to, secret);

    _syncDbThen((db) async {
      await _updateOrdering(db);
    });
  }

  /// Removes the secret at `index`.
  void remove(int index) {
    final removed = _secrets.removeAt(index);

    _syncDbThen((db) async {
      // Remove the secret.
      await db.remove(removed.id!);
      // Note: No need to update the ordering.
    });
  }

  /// Returns true if there exists a secret with `mnemonic`.
  bool exists(String mnemonic) {
    return _secrets.any((secret) => secret.mnemonic == mnemonic);
  }

  /// Runs `updater`, ensuring that the database is syncronized with `_secrets`
  /// while it is running.
  Future<void> _syncDbThen(Future<void> Function(_SecretDatabase db) updater) {
    // Save the original future that we will need to await before running the updater.
    final finishOriginalUpdates = _finishUpdates;

    // Create a completer and make it so that _finishUpdates is followed by
    // the future of that completer. This allows us to control when _finishUpdates
    // completes next.
    final completer = Completer<void>();
    _finishUpdates =
        finishOriginalUpdates.then((_) => _finishUpdates = completer.future);

    return finishOriginalUpdates
        .then((_) => _getCurrentDb())
        .then((db) => updater(db))
        .catchError((err) {}, test: (err) => err is DatabaseException)
        .then((_) => completer.complete());
  }

  /// Updates the database's ordering with the current ordering.
  /// 
  /// WARNING: This function MUST be called from within `_finishUpdatesThenUpdate`.
  Future<void> _updateOrdering(_SecretDatabase db) async {
    await db.updateOrdering(_secrets.map((e) => e.id!));
  }

  /// Gets the current secret database, opening a connection if one has not already been opened.
  Future<_SecretDatabase> _getCurrentDb() async {
    return _dbInstance ??= await _SecretDatabase.open();
  }
}

class _StoredSecret extends Secret {
  int? id;

  _StoredSecret._fromRaw(
      {this.id,
      required String mnemonic,
      required String hash,
      required int reviewStage,
      required DateTime reviewTime})
      : super.fromRaw(
            mnemonic: mnemonic,
            hash: hash,
            reviewStage: reviewStage,
            reviewTime: reviewTime);

  _StoredSecret.fromSecret(Secret secret, {this.id})
      : super.fromRaw(
            mnemonic: secret.mnemonic,
            hash: secret.hash,
            reviewStage: secret.reviewStage,
            reviewTime: secret.reviewTime);
}

/// Interacts with SQLite to store secrets on-device.
class _SecretDatabase {
  static const _secretsTable = 'secrets';
  static const _idColumn = 'id';
  static const _mnemonicColumn = 'mnemonic';
  static const _hashColumn = 'hash';
  static const _reviewStageColumn = 'reviewStage';
  static const _reviewTimeColumn = 'reviewTime';
  static const _indexColumn = 'idx';

  final Database _conn;

  _SecretDatabase._(this._conn);

  static Future<_SecretDatabase> open() async {
    return _SecretDatabase._(
        await openDatabase('anhi-secrets.db', onCreate: _create, version: 1));
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_secretsTable(
        $_idColumn INTEGER PRIMARY KEY AUTOINCREMENT,
        $_mnemonicColumn TEXT NOT NULL,
        $_hashColumn TEXT NOT NULL,
        $_reviewStageColumn INTEGER NOT NULL,
        $_reviewTimeColumn INTEGER NOT NULL,
        $_indexColumn INTEGER
      );
    ''');
  }

  Future<Iterable<_StoredSecret>> selectAll() async {
    var queryResult = await _conn.query(_secretsTable,
        columns: <String>[
          _idColumn,
          _mnemonicColumn,
          _hashColumn,
          _reviewStageColumn,
          _reviewTimeColumn
        ],
        orderBy: _indexColumn);

    return queryResult.map((e) => _StoredSecret._fromRaw(
        id: e[_idColumn]! as int,
        mnemonic: e[_mnemonicColumn]! as String,
        hash: e[_hashColumn]! as String,
        reviewStage: e[_reviewStageColumn]! as int,
        reviewTime:
            DateTime.fromMillisecondsSinceEpoch(e[_reviewTimeColumn]! as int)));
  }

  /// Adds the given secret to the database with the `index` column set to null.
  ///
  /// Returns the id of the inserted secret.
  Future<int> insert(Secret secret) async {
    return await _conn.insert(
        _secretsTable,
        {
          _mnemonicColumn: secret.mnemonic,
          _hashColumn: secret.hash,
          _reviewStageColumn: secret.reviewStage,
          _reviewTimeColumn: secret.reviewTime.millisecondsSinceEpoch,
          _indexColumn: null
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
    ;
  }

  /// Removes the secret with the given id from the database.
  Future<bool> remove(int id) async {
    final rowsAffected = await _conn.delete(_secretsTable, where: "$_idColumn = ?", whereArgs: [id]);

    if (rowsAffected > 1) {
      throw Exception("Internal error: Too many ($rowsAffected) rows affected in deletion. This is a bug.");
    } else {
      return rowsAffected == 1;
    }
  }

  /// Ensures that the secrets returned from `selectAll` will be returned in the
  /// order that the given iterable is in. Each item in the iterable should be the
  /// id of a secret.
  Future<void> updateOrdering(Iterable<int> ids) async {
    int index = 0;
    for (final id in ids) {
      await _conn.update(_secretsTable, {_indexColumn: index++},
          where: "$_idColumn = ?", whereArgs: [id]);
    }
  }
}