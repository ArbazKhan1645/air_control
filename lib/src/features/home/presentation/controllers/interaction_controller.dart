import 'dart:async';
import 'package:air_control/src/features/home/domain/models/motion_models.dart';
import 'package:air_control/src/services/motion_service.dart';
import 'package:flutter_riverpod/legacy.dart';

enum InteractionEventType {
  navigateNext,
  navigatePrevious,
  showRating,
  hideRating,
  increaseRating,
  decreaseRating,
  submitRating,
  calibrationComplete,
}

class InteractionEvent {
  final InteractionEventType type;
  final int? currentRating;
  final int? contentIndex;
  final DateTime timestamp;

  InteractionEvent({
    required this.type,
    this.currentRating,
    this.contentIndex,
    required this.timestamp,
  });
}

class InteractionStateData {
  final InteractionState currentState;
  final int currentRating;
  final int currentContentIndex;
  final bool isCalibrated;

  InteractionStateData({
    this.currentState = InteractionState.browsing,
    this.currentRating = 0,
    this.currentContentIndex = 0,
    this.isCalibrated = false,
  });

  InteractionStateData copyWith({
    InteractionState? currentState,
    int? currentRating,
    int? currentContentIndex,
    bool? isCalibrated,
  }) {
    return InteractionStateData(
      currentState: currentState ?? this.currentState,
      currentRating: currentRating ?? this.currentRating,
      currentContentIndex: currentContentIndex ?? this.currentContentIndex,
      isCalibrated: isCalibrated ?? this.isCalibrated,
    );
  }
}

final interactionControllerProvider =
    StateNotifierProvider<InteractionController, InteractionStateData>((ref) {
      final motionService = ref.watch(motionServiceProvider);
      return InteractionController(motionService);
    });

class InteractionController extends StateNotifier<InteractionStateData> {
  final MotionService _motionService;
  StreamSubscription<ShakeEvent>? _shakeSubscription;
  StreamSubscription<Map<String, dynamic>>? _debugSubscription;

  final _eventController = StreamController<InteractionEvent>.broadcast();
  Stream<InteractionEvent> get onInteraction => _eventController.stream;

  InteractionController(this._motionService) : super(InteractionStateData()) {
    _init();
  }

  void _init() {
    _motionService.start();
    _shakeSubscription = _motionService.onShake.listen(_handleShakeEvent);
    _debugSubscription = _motionService.debugStream.listen((data) {
      if (!state.isCalibrated) {
        final magnitude = data['magnitude'];
        if (magnitude != null) {
          state = state.copyWith(isCalibrated: true);
          _emitEvent(InteractionEventType.calibrationComplete);
        }
      }
    });
  }

  void setTotalContentCount(int count) {
    // We don't necessarily need to store total count here if we handle it in UI
    // but we can if needed.
  }

  void _handleShakeEvent(ShakeEvent event) {
    switch (state.currentState) {
      case InteractionState.browsing:
        _handleBrowsingState(event);
        break;
      case InteractionState.ratingActive:
        _handleRatingState(event);
        break;
      case InteractionState.ratingConfirm:
        break;
    }
  }

  void _handleBrowsingState(ShakeEvent event) {
    switch (event.direction) {
      case ShakeDirection.forward:
        state = state.copyWith(
          currentContentIndex: state.currentContentIndex + 1,
        );
        _emitEvent(InteractionEventType.navigateNext);
        break;
      case ShakeDirection.backward:
        if (state.currentContentIndex > 0) {
          state = state.copyWith(
            currentContentIndex: state.currentContentIndex - 1,
          );
          _emitEvent(InteractionEventType.navigatePrevious);
        }
        break;
      case ShakeDirection.right:
        state = state.copyWith(
          currentState: InteractionState.ratingActive,
          currentRating: 1,
        );
        _emitEvent(InteractionEventType.showRating);
        break;
      default:
        break;
    }
  }

  void _handleRatingState(ShakeEvent event) {
    switch (event.direction) {
      case ShakeDirection.right:
        if (state.currentRating < 5) {
          state = state.copyWith(currentRating: state.currentRating + 1);
          _emitEvent(InteractionEventType.increaseRating);
        }
        break;
      case ShakeDirection.left:
        if (state.currentRating > 1) {
          state = state.copyWith(currentRating: state.currentRating - 1);
          _emitEvent(InteractionEventType.decreaseRating);
        } else {
          state = state.copyWith(
            currentState: InteractionState.browsing,
            currentRating: 0,
          );
          _emitEvent(InteractionEventType.hideRating);
        }
        break;
      case ShakeDirection.forward:
        state = state.copyWith(currentState: InteractionState.ratingConfirm);
        _emitEvent(InteractionEventType.submitRating);
        Future.delayed(const Duration(milliseconds: 500), () {
          state = state.copyWith(
            currentState: InteractionState.browsing,
            currentRating: 0,
          );
        });
        break;
      case ShakeDirection.backward:
        state = state.copyWith(
          currentState: InteractionState.browsing,
          currentRating: 0,
        );
        _emitEvent(InteractionEventType.hideRating);
        break;
      default:
        break;
    }
  }

  void _emitEvent(InteractionEventType type) {
    _eventController.add(
      InteractionEvent(
        type: type,
        currentRating: state.currentRating,
        contentIndex: state.currentContentIndex,
        timestamp: DateTime.now(),
      ),
    );
  }

  void navigateToIndex(int index) {
    state = state.copyWith(currentContentIndex: index);
  }

  void setRating(int rating) {
    if (rating == 0) {
      state = state.copyWith(
        currentState: InteractionState.browsing,
        currentRating: 0,
      );
      _emitEvent(InteractionEventType.hideRating);
    } else {
      state = state.copyWith(
        currentState: InteractionState.ratingActive,
        currentRating: rating,
      );
      _emitEvent(InteractionEventType.showRating);
    }
  }

  void recalibrate() {
    state = state.copyWith(isCalibrated: false);
    _motionService.recalibrate();
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _debugSubscription?.cancel();
    _eventController.close();
    super.dispose();
  }
}
