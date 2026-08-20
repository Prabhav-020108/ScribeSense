// lib/services/session_repository.dart
//
// The ONLY class allowed to touch raw SQL in the ScribeSense app.
// All callers (providers, screens) go through this class — never through
// DbService directly.
//
// Downsampling policy (S1.3, Task 2):
//   Full ~50Hz resolution is kept only for the session that just ended.
//   Every other finished session is thinned to ~1Hz (1-in-50 rows) so the
//   database does not grow without bound over weeks of use.

import 'db_service.dart';

class SessionRepository {
  // ---------------------------------------------------------------------------
  // Session lifecycle
  // ---------------------------------------------------------------------------

  /// Creates a new session row and returns its auto-assigned id.
  Future<int> startSession() async {
    final db = await DbService.instance;
    return db.insert('sessions', {
      'started_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Marks [sessionId] as ended, then downsamples all *other* finished
  /// sessions to ~1Hz to keep the database size bounded.
  Future<void> endSession(int sessionId) async {
    final db = await DbService.instance;
    await db.update(
      'sessions',
      {'ended_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    await _downsampleOlderSessions(sessionId);
  }

  // ---------------------------------------------------------------------------
  // Sample writes
  // ---------------------------------------------------------------------------

  /// Inserts one raw sensor row linked to [sessionId].
  ///
  /// [row] must contain the keys: ts, pressure, ax, ay, az, pitch, roll, flags.
  /// Callers should build [row] from a [SensorSample] like:
  /// ```dart
  /// {
  ///   'ts':       sample.tMs,
  ///   'pressure': sample.pressure,
  ///   'ax':       sample.ax,  'ay': sample.ay,  'az': sample.az,
  ///   'pitch':    sample.pitch,
  ///   'roll':     sample.roll,
  ///   'flags':    sample.flags,
  /// }
  /// ```
  Future<void> insertSample(int sessionId, Map<String, dynamic> row) async {
    final db = await DbService.instance;
    await db.insert('samples', {'session_id': sessionId, ...row});
  }

  // ---------------------------------------------------------------------------
  // Classification writes
  // ---------------------------------------------------------------------------

  /// Inserts one ML classification result linked to [sessionId].
  Future<void> insertClassification(
    int sessionId, {
    required int windowStart,
    required int windowEnd,
    required String label,
    required double confidence,
  }) async {
    final db = await DbService.instance;
    await db.insert('classifications', {
      'session_id':   sessionId,
      'window_start': windowStart,
      'window_end':   windowEnd,
      'label':        label,
      'confidence':   confidence,
    });
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Returns all sessions ordered newest-first.
  Future<List<Map<String, dynamic>>> allSessions() async {
    final db = await DbService.instance;
    return db.query('sessions', orderBy: 'started_at DESC');
  }

  /// Returns all samples for [sessionId] ordered by timestamp ascending.
  Future<List<Map<String, dynamic>>> samplesForSession(int sessionId) async {
    final db = await DbService.instance;
    return db.query(
      'samples',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'ts ASC',
    );
  }

  /// Returns all classifications for [sessionId] ordered by window_start.
  Future<List<Map<String, dynamic>>> classificationsForSession(
    int sessionId,
  ) async {
    final db = await DbService.instance;
    return db.query(
      'classifications',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'window_start ASC',
    );
  }

  // ---------------------------------------------------------------------------
  // Downsampling (internal)
  // ---------------------------------------------------------------------------

  // Full ~50Hz resolution is kept only for the session that just ended (the
  // "current or most recent" one, task 2). Everything older gets thinned to
  // roughly 1-in-50 rows (~1Hz from a ~50Hz stream) so the database does not
  // grow without bound.
  Future<void> _downsampleOlderSessions(int justEndedSessionId) async {
    final db = await DbService.instance;
    final older = await db.query(
      'sessions',
      columns: ['id'],
      where: 'id != ? AND ended_at IS NOT NULL',
      whereArgs: [justEndedSessionId],
    );
    for (final s in older) {
      final sid = s['id'] as int;
      await db.rawDelete('''
        DELETE FROM samples
        WHERE session_id = ?
          AND id NOT IN (
            SELECT id FROM samples WHERE session_id = ? AND (id % 50) = 0
          )
      ''', [sid, sid]);
    }
  }
}
