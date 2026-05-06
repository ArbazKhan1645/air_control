// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated star rating overlay widget
class RatingOverlay extends StatefulWidget {
  final int rating;
  final bool isVisible;
  final bool isSubmitting;
  final VoidCallback? onDismiss;
  final Function(int)? onRatingChanged;
  final VoidCallback? onSubmit;

  const RatingOverlay({
    super.key,
    required this.rating,
    required this.isVisible,
    this.isSubmitting = false,
    this.onDismiss,
    this.onRatingChanged,
    this.onSubmit,
  });

  @override
  State<RatingOverlay> createState() => _RatingOverlayState();
}

class _RatingOverlayState extends State<RatingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _previousRating = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _previousRating = widget.rating;
  }

  @override
  void didUpdateWidget(RatingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when rating changes
    if (widget.rating != _previousRating) {
      _pulseController.forward(from: 0);
      HapticFeedback.lightImpact();
      _previousRating = widget.rating;
    }

    // Heavy haptic on submit
    if (widget.isSubmitting && !oldWidget.isSubmitting) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.35,
      child:
          Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      const Text(
                        'RATE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stars column
                      Column(
                        children: List.generate(5, (index) {
                          final starNumber = 5 - index; // 5 at top, 1 at bottom
                          final isActive = starNumber <= widget.rating;

                          return GestureDetector(
                            onTap: () {
                              widget.onRatingChanged?.call(starNumber);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: AnimatedBuilder(
                                listenable: _pulseController,
                                builder: (context, child) {
                                  final scale = starNumber == widget.rating
                                      ? 1.0 + (_pulseController.value * 0.3)
                                      : 1.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      isActive
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: isActive
                                          ? _getStarColor(widget.rating)
                                          : Colors.white30,
                                      size: 36,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 12),

                      // Rating number
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          widget.rating.toString(),
                          key: ValueKey(widget.rating),
                          style: TextStyle(
                            color: _getStarColor(widget.rating),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Rating label
                      Text(
                        _getRatingLabel(widget.rating),
                        style: TextStyle(
                          color: _getStarColor(widget.rating).withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Submit hint
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Forward to submit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(target: widget.isVisible ? 1 : 0)
              .fadeIn(duration: 200.ms)
              .slideX(
                begin: 0.3,
                end: 0,
                duration: 200.ms,
                curve: Curves.easeOut,
              ),
    );
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 1:
        return const Color(0xFFFF4444);
      case 2:
        return const Color(0xFFFF8C00);
      case 3:
        return const Color(0xFFFFD700);
      case 4:
        return const Color(0xFF9ACD32);
      case 5:
        return const Color(0xFF00D084);
      default:
        return Colors.white;
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      case 5:
        return 'Amazing!';
      default:
        return '';
    }
  }
}

/// Animated builder helper
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  }) : super();

  @override
  Widget build(BuildContext context) => builder(context, child);
}

/// Rating submitted success overlay
class RatingSubmittedOverlay extends StatelessWidget {
  final int rating;
  final bool isVisible;

  const RatingSubmittedOverlay({
    super.key,
    required this.rating,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Center(
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00D084).withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF00D084),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Rating Submitted!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        rating,
                        (index) => const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 200.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 150.ms),
    );
  }
}
