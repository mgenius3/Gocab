import 'package:flutter/material.dart';
import 'package:Gocab/common_widgets/button.dart';

class SocialSignInButton extends CustomButton {
  SocialSignInButton({
    String? assetName,
    @required String? text,
    Color? textColor,
    Color? bgColor,
    VoidCallback? onPressed,
  })  : assert(assetName != null),
        super(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(assetName ?? ""),
                  Text(
                    text ?? '',
                    style: TextStyle(color: textColor, fontSize: 15.0),
                  ),
                  Opacity(opacity: 0.0, child: Image.asset(assetName ?? ""))
                ]),
            color: textColor,
            bgcolor: bgColor,
            onPressed: onPressed);
}
