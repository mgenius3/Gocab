import 'package:flutter/material.dart';

class BecomeTaxiRiderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BecomeTaxiRiderButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.local_taxi_rounded),
              onPressed: () {
                // Code to handle booking a dispatch rider button click
              },
            ),
            Text("Become a Taxi Driver")
          ],
        ),
      ),
    );
  }
}
