import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:air_control/src/features/home/domain/models/motion_models.dart';
import 'package:air_control/src/features/home/presentation/controllers/content_controller.dart';
import 'package:air_control/src/features/home/presentation/controllers/interaction_controller.dart';
import 'package:air_control/src/features/home/presentation/widgets/callibration_overlay/callibration_overlay.dart';
import 'package:air_control/src/features/home/presentation/widgets/content_card/content_card.dart';
import 'package:air_control/src/features/home/presentation/widgets/direction_indicator/direction_indicator.dart';
import 'package:air_control/src/features/home/presentation/widgets/motion_debug/motion_debug.dart';
import 'package:air_control/src/features/home/presentation/widgets/overlay_widget/rating_overlay.dart';
import 'package:air_control/src/services/motion_service.dart';

class AirControlHomeScreen extends ConsumerStatefulWidget {
  const AirControlHomeScreen({super.key});

  @override
  ConsumerState<AirControlHomeScreen> createState() => _AirControlHomeScreenState();
}

class _AirControlHomeScreenState extends ConsumerState<AirControlHomeScreen> {
  late final PageController _pageController;
  StreamSubscription<InteractionEvent>? _interactionSub;

  int _currentPage = 0;
  bool _showDebugOverlay = true;
  bool _showInstructions = true;
  bool _showSettings = false;
  bool _showDirectionIndicator = false;
  bool _isRatingSubmitted = false;
  int _submittedRating = 0;
  ShakeDirection? _lastDirection;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Listen to interaction events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interactionSub = ref.read(interactionControllerProvider.notifier).onInteraction.listen(_handleInteraction);
    });
  }

  @override
  void dispose() {
    _interactionSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handleInteraction(InteractionEvent event) {
    HapticFeedback.mediumImpact();

    switch (event.type) {
      case InteractionEventType.navigateNext:
        _navigateToPage(event.contentIndex ?? 0);
        _showDirection(ShakeDirection.forward);
        break;
      case InteractionEventType.navigatePrevious:
        _navigateToPage(event.contentIndex ?? 0);
        _showDirection(ShakeDirection.backward);
        break;
      case InteractionEventType.showRating:
        _showDirection(ShakeDirection.right);
        break;
      case InteractionEventType.hideRating:
        _showDirection(ShakeDirection.left);
        break;
      case InteractionEventType.increaseRating:
        _showDirection(ShakeDirection.right);
        break;
      case InteractionEventType.decreaseRating:
        _showDirection(ShakeDirection.left);
        break;
      case InteractionEventType.submitRating:
        _handleRatingSubmit(event.currentRating ?? 0);
        break;
      case InteractionEventType.calibrationComplete:
        break;
    }
    setState(() {});
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
    ref.read(interactionControllerProvider.notifier).navigateToIndex(index);
  }

  void _handleRatingSubmit(int rating) {
    final contentAsync = ref.read(contentListProvider);
    contentAsync.whenData((items) {
      final interactionState = ref.read(interactionControllerProvider);
      final content = items[interactionState.currentContentIndex];
      
      ref.read(contentListProvider.notifier).submitRating(content.id, rating);
      HapticFeedback.heavyImpact();

      setState(() {
        _isRatingSubmitted = true;
        _submittedRating = rating;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isRatingSubmitted = false);
      });
    });
  }

  void _navigateToPage(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _showDirection(ShakeDirection direction) {
    setState(() {
      _lastDirection = direction;
      _showDirectionIndicator = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showDirectionIndicator = false);
    });
  }

  void _toggleSettings() => setState(() => _showSettings = !_showSettings);
  void _toggleDebug() => setState(() => _showDebugOverlay = !_showDebugOverlay);
  void _closeSettings() => setState(() => _showSettings = false);

  void _showInstructionsPanel() {
    setState(() {
      _showSettings = false;
      _showInstructions = true;
    });
  }

  void _recalibrate() {
    setState(() => _showSettings = false);
    ref.read(interactionControllerProvider.notifier).recalibrate();
  }

  @override
  Widget build(BuildContext context) {
    final interactionState = ref.watch(interactionControllerProvider);
    final contentAsync = ref.watch(contentListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          contentAsync.when(
            data: (items) => PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const ClampingScrollPhysics(),
              itemCount: items.length,
              onPageChanged: _handlePageChanged,
              itemBuilder: (context, index) {
                return ContentCard(
                  content: items[index],
                  isActive: index == _currentPage,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          _buildTopBar(contentAsync),
          _buildRatingOverlay(interactionState),
          _buildDirectionIndicator(),
          _buildDebugOverlay(),
          _buildRatingSubmittedOverlay(),
          _buildCalibrationOverlay(interactionState),
          _buildInstructionsOverlay(interactionState),
          _buildSettingsPanel(),
          _buildBottomHint(interactionState),
        ],
      ),
    );
  }

  Widget _buildTopBar(AsyncValue<List<Object>> contentAsync) {
    final padding = MediaQuery.of(context).padding;
    final count = contentAsync.when(data: (items) => items.length, loading: () => 0, error: (_, __) => 0);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            const Text(
              'Motion Feed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (count > 0) _buildPageCounter(count),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _toggleSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCounter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${_currentPage + 1}/$total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingOverlay(InteractionStateData state) {
    return RatingOverlay(
      rating: state.currentRating,
      isVisible: state.currentState == InteractionState.ratingActive,
      isSubmitting: _isRatingSubmitted,
      onRatingChanged: (r) => ref.read(interactionControllerProvider.notifier).setRating(r),
      onSubmit: () => ref.read(interactionControllerProvider.notifier).setRating(state.currentRating),
    );
  }

  Widget _buildDirectionIndicator() {
    return DirectionIndicator(
      direction: _lastDirection,
      isVisible: _showDirectionIndicator,
    );
  }

  Widget _buildDebugOverlay() {
    if (!_showDebugOverlay) return const SizedBox.shrink();
    return MotionDebugOverlay(
      debugStream: ref.watch(motionServiceProvider).debugStream,
      isVisible: _showDebugOverlay,
    );
  }

  Widget _buildRatingSubmittedOverlay() {
    if (!_isRatingSubmitted) return const SizedBox.shrink();
    return RatingSubmittedOverlay(
      rating: _submittedRating,
      isVisible: _isRatingSubmitted,
    );
  }

  Widget _buildCalibrationOverlay(InteractionStateData state) {
    return CalibrationOverlay(isCalibrating: !state.isCalibrated);
  }

  Widget _buildInstructionsOverlay(InteractionStateData state) {
    return InstructionsOverlay(
      isVisible: _showInstructions && state.isCalibrated,
      onDismiss: () => setState(() => _showInstructions = false),
    );
  }

  Widget _buildSettingsPanel() {
    if (!_showSettings) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _closeSettings,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: SettingsPanel(
            showDebug: _showDebugOverlay,
            showInstructions: _showInstructions,
            onToggleDebug: _toggleDebug,
            onShowInstructions: _showInstructionsPanel,
            onRecalibrate: _recalibrate,
            onClose: _closeSettings,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHint(InteractionStateData state) {
    if (!state.isCalibrated || _showInstructions) {
      return const SizedBox.shrink();
    }

    final isRating = state.currentState == InteractionState.ratingActive;
    final icon = isRating ? Icons.star_rounded : Icons.swipe_vertical_rounded;
    final text = isRating
        ? 'Rating mode • Forward to submit'
        : 'Tilt to navigate • Right for rating';

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ).animate().fadeIn(
          duration: 500.ms,
          delay: 1000.ms,
        ),
      ),
    );
  }
}
