import 'package:flutter/material.dart';
import 'package:Gocab/app/auth/register/users/email_register_form.dart';
import 'package:Gocab/services/auth.dart';

class EmailRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Register'),
            elevation: 2.0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EmailRegisterForm(
              auth: Auth(),
            ),
          ),
          backgroundColor: Colors.grey[200],
        ));
  }
}
