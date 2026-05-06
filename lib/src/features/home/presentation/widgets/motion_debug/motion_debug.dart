// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:air_control/src/features/home/domain/models/motion_models.dart';
import 'package:flutter/material.dart';

/// Debug overlay showing motion detection visualization
class MotionDebugOverlay extends StatefulWidget {
  final Stream<Map<String, dynamic>> debugStream;
  final Stream<ShakeEvent>? shakeStream;
  final bool isVisible;

  const MotionDebugOverlay({
    super.key,
    required this.debugStream,
    this.shakeStream,
    this.isVisible = true,
  });

  @override
  State<MotionDebugOverlay> createState() => _MotionDebugOverlayState();
}

class _MotionDebugOverlayState extends State<MotionDebugOverlay> {
  Map<String, dynamic> _currentData = {};
  ShakeDirection? _lastDirection;
  DateTime? _lastShakeTime;
  StreamSubscription? _debugSub;
  StreamSubscription? _shakeSub;

  // History for graph
  final List<double> _magnitudeHistory = [];
  static const int _historySize = 50;

  @override
  void initState() {
    super.initState();
    _debugSub = widget.debugStream.listen((data) {
      if (!mounted) return;
      setState(() {
        _currentData = data;
        final mag = _toDouble(data['magnitude']);
        if (mag != null) {
          _magnitudeHistory.add(mag);
          if (_magnitudeHistory.length > _historySize) {
            _magnitudeHistory.removeAt(0);
          }
        }
      });
    });

    _shakeSub = widget.shakeStream?.listen((event) {
      if (!mounted) return;
      setState(() {
        _lastDirection = event.direction;
        _lastShakeTime = event.timestamp;
      });

      // Clear after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _lastShakeTime == event.timestamp) {
          setState(() {
            _lastDirection = null;
          });
        }
      });
    });
  }

  /// Safely convert dynamic to double
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely get double from nested map
  double _getNestedDouble(
    Map<String, dynamic>? map,
    String key, [
    double defaultValue = 0.0,
  ]) {
    if (map == null) return defaultValue;
    final value = map[key];
    return _toDouble(value) ?? defaultValue;
  }

  @override
  void dispose() {
    _debugSub?.cancel();
    _shakeSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final filtered = _currentData['filtered'] as Map<String, dynamic>?;
    final magnitude = _toDouble(_currentData['magnitude']) ?? 0.0;
    final threshold = _toDouble(_currentData['threshold']) ?? 2.5;

    return Positioned(
      left: 12,
      top: MediaQuery.of(context).padding.top + 60,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.sensors, color: Colors.blue[400], size: 16),
                const SizedBox(width: 6),
                const Text(
                  'MOTION DEBUG',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Direction indicator
            _buildDirectionIndicator(filtered),
            const SizedBox(height: 12),

            // Magnitude graph
            _buildMagnitudeGraph(threshold),
            const SizedBox(height: 8),

            // Raw values
            _buildValueRow('X', _getNestedDouble(filtered, 'x')),
            _buildValueRow('Y', _getNestedDouble(filtered, 'y')),
            _buildValueRow('Z', _getNestedDouble(filtered, 'z')),
            const Divider(color: Colors.white24, height: 16),
            _buildValueRow('Mag', magnitude, highlight: magnitude > threshold),
            _buildValueRow('Thresh', threshold),

            // Detection status
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (_currentData['canDetect'] == true)
                          ? Colors.green.withOpacity(0.6)
                          : Colors.red.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (_currentData['canDetect'] == true)
                          ? 'READY'
                          : 'COOLDOWN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_currentData['isShaking'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SHAKING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Last detected direction
            if (_lastDirection != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _directionToString(_lastDirection!),
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionIndicator(Map<String, dynamic>? filtered) {
    final x = _getNestedDouble(filtered, 'x');
    final y = _getNestedDouble(filtered, 'y');
    final magnitude = _toDouble(_currentData['magnitude']) ?? 0.0;
    final threshold = _toDouble(_currentData['threshold']) ?? 2.5;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Direction labels
          const Positioned(
            top: 4,
            child: Text(
              'F',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          const Positioned(
            bottom: 4,
            child: Text(
              'B',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          const Positioned(
            left: 4,
            child: Text(
              'L',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          const Positioned(
            right: 4,
            child: Text(
              'R',
              style: TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),

          // Crosshairs
          Container(width: 1, height: 60, color: Colors.white12),
          Container(width: 60, height: 1, color: Colors.white12),

          // Indicator dot
          Transform.translate(
            offset: Offset(
              (x * 10).clamp(-30.0, 30.0),
              (-y * 10).clamp(-30.0, 30.0),
            ),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getIndicatorColor(magnitude, threshold),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getIndicatorColor(
                      magnitude,
                      threshold,
                    ).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIndicatorColor(double magnitude, double threshold) {
    if (magnitude > threshold) {
      return Colors.green;
    } else if (magnitude > threshold * 0.7) {
      return Colors.yellow;
    }
    return Colors.blue;
  }

  Widget _buildMagnitudeGraph(double threshold) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _MagnitudeGraphPainter(
          values: _magnitudeHistory,
          threshold: threshold,
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.green : Colors.white54,
              fontSize: 11,
            ),
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              color: highlight ? Colors.green : Colors.white,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _directionToString(ShakeDirection direction) {
    switch (direction) {
      case ShakeDirection.forward:
        return 'FORWARD';
      case ShakeDirection.backward:
        return 'BACKWARD';
      case ShakeDirection.left:
        return 'LEFT';
      case ShakeDirection.right:
        return 'RIGHT';
      case ShakeDirection.none:
        return 'NONE';
    }
  }
}

class _MagnitudeGraphPainter extends CustomPainter {
  final List<double> values;
  final double threshold;

  _MagnitudeGraphPainter({required this.values, required this.threshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = max(values.reduce(max), threshold * 2);

    // Draw threshold line
    final thresholdY = size.height - (threshold / maxValue * size.height);
    final thresholdPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, thresholdY),
      Offset(size.width, thresholdY),
      thresholdPaint,
    );

    // Draw graph
    final path = Path();
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < values.length; i++) {
      final x = i / values.length * size.width;
      final y = size.height - (values[i] / maxValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MagnitudeGraphPainter oldDelegate) {
    return true;
  }
}
