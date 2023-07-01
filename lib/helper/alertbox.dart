import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';

// showAlertDialog(BuildContext context, title, text) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('$title'),
//         content: Text('$text'),
//         // actions: <Widget>[
//         //   FlatButton(
//         //     child: Text('OK'),
//         //     onPressed: () {
//         //       Navigator.of(context).pop(); // Close the alert dialog
//         //     },
//         //   ),
//         // ],
//       );
//     },
//   );
// }

class AlertBox {
  @override
  showAlertDialog(BuildContext context, title, text) {
    Alert(
      context: context,
      title: "$title",
      desc: "$text",
    ).show();
  }

  @override
  showToastMessage(status, msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
