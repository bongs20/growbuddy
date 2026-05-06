import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  FirebaseService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _auth = auth ?? FirebaseAuth.instance,
      _database = database ?? FirebaseDatabase.instance;

  static const String demoDeviceId = 'device_demo';
  static const int idealMoistureMin = 35;
  static const int idealMoistureMax = 70;
  static const int dryMoistureThreshold = 25;
  static const int severeDryMoistureThreshold = 15;
  static const int overwaterMoistureThreshold = 85;
  static const List<int> _levelThresholds = <int>[
    0,
    50,
    120,
    220,
    360,
    540,
    760,
    1020,
    1320,
    1660,
  ];

  static final StreamController<Map<Object?, Object?>> _demoDeviceController =
      StreamController<Map<Object?, Object?>>.broadcast();
  static final StreamController<List<Map<Object?, Object?>>>
  _demoHistoryController =
      StreamController<List<Map<Object?, Object?>>>.broadcast();

  static Timer? _demoWaterTimer;
  static Map<Object?, Object?> _demoDeviceState = {
    'moisture': 42,
    'status': 'idle',
    'online': true,
    'last_update': DateTime.now().millisecondsSinceEpoch,
    'fw_version': 'demo-simulator-1.0.0',
    'wifi_ssid': 'GrowBuddy Demo Lab',
    'control': {'siram': false},
    'game': {
      'score': 120,
      'level': 3,
      'last_watered_at': DateTime.now()
          .subtract(const Duration(hours: 10))
          .millisecondsSinceEpoch,
      'last_score_delta': 12,
      'last_score_reason': 'Penyiraman sebelumnya berada di zona aman.',
    },
    'settings': {'pump_duration_seconds': 3},
  };
  static List<Map<Object?, Object?>> _demoHistory = [
    {
      'action': 'seed_data',
      'title': 'Demo Device Siap',
      'device_id': demoDeviceId,
      'triggered_by': 'demo_system',
      'moisture_before': 35,
      'moisture_after': 42,
      'duration_seconds': 3,
      'created_at': DateTime.now()
          .subtract(const Duration(minutes: 15))
          .millisecondsSinceEpoch,
    },
  ];

  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  User? get currentUser => _auth.currentUser;

  bool isDemoDevice(String deviceId) => deviceId.trim() == demoDeviceId;

  Future<User> ensureAnonymousSignIn() async {
    final existingUser = _auth.currentUser;
    if (existingUser != null) {
      return existingUser;
    }

    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous sign-in succeeded without a user.');
    }
    return user;
  }

  Future<String?> fetchSavedDeviceId(String uid) async {
    final snapshot = await _database.ref('users/$uid/device_id').get();
    if (!snapshot.exists) {
      return null;
    }

    final value = snapshot.value;
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  /// Check if a device ID is registered in the system
  /// Returns true if device exists, false otherwise
  Future<bool> deviceExists(String deviceId) async {
    if (isDemoDevice(deviceId)) {
      return true; // Demo device always exists
    }

    try {
      final snapshot = await deviceRef(deviceId).get();
      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveDeviceId({
    required String uid,
    required String deviceId,
  }) async {
    await _database.ref('users/$uid').update({
      'device_id': deviceId,
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<void> clearDeviceId(String uid) async {
    await _database.ref('users/$uid/device_id').remove();
  }

  DatabaseReference deviceRef(String deviceId) {
    return _database.ref('devices/$deviceId');
  }

  Stream<Map<Object?, Object?>> watchDevice(String deviceId) {
    if (isDemoDevice(deviceId)) {
      return Stream<Map<Object?, Object?>>.multi((controller) {
        controller.add(_cloneMap(_demoDeviceState));
        final subscription = _demoDeviceController.stream.listen(
          controller.add,
        );
        controller.onCancel = subscription.cancel;
      });
    }

    return deviceRef(
      deviceId,
    ).onValue.map((event) => _snapshotToMap(event.snapshot.value));
  }

  Future<Map<Object?, Object?>> fetchDevice(String deviceId) async {
    if (isDemoDevice(deviceId)) {
      return _cloneMap(_demoDeviceState);
    }

    final snapshot = await deviceRef(deviceId).get();
    return _snapshotToMap(snapshot.value);
  }

  Stream<List<Map<Object?, Object?>>> watchHistory(
    String deviceId, {
    int limit = 10,
  }) {
    if (isDemoDevice(deviceId)) {
      return Stream<List<Map<Object?, Object?>>>.multi((controller) {
        controller.add(_cloneHistory(limit));
        final subscription = _demoHistoryController.stream.listen(
          (history) => controller.add(_limitHistory(history, limit)),
        );
        controller.onCancel = subscription.cancel;
      });
    }

    return deviceRef(deviceId)
        .child('history')
        .limitToLast(limit)
        .onValue
        .map((event) => _snapshotToHistory(event.snapshot.value, limit));
  }

  Future<Map<String, bool>> loadUserSettings(String uid) async {
    final snap = await _database.ref('users/$uid/settings').get();
    if (!snap.exists || snap.value is! Map) {
      return {'smart_notifications': true, 'auto_water': false};
    }

    final map = Map<Object?, Object?>.from(snap.value as Map);
    return {
      'smart_notifications': map['smart_notifications'] == true,
      'auto_water': map['auto_water'] == true,
    };
  }

  Future<void> saveUserSettings({
    required String uid,
    bool? smartNotif,
    bool? autoWater,
  }) async {
    final current = await loadUserSettings(uid);
    await _database.ref('users/$uid/settings').update({
      'smart_notifications':
          smartNotif ?? current['smart_notifications'] ?? true,
      'auto_water': autoWater ?? current['auto_water'] ?? false,
    });
  }

  Future<Map<String, String>> loadUserProfile(String uid) async {
    final snap = await _database.ref('users/$uid/profile').get();
    final fallbackName = 'Plant Hero';

    if (!snap.exists || snap.value is! Map) {
      return <String, String>{
        'display_name': fallbackName,
        'plant_focus': 'Monstera Deliciosa',
        'location': 'Rumah Kaca',
      };
    }

    final map = Map<Object?, Object?>.from(snap.value as Map);
    return <String, String>{
      'display_name': '${map['display_name'] ?? fallbackName}',
      'plant_focus': '${map['plant_focus'] ?? 'Monstera Deliciosa'}',
      'location': '${map['location'] ?? 'Rumah Kaca'}',
    };
  }

  Future<void> saveUserProfile({
    required String uid,
    String? displayName,
    String? plantFocus,
    String? location,
  }) async {
    final current = await loadUserProfile(uid);
    await _database.ref('users/$uid/profile').update({
      'display_name': displayName ?? current['display_name'] ?? 'Plant Hero',
      'plant_focus': plantFocus ?? current['plant_focus'] ?? 'Monstera Deliciosa',
      'location': location ?? current['location'] ?? 'Rumah Kaca',
      'updated_at': ServerValue.timestamp,
    });
  }

  int readPumpDurationSeconds(Map<Object?, Object?> deviceData) {
    final settings = _readMap(deviceData['settings']);
    final raw = settings['pump_duration_seconds'] ?? settings['pump_duration'];
    final seconds = _readInt(raw);
    return seconds <= 0 ? 3 : seconds;
  }

  Future<int> fetchPumpDurationSeconds(String deviceId) async {
    final deviceData = await fetchDevice(deviceId);
    return readPumpDurationSeconds(deviceData);
  }

  /// Fetch calibration info stored on the device node.
  /// Returns an empty map if no calibration exists.
  Future<Map<Object?, Object?>> fetchDeviceCalibration(String deviceId) async {
    if (isDemoDevice(deviceId)) {
      final cal = _readMap(_demoDeviceState['calibration']);
      return Map<Object?, Object?>.from(cal);
    }

    final snap = await deviceRef(deviceId).child('calibration').get();
    if (!snap.exists) return <Object?, Object?>{};
    return _snapshotToMap(snap.value);
  }

  /// Save a simple calibration for the device. Calibration is stored
  /// under `devices/{deviceId}/calibration` with fields:
  /// - `plant_type`: String
  /// - `offset_percent`: int (can be negative or positive)
  Future<void> saveDeviceCalibration({
    required String deviceId,
    required String plantType,
    required int offsetPercent,
  }) async {
    if (isDemoDevice(deviceId)) {
      final cal = <Object?, Object?>{
        'plant_type': plantType,
        'offset_percent': offsetPercent,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };
      _demoDeviceState = {..._demoDeviceState, 'calibration': cal};
      _emitDemoDevice();
      return;
    }

    await deviceRef(deviceId).child('calibration').update({
      'plant_type': plantType,
      'offset_percent': offsetPercent,
      'last_updated': ServerValue.timestamp,
    });
  }

  Future<void> setPumpDurationSeconds({
    required String deviceId,
    required int seconds,
  }) async {
    if (seconds < 1 || seconds > 60) {
      throw ArgumentError('Durasi pompa harus di antara 1-60 detik.');
    }

    if (isDemoDevice(deviceId)) {
      final settings = _readMap(_demoDeviceState['settings']);
      settings['pump_duration_seconds'] = seconds;
      _demoDeviceState = {
        ..._demoDeviceState,
        'settings': settings,
        'last_update': DateTime.now().millisecondsSinceEpoch,
      };
      _emitDemoDevice();
      return;
    }

    await deviceRef(deviceId).child('settings').update({
      'pump_duration_seconds': seconds,
      'updated_at': ServerValue.timestamp,
    });
  }

  Future<void> triggerWaterNow({
    required String uid,
    required String deviceId,
    required int moistureBefore,
  }) async {
    final durationSeconds = await fetchPumpDurationSeconds(deviceId);

    if (isDemoDevice(deviceId)) {
      _triggerDemoWater(
        uid: uid,
        durationSeconds: durationSeconds,
        moistureBefore: moistureBefore,
      );
      return;
    }

    final deviceReference = deviceRef(deviceId);
    final historyReference = deviceReference.child('history').push();
    final currentDeviceData = await fetchDevice(deviceId);
    final gameResult = _buildGameResult(
      game: _readMap(currentDeviceData['game']),
      moistureBefore: moistureBefore,
      moistureAfter: _estimateMoistureAfter(
        moistureBefore: moistureBefore,
        durationSeconds: durationSeconds,
      ),
      durationSeconds: durationSeconds,
      eventTimeMs: DateTime.now().millisecondsSinceEpoch,
    );

    await deviceReference.update({
      'control/siram': true,
      'control/requested_at': ServerValue.timestamp,
      'control/requested_by': uid,
      'control/duration_seconds': durationSeconds,
      'game': gameResult.updatedGame,
      if (historyReference.key != null)
        'history/${historyReference.key}': {
          ...gameResult.historyEntry,
          'action': 'manual_water',
          'title': 'Siram Sekarang',
          'device_id': deviceId,
          'triggered_by': uid,
          'created_at': ServerValue.timestamp,
        },
    });
  }

  void _triggerDemoWater({
    required String uid,
    required int durationSeconds,
    required int moistureBefore,
  }) {
    _demoWaterTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch;
    final control = _readMap(_demoDeviceState['control']);
    control.addAll({
      'siram': true,
      'requested_at': now,
      'requested_by': uid,
      'duration_seconds': durationSeconds,
    });

    final moistureAfter = _estimateMoistureAfter(
      moistureBefore: moistureBefore,
      durationSeconds: durationSeconds,
    );
    final gameResult = _buildGameResult(
      game: _readMap(_demoDeviceState['game']),
      moistureBefore: moistureBefore,
      moistureAfter: moistureAfter,
      durationSeconds: durationSeconds,
      eventTimeMs: now,
    );

    _demoDeviceState = {
      ..._demoDeviceState,
      'status': 'watering',
      'last_update': now,
      'control': control,
      'game': gameResult.updatedGame,
    };
    _demoHistory = [
      {
        ...gameResult.historyEntry,
        'action': 'manual_water',
        'title': 'Siram Sekarang',
        'device_id': demoDeviceId,
        'triggered_by': uid,
        'created_at': now,
      },
      ..._demoHistory,
    ];

    _emitDemoDevice();
    _emitDemoHistory();

    _demoWaterTimer = Timer(Duration(seconds: durationSeconds), () {
      final updatedControl = _readMap(_demoDeviceState['control']);
      updatedControl['siram'] = false;

      _demoDeviceState = {
        ..._demoDeviceState,
        'status': 'idle',
        'moisture': moistureAfter,
        'last_update': DateTime.now().millisecondsSinceEpoch,
        'control': updatedControl,
      };

      _emitDemoDevice();
    });
  }

  void _emitDemoDevice() {
    _demoDeviceController.add(_cloneMap(_demoDeviceState));
  }

  void _emitDemoHistory() {
    _demoHistoryController.add(_cloneHistory(_demoHistory.length));
  }

  List<Map<Object?, Object?>> _cloneHistory(int limit) {
    return _limitHistory(
      _demoHistory,
      limit,
    ).map((item) => _cloneMap(item)).toList();
  }

  List<Map<Object?, Object?>> _limitHistory(
    List<Map<Object?, Object?>> source,
    int limit,
  ) {
    if (source.length <= limit) {
      return List<Map<Object?, Object?>>.from(source);
    }
    return source.take(limit).toList();
  }

  Map<Object?, Object?> _snapshotToMap(Object? rawValue) {
    if (rawValue is Map) {
      return Map<Object?, Object?>.from(rawValue);
    }
    return <Object?, Object?>{};
  }

  List<Map<Object?, Object?>> _snapshotToHistory(Object? rawValue, int limit) {
    if (rawValue is! Map) {
      return <Map<Object?, Object?>>[];
    }

    final map = Map<Object?, Object?>.from(rawValue);
    final entries = map.entries.toList()
      ..sort(
        (a, b) => _readInt(b.value is Map ? (b.value as Map)['created_at'] : 0)
            .compareTo(
              _readInt(a.value is Map ? (a.value as Map)['created_at'] : 0),
            ),
      );

    return entries.take(limit).map((entry) => _readMap(entry.value)).toList();
  }

  static Map<Object?, Object?> _cloneMap(Map<Object?, Object?> source) {
    final result = <Object?, Object?>{};
    for (final entry in source.entries) {
      final value = entry.value;
      if (value is Map) {
        result[entry.key] = _cloneMap(Map<Object?, Object?>.from(value));
      } else if (value is List) {
        result[entry.key] = List<Object?>.from(value);
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  static Map<Object?, Object?> _readMap(Object? value) {
    if (value is Map) {
      return Map<Object?, Object?>.from(value);
    }
    return <Object?, Object?>{};
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }

  int levelForScore(int score) {
    final safeScore = math.max(0, score);
    for (var index = _levelThresholds.length - 1; index >= 0; index--) {
      if (safeScore >= _levelThresholds[index]) {
        return index + 1;
      }
    }
    return 1;
  }

  Map<String, int> levelProgressForScore(int score) {
    final safeScore = math.max(0, score);
    final level = levelForScore(safeScore);
    final currentFloor = _levelThresholds[level - 1];
    final nextFloor = level < _levelThresholds.length
        ? _levelThresholds[level]
        : currentFloor + 400;
    return <String, int>{
      'level': level,
      'score': safeScore,
      'current_floor': currentFloor,
      'next_floor': nextFloor,
      'xp_in_level': safeScore - currentFloor,
      'xp_needed': nextFloor - currentFloor,
      'xp_remaining': math.max(0, nextFloor - safeScore),
    };
  }

  int _estimateMoistureAfter({
    required int moistureBefore,
    required int durationSeconds,
  }) {
    return (moistureBefore + (durationSeconds * 4)).clamp(0, 100);
  }

  _GameResult _buildGameResult({
    required Map<Object?, Object?> game,
    required int moistureBefore,
    required int moistureAfter,
    required int durationSeconds,
    required int eventTimeMs,
  }) {
    var scoreDelta = 0;
    final reasons = <String>[];
    final previousScore = _readInt(game['score']);
    final previousWateredAt = _readInt(game['last_watered_at']);

    if (moistureBefore <= severeDryMoistureThreshold) {
      scoreDelta -= 12;
      reasons.add('Tanaman terlalu kering sebelum disiram.');
    } else if (moistureBefore <= dryMoistureThreshold) {
      scoreDelta -= 6;
      reasons.add('Tanaman sempat kekurangan air.');
    }

    if (previousWateredAt > 0) {
      final hoursSinceLastWater = DateTime.fromMillisecondsSinceEpoch(
        eventTimeMs,
      ).difference(
        DateTime.fromMillisecondsSinceEpoch(previousWateredAt),
      ).inHours;
      if (moistureBefore <= dryMoistureThreshold && hoursSinceLastWater >= 18) {
        scoreDelta -= 8;
        reasons.add('Kekeringan berlangsung terlalu lama.');
      } else if (moistureBefore <= dryMoistureThreshold &&
          hoursSinceLastWater >= 8) {
        scoreDelta -= 4;
        reasons.add('Penyiraman terlambat dilakukan.');
      }
    }

    if (moistureBefore >= 75) {
      scoreDelta -= 6;
      reasons.add('Penyiraman dilakukan saat tanah masih basah.');
    } else if (moistureBefore >= idealMoistureMin &&
        moistureBefore <= idealMoistureMax) {
      scoreDelta += 4;
      reasons.add('Kondisi tanah masih aman saat dicek.');
    } else if (moistureBefore > dryMoistureThreshold &&
        moistureBefore < idealMoistureMin) {
      scoreDelta += 10;
      reasons.add('Penyiraman dilakukan pada momen yang tepat.');
    }

    if (moistureAfter > 95) {
      scoreDelta -= 14;
      reasons.add('Penyiraman berlebihan membuat tanah terlalu jenuh.');
    } else if (moistureAfter > overwaterMoistureThreshold) {
      scoreDelta -= 8;
      reasons.add('Hasil penyiraman sedikit berlebihan.');
    } else if (moistureAfter >= 45 && moistureAfter <= 75) {
      scoreDelta += 8;
      reasons.add('Kelembapan akhir berada di zona ideal.');
    } else if (moistureAfter >= idealMoistureMin &&
        moistureAfter <= overwaterMoistureThreshold) {
      scoreDelta += 4;
      reasons.add('Kelembapan akhir cukup sehat.');
    }

    scoreDelta = scoreDelta.clamp(-30, 18);

    final updatedScore = math.max(0, previousScore + scoreDelta);
    final levelProgress = levelProgressForScore(updatedScore);
    final reasonText = reasons.isEmpty
        ? 'Belum ada perubahan skor yang signifikan.'
        : reasons.join(' ');

    return _GameResult(
      updatedGame: <Object?, Object?>{
        ...game,
        'score': updatedScore,
        'level': levelProgress['level'],
        'xp_in_level': levelProgress['xp_in_level'],
        'xp_to_next_level': levelProgress['xp_remaining'],
        'level_floor_score': levelProgress['current_floor'],
        'next_level_score': levelProgress['next_floor'],
        'last_score_delta': scoreDelta,
        'last_score_reason': reasonText,
        'last_watered_at': eventTimeMs,
        'last_moisture_before': moistureBefore,
        'last_moisture_after_estimate': moistureAfter,
        'last_duration_seconds': durationSeconds,
      },
      historyEntry: <Object?, Object?>{
        'moisture_before': moistureBefore,
        'moisture_after': moistureAfter,
        'duration_seconds': durationSeconds,
        'score_delta': scoreDelta,
        'score_after': updatedScore,
        'level_after': levelProgress['level'],
        'score_reason': reasonText,
      },
    );
  }
}

class _GameResult {
  const _GameResult({required this.updatedGame, required this.historyEntry});

  final Map<Object?, Object?> updatedGame;
  final Map<Object?, Object?> historyEntry;
}
