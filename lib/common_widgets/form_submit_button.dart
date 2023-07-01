import 'package:Gocab/common_widgets/button.dart';
import 'package:flutter/material.dart';

class FormSubmitButton extends CustomButton {
  FormSubmitButton({
    required String text,
    required VoidCallback onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
          height: 44.0,
          color: Color.fromARGB(255, 29, 30, 37),
          borderRadius: 1.0,
          onPressed: onPressed,
        );
}
