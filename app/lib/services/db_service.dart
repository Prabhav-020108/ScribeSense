// lib/services/db_service.dart
//
// Local SQLite persistence layer for ScribeSense.
// Contract source: Software Build Plan §5, S1.3, Tasks 1–4.
//
// Three tables:
//   sessions        — one row per writing session (start/end timestamps + notes)
//   samples         — raw ~50Hz BLE packets linked to a session
//   classifications — ML output windows linked to a session
//
// Full ~50Hz resolution is kept only for the most-recently-ended session.
// Older sessions are downsampled to ~1Hz (1-in-50 rows) by SessionRepository
// to prevent unbounded database growth.

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService {
  static Database? _db;
  static const _dbVersion = 1;

  // ---------------------------------------------------------------------------
  // Testing support — never called in production code.
  // ---------------------------------------------------------------------------

  /// Overrides the database path. Set to [inMemoryDatabasePath] in tests.
  static String? _pathOverride;

  /// Call this in test setUp() to get a clean, isolated in-memory database.
  @visibleForTesting
  static void useInMemoryDatabaseForTesting() {
    _pathOverride = inMemoryDatabasePath;
    _db = null;
  }

  /// Clears the cached instance (useful when you need a specific path in tests).
  @visibleForTesting
  static void resetForTesting() => _db = null;

  /// Returns the singleton database instance, opening (and creating) it on
  /// the first call.
  static Future<Database> get instance async {
    if (_db != null) return _db!;
    final dbPath = _pathOverride ?? join(await getDatabasesPath(), 'scribesense.db');
    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  // ---------------------------------------------------------------------------
  // Schema
  // ---------------------------------------------------------------------------

  static Future<void> _onCreate(Database db, int version) async {
    // sessions: one row per writing session
    await db.execute('''
      CREATE TABLE sessions (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at  INTEGER NOT NULL,
        ended_at    INTEGER,
        notes       TEXT
      )
    ''');

    // samples: raw BLE Sensor Data packets (~50 Hz)
    // All sensor fields mirror SensorSample exactly (integration-contract.md v1.0)
    await db.execute('''
      CREATE TABLE samples (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id  INTEGER NOT NULL,
        ts          INTEGER NOT NULL,
        pressure    INTEGER NOT NULL,
        ax          INTEGER NOT NULL,
        ay          INTEGER NOT NULL,
        az          INTEGER NOT NULL,
        pitch       INTEGER NOT NULL,
        roll        INTEGER NOT NULL,
        flags       INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id)
      )
    ''');

    // classifications: ML output windows (label + confidence) per session
    await db.execute('''
      CREATE TABLE classifications (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id   INTEGER NOT NULL,
        window_start INTEGER NOT NULL,
        window_end   INTEGER NOT NULL,
        label        TEXT    NOT NULL,
        confidence   REAL    NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id)
      )
    ''');
  }

  // Bump _dbVersion above whenever the schema changes, add a branch here.
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Example for a future version 2:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE sessions ADD COLUMN device_id TEXT');
    // }
  }
}
