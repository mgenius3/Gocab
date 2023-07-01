import 'package:flutter/material.dart';

class BookDispatchRiderButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BookDispatchRiderButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.directions_bike),
              onPressed: () {
                // Code to handle booking a dispatch rider button click
              },
            ),
            Text("Book a Dispatch")
          ],
        ),
      ),
    );
  }
}
