import 'package:flutter/material.dart';
import 'package:Gocab/common_widgets/button.dart';
import 'package:Gocab/app/auth/widget/sign_in_button.dart';
import 'package:Gocab/app/auth/widget/social_sign_in_button.dart';
import 'package:Gocab/services/auth.dart';
import 'package:Gocab/app/auth/signIn/email_sign_in_page.dart';

class SignPage extends StatelessWidget {
  final Function(User) onSignIn;
  final AuthBase auth;
  const SignPage({Key? key, required this.onSignIn, required this.auth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _signInAnonymously() async {
      try {
        User user = await auth.signInAnonymously();
        onSignIn(user);
      } catch (error) {
        print(error.toString());
      }
    }

    Future<void> _signInWithGoogle() async {
      try {
        User user = await auth.signInWithGoogle();
        onSignIn(user);
      } catch (error) {
        print(error.toString());
      }
    }

    void _signInWithEmail(BuildContext context) {
      //TODO: Show Emails
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => EmailSignInPage(),
          // fullscreenDialog: true,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Go Cab'),
        elevation: 2.0,
      ),
      body: _buildContent(
        _signInAnonymously,
        _signInWithGoogle,
        _signInWithEmail,
        context,
      ),
    );
  }
}

Widget _buildContent(
  void Function() _signInAnonymously,
  void Function() _signInWithGoogle,
  void Function(BuildContext) _signInWithEmail,
  BuildContext context,
) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Sign in',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 48.0),
        SocialSignInButton(
          assetName: "images/google.png",
          text: "Sign in with Google",
          textColor: Colors.black,
          bgColor: Colors.white70,
          onPressed: _signInWithGoogle,
        ),
        SizedBox(height: 8.0),
        SignInButton(
          text: "Sign in with email",
          textColor: Colors.white,
          bgColor: Colors.teal[700],
          onPressed: () => _signInWithEmail(context),
        ),
        SizedBox(height: 8.0),
        Center(
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "or\n",
                  style: TextStyle(color: Colors.black.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8.0),
        SignInButton(
          text: "Go anonymous",
          textColor: Colors.black87,
          bgColor: Colors.lime[300],
          onPressed: _signInAnonymously,
        ),
      ],
    ),
  );
}
