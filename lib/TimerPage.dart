import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation_scheduler/HiveDb.dart';
import 'package:meditation_scheduler/Provider/meditation_provider.dart';
import 'package:meditation_scheduler/SettingsHive.dart';
import 'package:meditation_scheduler/feed.dart';
import 'package:meditation_scheduler/widgets/elevatedbutton.dart';
import 'package:meditation_scheduler/services/notification_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TimerPage extends ConsumerStatefulWidget {
  final Duration duration;
  final MeditationSlot slot; // morning or evening

  const TimerPage({super.key, required this.duration, required this.slot});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final AudioPlayer _player = AudioPlayer();
  // Separate player for guided meditation
  late Duration _remaining;
  late Duration _initialDuration;
  bool paused = false;
  Timer? _timer;
  late AnimationController _starController;

  // Track when the timer started for background persistence
  DateTime? _timerStartTime;
  DateTime? _lastPauseTime;
  Duration _totalPausedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initialDuration = widget.duration;

    _remaining = widget.duration;

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _startTimer();

    // Start guided meditation audio if selected

    // Schedule notification for timer completion
    _scheduleCompletionNotification();
  }

  Future<void> saveMeditation({
    required DateTime date,
    required bool isMorning,
    required int duration,
  }) async {
    // Use the HiveDb methods instead of direct box access
    if (isMorning) {
      await MeditationDayHiveDB.updateMorningAsComplete(duration);
    } else {
      await MeditationDayHiveDB.updateEveningAsComplete(duration);
    }
  }

  Future<void> _seekGuidedMeditationTo(Duration position) async {
    try {
      // If player is not in a state that allows seeking, restart and seek
    } catch (e) {}
  }

  void _startTimer() {
    _timer?.cancel();

    // If this is the first start, record the start time
    if (_timerStartTime == null) {
      _timerStartTime = DateTime.now();
    }

    // If resuming from pause, add to total paused time
    if (_lastPauseTime != null) {
      _totalPausedTime += DateTime.now().difference(_lastPauseTime!);
      _lastPauseTime = null;
    }

    setState(() => paused = false);

    // Resume guided meditation audio if it was paused

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (_timerStartTime == null) return;

    final now = DateTime.now();
    final elapsedTime = now.difference(_timerStartTime!) - _totalPausedTime;
    final newRemaining = _initialDuration - elapsedTime;

    if (newRemaining.inSeconds > 0) {
      setState(() => _remaining = newRemaining);
    } else {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      _onTimerComplete();
    }
  }

  // Schedule notification for timer completion
  void _scheduleCompletionNotification() {
    final slot = widget.slot == MeditationSlot.morning ? 'morning' : 'evening';

    // Only schedule if app is not in foreground
    if (!NotificationService().isAppInForeground) {
      NotificationService().scheduleTimerCompletionNotification(
        duration: _remaining,
        slot: slot,
      );
    } else {}
  }

  // Reschedule notification when app goes to background
  void _rescheduleNotificationIfNeeded() {
    if (!NotificationService().isAppInForeground && _remaining.inSeconds > 0) {
      _scheduleCompletionNotification();
    }
  }

  // Cancel scheduled notification
  void _cancelScheduledNotification() {
    // Cancel all notifications when timer is cancelled or reset
    NotificationService().cancelAllNotifications();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _lastPauseTime = DateTime.now();
    setState(() => paused = true);

    // Pause guided meditation audio if playing

    // Cancel and reschedule notification when paused
    _cancelScheduledNotification();
  }

  void _resetTimer() {
    _timer?.cancel();

    // Stop and restart guided meditation audio

    setState(() {
      paused = false;
      _remaining = _initialDuration;
    });

    // Reset timer tracking variables
    _timerStartTime = null;
    _lastPauseTime = null;
    _totalPausedTime = Duration.zero;

    // Cancel old notification and schedule new one
    _cancelScheduledNotification();
    _startTimer();

    _scheduleCompletionNotification();
  }

  void _cancelTimer() async {
    _timer?.cancel();
    _player.stop();

    // Stop guided meditation audio

    // Cancel scheduled notification
    _cancelScheduledNotification();

    setState(() => _remaining = Duration.zero);

    // Reset timer tracking variables
    _timerStartTime = null;
    _lastPauseTime = null;
    _totalPausedTime = Duration.zero;
    WakelockPlus.disable();
    _navigateToFeed();
  }

  Future<void> _onTimerComplete() async {
    // Cancel the scheduled notification since timer is complete
    _cancelScheduledNotification();

    await saveMeditation(
      date: DateTime.now(),
      isMorning: widget.slot == MeditationSlot.morning,
      duration: widget.duration.inMinutes,
    );

    // Mark the meditation slot completed
    if (mounted) {
      ref
          .read(meditationProvider.notifier)
          .completeSlot(widget.slot, widget.duration);
    }

    // Only play timer ending sound if no guided meditation is selected

    String audioname = SettingsHiveDB.getTimerSound();
    await _player.play(AssetSource(audioname), volume: 8);

    _player.onPlayerComplete.listen((event) {
      _navigateToFeed();
    });
  }

  void _navigateToFeed() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FeedPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inHours > 0 ? "${twoDigits(d.inHours)}:" : ""}$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _starController.dispose();
    _player.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - update timer and cancel notifications
        if (!paused && _timerStartTime != null) {
          _updateRemainingTime();
        }
        _cancelScheduledNotification();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - reschedule notification if timer is running
        if (!paused && _remaining.inSeconds > 0) {
          _rescheduleNotificationIfNeeded();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color textButtonColor = Theme.of(context).focusColor;

    return ValueListenableBuilder(
      valueListenable: Hive.box("settings").listenable(),

      builder: (context, value, child) {
        Color bg = Theme.of(context).scaffoldBackgroundColor;
        if (SettingsHiveDB.getTimerBG() != "default") {
          bg = Colors.black38;
        }
        return Scaffold(
          backgroundColor: bg,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 150),

                if (paused)
                  Text(
                    "Paused",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                // Show guided meditation info if selected
                const SizedBox(height: 100),

                // Timer display
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).focusColor,
                              blurRadius: 25,
                              spreadRadius: 80,
                            ),
                          ],
                        ),
                        child: Text(
                          _formatTime(_remaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),

                const SizedBox(height: 50),

                // Control buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton_widget(
                        textSize: 20,
                        bgcolor: Colors.transparent,
                        fgcolor: textButtonColor,
                        input: paused ? "Resume" : "Pause",
                        onTap: paused
                            ? () {
                                _startTimer();
                                _scheduleCompletionNotification();
                              }
                            : _pauseTimer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton_widget(
                        bgcolor: Colors.transparent,
                        fgcolor: textButtonColor,
                        input: "Reset",
                        onTap: _resetTimer,
                        textSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton_widget(
                        input: "Exit",
                        bgcolor: Colors.transparent,
                        onTap: _cancelTimer,
                        fgcolor: textButtonColor,
                        textSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
