import 'dart:async';

import 'package:anhi/secret.dart';
import 'package:sqflite/sqflite.dart';

/// Wraps exceptions thrown by SQLite.
class StorageException implements Exception {
  final String? _message;
  final DatabaseException? _cause;

  StorageException._({String? message, DatabaseException? cause})
      : _message = message,
        _cause = cause;

  @override
  String toString() {
    return _message ??
        'Unexpected exception thrown by database' + (_cause?.toString() ?? '');
  }
}

class StoredSecret extends Secret {
  final int localId;

  int? _databaseId;

  StoredSecret._fromSecret(Secret secret,
      {required this.localId, int? databaseId})
      : _databaseId = databaseId,
        super.fromRaw(
            mnemonic: secret.mnemonic,
            hash: secret.hash,
            reviewStage: secret.reviewStage,
            reviewTime: secret.reviewTime);
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

  /// A counter that is incremented each time a new local id is added.
  int _localIdCounter = 0;

  /// The list of secrets.
  List<StoredSecret> _secrets = [];

  /// Gets the current list of secrets.
  ///
  /// NOTE: This list is unmodifiable!
  List<StoredSecret> get storedSecrets {
    return List.unmodifiable(_secrets);
  }

  /// This function is called whenever the list of stored secrets is updated outside
  /// of the context of a modification method call.
  final void Function() onUpdate;

  /// This function is called whenever an exception occurs outside of the context
  /// of a modification method call.
  final void Function(StorageException) onError;

  SecretStorage({required this.onUpdate, required this.onError}) {
    // Load the preexisting secrets stored on-device.
    _syncDbThen((db) async {
      final dbSecrets = await db.selectAll();
      _secrets.addAll(
        dbSecrets.map(
          (dbSecret) => StoredSecret._fromSecret(
            dbSecret,
            localId: _nextLocalId(),
            databaseId: dbSecret.id,
          ),
        ),
      );
      onUpdate();
    });
  }

  /// Adds a secret to the beginning of the list.
  void add(Secret secret) {
    if (_secrets.any((e) => e.mnemonic == secret.mnemonic)) {
      throw StorageException._(message: "Secret with non-unique mnemonic added to SecretStorage");
    }

    final storedSecret = StoredSecret._fromSecret(secret, localId: _nextLocalId());
    _secrets.insert(0, storedSecret);

    _syncDbThen((db) async {
      // Insert the secret into the DB without an index.
      final databaseId = await db.insert(secret);
      // Set the ID of the item we added to _secrets earlier now that it's actually in the DB.
      storedSecret._databaseId = databaseId;
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

  /// Removes the secret with the given `localId`.
  void remove(int localId) {
    final index = _secrets.indexWhere((secret) => secret.localId == localId);
    final secret = _secrets[index];
    _secrets.removeAt(index);

    _syncDbThen((db) async {
      // Remove the secret.
      await db.remove(secret._databaseId!);
      // Note: No need to update the ordering.
    });
  }

  /// Updates the secret with `localId` to the given value.
  ///
  /// Fails if the given secret is not currently stored.
  void update(int id, Secret secret) {
    final index = _secrets.indexWhere((secret) => secret.localId == id);

    if (index != -1) {
      final newSecret = StoredSecret._fromSecret(secret, localId: id, databaseId: _secrets[id]._databaseId);
      final oldSecret = _secrets[index];
      _secrets[index] = newSecret;

      _syncDbThen((db) async {
        // Set the databaseId in case the old value wasn't stored at the time of updating
        newSecret._databaseId = oldSecret._databaseId;
        await db.update(id, secret);
      });
    } else {
      throw StorageException._(
          message:
              "Failed to update secret that is not stored in the database");
    }
  }

  /// Returns true if there exists a secret with `mnemonic`.
  bool exists(String mnemonic) {
    return _secrets.any((secret) => secret.mnemonic == mnemonic);
  }

  /// Generates the next local secret id.
  int _nextLocalId() {
    return _localIdCounter++;
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
        .catchError((err) => onError(StorageException._(cause: err)),
            test: (err) => err is DatabaseException)
        .catchError((err) => onError(err),
            test: (err) => err is StorageException)
        .then((_) => completer.complete());
  }

  /// Updates the database's ordering with the current ordering.
  Future<void> _updateOrdering(_SecretDatabase db) async {
    await db.updateOrdering(_secrets.map((e) => e._databaseId!));
  }

  /// Gets the current secret database, opening a connection if one has not already been opened.
  Future<_SecretDatabase> _getCurrentDb() async {
    return _dbInstance ??= await _SecretDatabase.open();
  }
}

/// A secret returned by the database.
class _DatabaseSecret extends Secret {
  final int id;

  _DatabaseSecret._fromRaw(
      {required this.id,
      required String mnemonic,
      required String hash,
      required int reviewStage,
      required DateTime reviewTime})
      : super.fromRaw(
            mnemonic: mnemonic,
            hash: hash,
            reviewStage: reviewStage,
            reviewTime: reviewTime);
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
        $_mnemonicColumn TEXT NOT NULL UNIQUE,
        $_hashColumn TEXT NOT NULL,
        $_reviewStageColumn INTEGER NOT NULL,
        $_reviewTimeColumn INTEGER NOT NULL,
        $_indexColumn INTEGER
      );
    ''');
  }

  Future<Iterable<_DatabaseSecret>> selectAll() async {
    var queryResult = await _conn.query(_secretsTable,
        columns: <String>[
          _idColumn,
          _mnemonicColumn,
          _hashColumn,
          _reviewStageColumn,
          _reviewTimeColumn
        ],
        orderBy: _indexColumn);

    return queryResult.map((e) => _DatabaseSecret._fromRaw(
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
    final rowsAffected = await _conn
        .delete(_secretsTable, where: "$_idColumn = ?", whereArgs: [id]);

    if (rowsAffected > 1) {
      throw StorageException._(
          message:
              "Internal error: Too many ($rowsAffected) rows affected in deletion. This is a bug.");
    } else {
      return rowsAffected == 1;
    }
  }

  /// Updates all the fields of the given secret with the given new values.
  Future<void> update(int id, Secret secret) async {
    await _conn.update(
      _secretsTable,
      {
        _mnemonicColumn: secret.mnemonic,
        _hashColumn: secret.hash,
        _reviewStageColumn: secret.reviewStage,
        _reviewTimeColumn: secret.reviewTime.millisecondsSinceEpoch,
      },
      where: "$_idColumn = ?",
      whereArgs: [id],
    );
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
