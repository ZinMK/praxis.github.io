import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meditation_scheduler/feed.dart';
import 'package:meditation_scheduler/widgets/elevatedbutton.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends StatefulWidget {
  final Duration duration; // immutable, passed from TimerBar
  const TimerPage({super.key, required this.duration});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool paused = false;
  late AnimationController _starController;
  Timer? _timer;

  late Duration _remaining;
  late Duration _initialDuration;

  @override
  void initState() {
    super.initState();

    // ✅ initialize durations with the passed value
    _initialDuration = widget.duration;
    _remaining = widget.duration;

    // Animation for stars
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          paused = false;
          _remaining -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        _notifyCompletion();
      }
    });
  }

  Future<void> _notifyCompletion() async {
    // 🔊 Play sound
    await _player.play(AssetSource("pluck.mp3"), volume: 8);
    _player.onPlayerComplete.listen((event) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => FeedPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  void _pauseTimer() {
    setState(() {
      paused = true;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      paused = false;
      _remaining = _initialDuration;
    });
    _startTimer();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _player.stop();
    setState(() {
      _remaining = Duration.zero;
    });
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FeedPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _starController.dispose();
    _player.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "${d.inHours > 0 ? "${twoDigits(d.inHours)}:" : ""}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final Color textButtonColor = Theme.of(context).focusColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 150),
            if (paused)
              Text("Paused", style: Theme.of(context).textTheme.labelMedium),

            const SizedBox(height: 100),

            // Timer text
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
  }
}

// 🎨 Custom painter for stars
class StarPainter extends CustomPainter {
  final double animationValue;
  final Random random;

  StarPainter({required this.animationValue, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(animationValue);

    for (int i = 0; i < 80; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
