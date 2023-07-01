import 'package:flutter/material.dart';
import 'package:Gocab/services/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({this.onSignOut, required this.auth});
  final VoidCallback? onSignOut;
  final AuthBase auth;

  Future<void> _signOut() async {
    try {
      await auth.signOut();
      onSignOut
          ?.call(); // Use the null-aware call operator to invoke the callback if it's not null
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: Text("Home page"),
      actions: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
                onPressed: _signOut,
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                )),
            Text('Logout', style: TextStyle(color: Colors.white))
          ],
        )
      ],
    ));
  }
}
