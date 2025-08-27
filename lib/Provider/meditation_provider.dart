// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// /// Enum for meditation slots
enum MeditationSlot { morning, evening }

/// Enum for meditation slots

/// State model
class MeditationState {
  final bool morningCompleted;
  final bool eveningCompleted;
  final Duration lastSessionDuration; // duration of the last completed session
  final int completedDays;

  MeditationState({
    this.morningCompleted = false,
    this.eveningCompleted = false,
    this.lastSessionDuration = Duration.zero,
    this.completedDays = 0,
  });

  MeditationState copyWith({
    bool? morningCompleted,
    bool? eveningCompleted,
    Duration? lastSessionDuration,
    int? completedDays,
  }) {
    return MeditationState(
      morningCompleted: morningCompleted ?? this.morningCompleted,
      eveningCompleted: eveningCompleted ?? this.eveningCompleted,
      lastSessionDuration: lastSessionDuration ?? this.lastSessionDuration,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  /// Convert to Map for Hive
  Map<String, dynamic> toMap() => {
    'morningCompleted': morningCompleted,
    'eveningCompleted': eveningCompleted,
    'lastSessionDuration': lastSessionDuration.inSeconds,
    'completedDays': completedDays,
  };

  /// Load from Map
  factory MeditationState.fromMap(Map<dynamic, dynamic> map) {
    return MeditationState(
      morningCompleted: map['morningCompleted'] ?? false,
      eveningCompleted: map['eveningCompleted'] ?? false,
      lastSessionDuration: Duration(seconds: map['lastSessionDuration'] ?? 0),
      completedDays: map['completedDays'] ?? 0,
    );
  }
}

/// StateNotifier (logic + Hive sync)
class MeditationNotifier extends StateNotifier<MeditationState> {
  final Box _box;
  final String _key;

  MeditationNotifier(this._box, this._key) : super(MeditationState()) {
    _loadFromHive();

    // Listen for external Hive changes
    _box.watch(key: _key).listen((event) {
      if (event.value != null) {
        state = MeditationState.fromMap(Map<String, dynamic>.from(event.value));
      }
    });
  }

  void _loadFromHive() {
    final raw = _box.get(_key);
    if (raw != null) {
      state = MeditationState.fromMap(Map<String, dynamic>.from(raw));
    }
  }

  Future<void> _saveToHive() async {
    await _box.put(_key, state.toMap());
  }

  /// Mark a slot as completed and store its duration
  void completeSlot(MeditationSlot slot, Duration duration) {
    if (slot == MeditationSlot.morning) {
      state = state.copyWith(
        morningCompleted: true,
        lastSessionDuration: duration,
      );
    } else {
      state = state.copyWith(
        eveningCompleted: true,
        lastSessionDuration: duration,
      );
    }

    _checkDayCompletion();
    _saveToHive();
  }

  void resetDay() {
    state = state.copyWith(
      morningCompleted: false,
      eveningCompleted: false,
      lastSessionDuration: Duration.zero,
    );
    _saveToHive();
  }

  void _checkDayCompletion() {
    if (state.morningCompleted && state.eveningCompleted) {
      state = state.copyWith(completedDays: state.completedDays + 1);
    }
  }
}

/// Provider
final meditationProvider =
    StateNotifierProvider<MeditationNotifier, MeditationState>((ref) {
      final box = Hive.box("meditation");
      // Example: use today's date as key
      final todayKey = DateTime.now().toIso8601String().substring(0, 10);
      return MeditationNotifier(box, todayKey);
    });
