import 'dart:math';

enum ShakeDirection { forward, backward, left, right, none }

enum InteractionState { browsing, ratingActive, ratingConfirm }

class MotionConfig {
  final double shakeThreshold;
  final double directionThreshold;
  final int cooldownMs;
  final int minShakeDurationMs;
  final int maxShakeDurationMs;
  final double lowPassAlpha;

  const MotionConfig({
    this.shakeThreshold = 0.8,
    this.directionThreshold = 0.5,
    this.cooldownMs = 350,
    this.minShakeDurationMs = 20,
    this.maxShakeDurationMs = 400,
    this.lowPassAlpha = 0.3,
  });
}

class AccelerationSample {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  AccelerationSample({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  double get magnitude => sqrt(x * x + y * y + z * z);
}

class ShakeEvent {
  final ShakeDirection direction;
  final double intensity;
  final DateTime timestamp;

  ShakeEvent({
    required this.direction,
    required this.intensity,
    required this.timestamp,
  });
}
