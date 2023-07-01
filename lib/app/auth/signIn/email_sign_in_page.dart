import 'package:flutter/material.dart';
import 'package:Gocab/app/auth/signIn/email_sign_in_form.dart';
import 'package:Gocab/services/auth.dart';

class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Sign in'),
            elevation: 2.0,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: EmailSignInForm(
                auth: Auth(),
              ),
            ),
          )),
    );
  }

  // Widget _buildContent() {
  //   return Container();
  // }
}
