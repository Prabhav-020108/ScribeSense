import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/sensor_sample.dart';
import '../services/ble_service.dart';

enum SessionState { idle, recording, paused }

class SessionProvider extends ChangeNotifier {
  SessionProvider(this._ble) {
    _sub = _ble.sensorStream.listen(_onSample);
    _throttle = Timer.periodic(const Duration(milliseconds: 66), (_) {
      if (_dirty) {
        _dirty = false;
        notifyListeners();
      }
    });
  }

  final BleService _ble;
  StreamSubscription<SensorSample>? _sub;
  Timer? _throttle;
  bool _dirty = false;

  SessionState _state = SessionState.idle;
  SessionState get state => _state;

  static const int _bufferSize = 200;
  final Queue<SensorSample> _buffer = Queue<SensorSample>();
  UnmodifiableListView<SensorSample> get recentSamples =>
      UnmodifiableListView(_buffer);

  SensorSample? _latest;
  SensorSample? get latest => _latest;

  DateTime? _sessionStart;
  Duration get elapsed => _sessionStart == null
      ? Duration.zero
      : DateTime.now().difference(_sessionStart!);

  int _highPressureEvents = 0;
  int get highPressureEventCount => _highPressureEvents;

  void startSession() {
    _state = SessionState.recording;
    _sessionStart = DateTime.now();
    _highPressureEvents = 0;
    _buffer.clear();
    notifyListeners();
  }

  void pauseSession() {
    if (_state == SessionState.recording) {
      _state = SessionState.paused;
      notifyListeners();
    }
  }

  void resumeSession() {
    if (_state == SessionState.paused) {
      _state = SessionState.recording;
      notifyListeners();
    }
  }

  void endSession() {
    _state = SessionState.idle;
    _sessionStart = null;
    notifyListeners();
  }

  void _onSample(SensorSample sample) {
    _latest = sample;
    _buffer.addLast(sample);
    if (_buffer.length > _bufferSize) _buffer.removeFirst();
    // TODO(contract-v1.1): compare against real high_pressure_threshold once the
    // Status characteristic carries it. Using `vibrating` as a stand-in for now.
    if (sample.vibrating) _highPressureEvents++;
    _dirty = true;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _throttle?.cancel();
    super.dispose();
  }
}
