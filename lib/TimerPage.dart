import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meditation_scheduler/HiveDb.dart';
import 'package:meditation_scheduler/Provider/meditation_provider.dart';
import 'package:meditation_scheduler/SettingsHive.dart';
import 'package:meditation_scheduler/feed.dart';
import 'package:meditation_scheduler/widgets/elevatedbutton.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends ConsumerStatefulWidget {
  Duration duration;
  final MeditationSlot slot; // morning or evening

  TimerPage({super.key, required this.duration, required this.slot});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late Duration _remaining;
  late Duration _initialDuration;
  bool paused = false;
  Timer? _timer;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();

    _initialDuration = widget.duration;

    _remaining = widget.duration;

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startTimer();
  }

  Future<void> saveMeditation({
    required DateTime date,
    required bool isMorning,
    required int duration,
  }) async {
    var box = await Hive.openBox("meditation");

    // Normalize date (so morning/evening of same day map to same key)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final key = normalizedDate.toIso8601String();

    // Read existing data if any
    Map<dynamic, dynamic> entry = box.get(
      key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    );

    if (isMorning) {
      entry['morningCompleted'] = true;
      entry['morningDuration'] = widget.duration.inMinutes;
    } else {
      entry['eveningCompleted'] = true;
      entry['eveningDuration'] = widget.duration.inMinutes;
    }

    // Save updated entry back
    await box.put(key, entry);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => paused = false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() => _remaining -= const Duration(seconds: 1));
      } else {
        _timer?.cancel();
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => paused = true);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      paused = false;
      _remaining = _initialDuration;
    });
    _startTimer();
  }

  void _cancelTimer() async {
    _timer?.cancel();
    _player.stop();

    setState(() => _remaining = Duration.zero);
    _navigateToFeed();
  }

  Future<void> _onTimerComplete() async {
    print(widget.slot);
    await saveMeditation(
      date: DateTime.now(),
      isMorning: widget.slot == MeditationSlot.morning,
      duration: widget.duration.inMinutes,
    );
    String audioname = SettingsHiveDB.getTimerSound();
    await _player.play(AssetSource(audioname), volume: 8);

    // Mark the meditation slot completed
    if (mounted) {
      ref
          .read(meditationProvider.notifier)
          .completeSlot(widget.slot, widget.duration);
    }

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
    super.dispose();
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

                const SizedBox(height: 150),

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
                        onTap: paused ? _startTimer : _pauseTimer,
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
