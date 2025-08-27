import 'package:flutter/material.dart';

class SimpleBottomSheetCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Color backgroundColor;
  final double borderRadius;

  const SimpleBottomSheetCard({
    Key? key,
    required this.child,
    this.height = 300,
    this.width = double.infinity,
    this.backgroundColor = Colors.white,
    this.borderRadius = 20.0,
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
          return SizedBox(
            height: height,
            width: width,
            child: Card(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius),
                  topRight: Radius.circular(borderRadius),
                ),
              ),
              elevation: 8.0,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// Usage example - this is how you would use it in your code:
/*
Align(
  alignment: Alignment.bottomCenter,
  child: BottomSheet(
    onClosing: () {},
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      return SizedBox(
        height: 300,
        width: double.infinity,
        child: Card(
          color: Colors.grey[100]!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Your content here'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ),
)
*/
