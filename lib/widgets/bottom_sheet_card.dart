import 'package:flutter/material.dart';

class BottomSheetCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const BottomSheetCard({
    Key? key,
    required this.child,
    this.height = 300,
    this.width = double.infinity,
    this.backgroundColor = Colors.white,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BottomSheet(
        onClosing: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        builder: (context) {
          return Container(
            height: height,
            width: width,
            margin: margin ?? const EdgeInsets.all(16.0),
            child: Card(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
              elevation: 8.0,
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16.0),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Example usage widget
class ExampleBottomSheet extends StatelessWidget {
  const ExampleBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomSheetCard(
      height: 300,
      backgroundColor: Colors.grey[100]!,
      borderRadius: 25.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bottom Sheet Content',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'This is a bottom sheet card with rounded edges',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
