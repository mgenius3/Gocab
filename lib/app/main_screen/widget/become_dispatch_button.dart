import 'package:flutter/material.dart';

class BecomeDispatchRiderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BecomeDispatchRiderButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.directions_bike_rounded),
              onPressed: () {
                // Code to handle booking a dispatch rider button click
              },
            ),
            Text("Become a Dispatch Rider")
          ],
        ),
      ),
    );
  }
}
