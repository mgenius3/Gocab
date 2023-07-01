import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {this.child,
      this.color,
      this.bgcolor,
      this.onPressed,
      this.borderRadius,
      this.height: 50.0});

  final Widget? child;
  final Color? color;
  final Color? bgcolor;
  final double? borderRadius;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: ElevatedButton(
          child: child,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(bgcolor ?? Colors.black),
            foregroundColor:
                MaterialStateProperty.all<Color>(color ?? Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          onPressed: onPressed,
        ));
  }
}
