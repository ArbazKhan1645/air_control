// ignore_for_file: deprecated_member_use

import 'package:air_control/src/features/home/domain/models/motion_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Visual direction indicator that shows detected shake direction
class DirectionIndicator extends StatefulWidget {
  final ShakeDirection? direction;
  final bool isVisible;

  const DirectionIndicator({super.key, this.direction, this.isVisible = false});

  @override
  State<DirectionIndicator> createState() => _DirectionIndicatorState();
}

class _DirectionIndicatorState extends State<DirectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(DirectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && widget.direction != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.direction == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final opacity = (1 - progress).clamp(0, 1).toDouble();

            return Opacity(opacity: opacity, child: _buildIndicator(context));
          },
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context) {
    final size = MediaQuery.of(context).size;

    switch (widget.direction!) {
      case ShakeDirection.forward:
        return _DirectionArrow(
          icon: Icons.keyboard_double_arrow_up_rounded,
          label: 'PREVIOUS',
          color: Colors.blue,
          alignment: Alignment.topCenter,
          offset: Offset(0, size.height * 0.15),
        );

      case ShakeDirection.backward:
        return _DirectionArrow(
          icon: Icons.keyboard_double_arrow_down_rounded,
          label: 'NEXT',
          color: Colors.purple,
          alignment: Alignment.bottomCenter,
          offset: Offset(0, -size.height * 0.2),
        );

      case ShakeDirection.left:
        return _DirectionArrow(
          icon: Icons.keyboard_double_arrow_left_rounded,
          label: 'DECREASE',
          color: Colors.orange,
          alignment: Alignment.centerLeft,
          offset: Offset(size.width * 0.15, 0),
        );

      case ShakeDirection.right:
        return _DirectionArrow(
          icon: Icons.keyboard_double_arrow_right_rounded,
          label: 'INCREASE',
          color: Colors.green,
          alignment: Alignment.centerRight,
          offset: Offset(-size.width * 0.15, 0),
        );

      case ShakeDirection.none:
        return const SizedBox.shrink();
    }
  }
}

class _DirectionArrow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Alignment alignment;
  final Offset offset;

  const _DirectionArrow({
    required this.icon,
    required this.label,
    required this.color,
    required this.alignment,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child:
            Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 48),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 100.ms),
      ),
    );
  }
}

/// Instructions overlay showing shake gestures
class InstructionsOverlay extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onDismiss;

  const InstructionsOverlay({
    super.key,
    required this.isVisible,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 24),
                const Text(
                  'SHAKE CONTROLS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use device motion to navigate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 48),

                // Navigation instructions
                const _InstructionRow(
                  icon: Icons.keyboard_double_arrow_up_rounded,
                  iconColor: Colors.blue,
                  title: 'Tilt Forward',
                  subtitle: 'Previous content',
                ),
                const SizedBox(height: 16),
                const _InstructionRow(
                  icon: Icons.keyboard_double_arrow_down_rounded,
                  iconColor: Colors.purple,
                  title: 'Tilt Backward',
                  subtitle: 'Next content',
                ),
                const SizedBox(height: 32),

                // Rating instructions
                const Divider(color: Colors.white24),
                const SizedBox(height: 32),
                const _InstructionRow(
                  icon: Icons.keyboard_double_arrow_right_rounded,
                  iconColor: Colors.green,
                  title: 'Tilt Right',
                  subtitle: 'Show/Increase rating',
                ),
                const SizedBox(height: 16),
                const _InstructionRow(
                  icon: Icons.keyboard_double_arrow_left_rounded,
                  iconColor: Colors.orange,
                  title: 'Tilt Left',
                  subtitle: 'Decrease/Hide rating',
                ),
                const SizedBox(height: 16),
                const _InstructionRow(
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.teal,
                  title: 'Tilt Forward (in rating)',
                  subtitle: 'Submit rating',
                ),

                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Tap anywhere to start',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InstructionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
