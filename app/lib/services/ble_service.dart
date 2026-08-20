// lib/services/ble_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_sample.dart';
import '../models/device_status.dart';

class BleService {
  static const serviceUuid        = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const sensorDataCharUuid = "4fafc202-1fb5-459e-8fcc-c5c9c331914b";
  static const controlCharUuid    = "4fafc203-1fb5-459e-8fcc-c5c9c331914b";
  static const statusCharUuid     = "4fafc204-1fb5-459e-8fcc-c5c9c331914b";

  final _sampleController = StreamController<SensorSample>.broadcast();
  Stream<SensorSample> get sensorStream => _sampleController.stream;
  Stream<SensorSample> get sampleStream => _sampleController.stream;

  // scanning / connecting / connected / disconnected — surfaced to the UI (task 6)
  final _connectionStateController = StreamController<String>.broadcast();
  Stream<String> get connectionState => _connectionStateController.stream;

  final _statusController = StreamController<DeviceStatus>.broadcast();
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  BluetoothDevice? _device;
  BluetoothCharacteristic? _sensorChar;
  BluetoothCharacteristic? _controlChar;
  BluetoothCharacteristic? _statusChar;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<int>>? _sensorSub;
  StreamSubscription<List<int>>? _statusSub;

  int _backoffMs = 500;
  bool _isManualDisconnect = false;

  Future<void> scanAndConnect() async {
    _isManualDisconnect = false;
    _connectionStateController.add('scanning');
    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)], // filter by Service UUID, never by name (task 2)
        timeout: const Duration(seconds: 10),
      );

      final results = await FlutterBluePlus.scanResults.first;
      await FlutterBluePlus.stopScan();

      if (results.isEmpty) {
        _connectionStateController.add('disconnected');
        return;
      }
      _device = results.first.device;
      await _connect();
    } catch (_) {
      _connectionStateController.add('disconnected');
    }
  }

  // Alias for scanAndConnect
  Future<void> startScan() => scanAndConnect();

  Future<void> disconnect() async {
    _isManualDisconnect = true;
    await _cancelSubscriptions();
    await _device?.disconnect();
    _device = null;
    _sensorChar = null;
    _controlChar = null;
    _statusChar = null;
    _connectionStateController.add('disconnected');
  }

  Future<void> _connect() async {
    if (_device == null) return;
    _connectionStateController.add('connecting');

    await _connSub?.cancel();
    _connSub = _device!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected && !_isManualDisconnect) {
        _connectionStateController.add('disconnected');
        _reconnectWithBackoff();
      }
    });

    await _device!.connect(
      license: License.nonprofit,
      autoConnect: false,
    );

    try {
      await _device!.requestMtu(247); // matches integration-contract.md's MTU note
    } catch (_) {
      // Non-fatal if MTU request is rejected/unsupported
    }

    final services = await _device!.discoverServices();
    final target = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == serviceUuid,
    );

    for (final c in target.characteristics) {
      final uuid = c.uuid.toString().toLowerCase();
      if (uuid == sensorDataCharUuid) _sensorChar = c;
      if (uuid == controlCharUuid) _controlChar = c;
      if (uuid == statusCharUuid) _statusChar = c;
    }

    if (_sensorChar != null) {
      await _sensorChar!.setNotifyValue(true);
      _sensorSub = _sensorChar!.onValueReceived.listen(_onPacket);
    }

    if (_statusChar != null) {
      if (_statusChar!.properties.notify) {
        await _statusChar!.setNotifyValue(true);
        _statusSub = _statusChar!.onValueReceived.listen(_onStatusPacket);
      }
      if (_statusChar!.properties.read) {
        try {
          final val = await _statusChar!.read();
          _onStatusPacket(val);
        } catch (_) {}
      }
    }

    _connectionStateController.add('connected');
    _backoffMs = 500; // reset backoff on a clean connect
  }

  void _onPacket(List<int> data) {
    if (data.isEmpty) return;
    try {
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      _sampleController.add(SensorSample.fromJson(json));
    } catch (e) {
      // A parse failure is a dropped packet — log and skip, never crash (task 4)
      // ignore: avoid_print
      print('BLE: dropped malformed packet: $e');
    }
  }

  void _onStatusPacket(List<int> data) {
    if (data.isEmpty) return;
    try {
      final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
      _statusController.add(DeviceStatus.fromJson(json));
    } catch (_) {
      // Malformed status packet dropped
    }
  }

  Future<void> _reconnectWithBackoff() async {
    if (_isManualDisconnect) return;
    await Future.delayed(Duration(milliseconds: _backoffMs));
    _backoffMs = (_backoffMs * 2).clamp(500, 8000);
    try {
      await _connect();
    } catch (_) {
      if (!_isManualDisconnect) {
        _reconnectWithBackoff();
      }
    }
  }

  Future<void> sendControl(Map<String, dynamic> cmd) async {
    if (_controlChar == null) return;
    await _controlChar!.write(utf8.encode(jsonEncode(cmd)));
  }

  // Convenience helper methods
  Future<void> calibrate() => sendControl({'cmd': 'calibrate'});

  Future<void> setThreshold(int value) =>
      sendControl({'cmd': 'set_threshold', 'value': value});

  Future<void> setSensitivity({required String mode}) =>
      sendControl({'cmd': 'set_sensitivity', 'mode': mode});

  Future<void> _cancelSubscriptions() async {
    await _sensorSub?.cancel();
    await _statusSub?.cancel();
    await _connSub?.cancel();
    _sensorSub = null;
    _statusSub = null;
    _connSub = null;
  }

  void dispose() {
    _isManualDisconnect = true;
    _cancelSubscriptions();
    _sampleController.close();
    _connectionStateController.close();
    _statusController.close();
  }
}
