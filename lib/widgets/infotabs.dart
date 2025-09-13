import 'package:flutter/material.dart';

class InfoTab extends StatelessWidget {
  String input;
  Color? insideColor;
  Color? outsideColor;
  Color? textColor;
  InfoTab({
    super.key,
    required this.input,
    this.insideColor,
    this.outsideColor,
    this.textColor,
  });
  double tabBorderRadius = 20;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height * 0.1,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(tabBorderRadius),

        color: outsideColor ?? Theme.of(context).hintColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(tabBorderRadius),

            color: insideColor ?? Theme.of(context).focusColor,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: SingleChildScrollView(
                child: Text(
                  maxLines: 5,
                  overflow: TextOverflow.visible,
                  input,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: textColor ?? Colors.white,
                    fontSize: width * 0.05,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
