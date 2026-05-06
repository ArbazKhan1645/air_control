import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:air_control/src/features/home/domain/models/motion_models.dart';

final motionServiceProvider = Provider((ref) => MotionService());

class MotionService {
  final MotionConfig config;
  late final LowPassFilter _lowPassFilter;

  bool _isShaking = false;
  DateTime? _shakeStartTime;
  DateTime? _lastShakeTime;
  bool _canDetect = true;

  double _baselineX = 0, _baselineY = 0, _baselineZ = 0;
  bool _isCalibrated = false;
  final List<AccelerationSample> _calibrationSamples = [];

  StreamSubscription<UserAccelerometerEvent>? _userAccelSub;
  
  final _shakeController = StreamController<ShakeEvent>.broadcast();
  Stream<ShakeEvent> get onShake => _shakeController.stream;

  final _debugController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get debugStream => _debugController.stream;

  bool get isCalibrated => _isCalibrated;

  MotionService({this.config = const MotionConfig()}) {
    _lowPassFilter = LowPassFilter(alpha: config.lowPassAlpha);
  }

  void start() {
    _userAccelSub = userAccelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 16),
    ).listen((event) {
      _processRaw(event.x, event.y, event.z);
    });
  }

  void stop() {
    _userAccelSub?.cancel();
  }

  void _processRaw(double x, double y, double z) {
    final sample = AccelerationSample(
      x: x,
      y: y,
      z: z,
      timestamp: DateTime.now(),
    );

    final filtered = _lowPassFilter.filter(sample);

    if (!_isCalibrated) {
      _calibrate(filtered);
      return;
    }

    final calibrated = AccelerationSample(
      x: filtered.x - _baselineX,
      y: filtered.y - _baselineY,
      z: filtered.z - _baselineZ,
      timestamp: filtered.timestamp,
    );

    _detectShake(calibrated);

    _debugController.add({
      'raw': {'x': x, 'y': y, 'z': z},
      'filtered': {'x': calibrated.x, 'y': calibrated.y, 'z': calibrated.z},
      'magnitude': calibrated.magnitude,
      'threshold': config.shakeThreshold,
      'canDetect': _canDetect,
      'isShaking': _isShaking,
    });
  }

  void _calibrate(AccelerationSample sample) {
    _calibrationSamples.add(sample);

    if (_calibrationSamples.length >= 20) {
      double sumX = 0, sumY = 0, sumZ = 0;
      for (final s in _calibrationSamples) {
        sumX += s.x;
        sumY += s.y;
        sumZ += s.z;
      }

      _baselineX = sumX / _calibrationSamples.length;
      _baselineY = sumY / _calibrationSamples.length;
      _baselineZ = sumZ / _calibrationSamples.length;

      _isCalibrated = true;
      _calibrationSamples.clear();
      
      debugPrint('✓ Calibrated: x=$_baselineX, y=$_baselineY, z=$_baselineZ');
    }
  }

  void recalibrate() {
    _isCalibrated = false;
    _calibrationSamples.clear();
    _baselineX = _baselineY = _baselineZ = 0;
    _lowPassFilter.reset();
    _isShaking = false;
    _canDetect = true;
    _shakeStartTime = null;
  }

  void _detectShake(AccelerationSample sample) {
    final now = DateTime.now();
    final magnitude = sample.magnitude;

    if (_lastShakeTime != null) {
      final elapsed = now.difference(_lastShakeTime!).inMilliseconds;
      _canDetect = elapsed >= config.cooldownMs;
    }

    if (!_isShaking && _canDetect && magnitude > config.shakeThreshold) {
      final direction = _getDirectionFromSample(sample);

      if (direction != ShakeDirection.none) {
        _shakeController.add(
          ShakeEvent(
            direction: direction,
            intensity: magnitude,
            timestamp: now,
          ),
        );

        _lastShakeTime = now;
        _canDetect = false;
        _isShaking = true;
        _shakeStartTime = now;
      }
      return;
    }

    if (_isShaking) {
      final duration = now.difference(_shakeStartTime!).inMilliseconds;
      if (magnitude < config.shakeThreshold * 0.6 || duration > config.maxShakeDurationMs) {
        _isShaking = false;
        _shakeStartTime = null;
      }
    }
  }

  ShakeDirection _getDirectionFromSample(AccelerationSample sample) {
    final x = sample.x;
    final y = sample.y;
    final absX = x.abs();
    final absY = y.abs();
    final threshold = config.directionThreshold;

    if (absX < threshold && absY < threshold) return ShakeDirection.none;

    if (absY >= absX && absY >= threshold) {
      return y > 0 ? ShakeDirection.backward : ShakeDirection.forward;
    }

    if (absX > absY && absX >= threshold) {
      if (absX > absY * 1.4) {
        return x > 0 ? ShakeDirection.right : ShakeDirection.left;
      }
    }

    return ShakeDirection.none;
  }

  void dispose() {
    stop();
    _shakeController.close();
    _debugController.close();
  }
}

class LowPassFilter {
  final double alpha;
  double _lastX = 0, _lastY = 0, _lastZ = 0;
  bool _initialized = false;

  LowPassFilter({this.alpha = 0.2});

  AccelerationSample filter(AccelerationSample sample) {
    if (!_initialized) {
      _lastX = sample.x;
      _lastY = sample.y;
      _lastZ = sample.z;
      _initialized = true;
      return sample;
    }

    _lastX = alpha * sample.x + (1 - alpha) * _lastX;
    _lastY = alpha * sample.y + (1 - alpha) * _lastY;
    _lastZ = alpha * sample.z + (1 - alpha) * _lastZ;

    return AccelerationSample(
      x: _lastX,
      y: _lastY,
      z: _lastZ,
      timestamp: sample.timestamp,
    );
  }

  void reset() {
    _initialized = false;
    _lastX = _lastY = _lastZ = 0;
  }
}
