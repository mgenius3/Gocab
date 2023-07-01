import 'package:flutter/material.dart';
import "package:Gocab/helper/alertbox.dart";

class BookTaxiButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BookTaxiButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.local_taxi),
              onPressed: () {
                // Code to handle booking a dispatch rider button click
              },
            ),
            Text("Book a Taxi")
          ],
        ),
      ),
    );
  }
}
