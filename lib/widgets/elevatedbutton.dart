import 'package:flutter/material.dart';

class ElevatedButton_widget extends StatefulWidget {
  String input;
  final VoidCallback? onTap;
  final Color? bgcolor;
  final Color? fgcolor;
  double? textSize;
  ElevatedButton_widget({
    super.key,
    required this.input,
    this.onTap,
    this.bgcolor,
    this.fgcolor,
    this.textSize,
  });

  @override
  State<ElevatedButton_widget> createState() => _ElevatedButton_widgetState();
}

class _ElevatedButton_widgetState extends State<ElevatedButton_widget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: WidgetStatePropertyAll(0),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        backgroundColor: WidgetStateProperty.all(
          widget.bgcolor ?? const Color.fromARGB(255, 249, 223, 156),
        ),
      ),
      onPressed: widget.onTap,
      child: Text(
        widget.input,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontSize: widget.textSize,
          color: widget.fgcolor ?? const Color.fromARGB(255, 92, 7, 1),
        ),
      ),
    );
  }
}
