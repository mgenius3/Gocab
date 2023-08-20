import 'package:Gocab/app/main_screen/index.dart';
import 'package:Gocab/app/home_page.dart';
import 'package:flutter/material.dart';
import "package:Gocab/common_widgets/form_submit_button.dart";
import 'package:Gocab/app/auth/register/users/email_register_page.dart';
import 'package:Gocab/services/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Gocab/app/sub_screens/forgot_password.dart';
import 'package:Gocab/app/sub_screens/map_screen.dart';
import 'package:Gocab/Assistants/assistant_method.dart';
import 'package:firebase_core/firebase_core.dart';

class EmailSignInForm extends StatefulWidget {
  EmailSignInForm({required this.auth});
  final AuthBase auth;
  @override
  _EmailSignInFormState createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  bool _isPasswordVisible = false;
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  bool loading = false;

  void _submit() async {
    try {
      setState(() {
        loading = true;
      });
      await widget.auth.signInWithEmailAndPassword(
          _emailTextController.text.toString(),
          _passwordTextController.text.toString());

      setState(() {
        loading = false;
      });
      await Fluttertoast.showToast(msg: "Successfully Logged In");

      AssistantMethods.readCurrentOnlineUserInfo();

      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        // builder: (context) => BookingPage(),
        builder: (context) => MapScreen(),
        fullscreenDialog: true,
      ));
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (e is FirebaseException) {
        Fluttertoast.showToast(msg: "Unable to sign in: ${e.message}");
      } else {
        await Fluttertoast.showToast(msg: "Unable to sign in:  try again");
      }
    }
  }

  List<Widget> _buildChildren() {
    return [
      Container(child: Image.asset("images/logo.png")),
      SizedBox(height: 26),
      Text(
        "Sign In",
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 36),

      TextFormField(
        decoration: InputDecoration(
          labelText: 'Email address',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(), // Set the border to a rectangular shape
        ),
        onChanged: (text) => setState(() {
          _emailTextController.text = text;
        }),
      ),
      SizedBox(height: 16.0),
      TextFormField(
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          labelText: 'Password',
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          border: OutlineInputBorder(), // Set the border to a rectangular shape
        ),
        onChanged: (text) => setState(() {
          _passwordTextController.text = text;
        }),
      ),
      SizedBox(height: 16.0),
      ElevatedButton(
        style: ElevatedButton.styleFrom(padding: EdgeInsets.all(10)),
        onPressed: !loading ? _submit : null,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !loading
                  ? Text("Sign In", style: TextStyle(fontSize: 24))
                  : CircularProgressIndicator(
                      color: Colors.white,
                      backgroundColor: Color(0xFF0D47A1),
                    )
            ],
          ),
        ),
      ),
      SizedBox(height: 16.0),
      GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
          },
          child: Text('Forgot Password ?')),
      SizedBox(height: 16.0),
      // ElevatedButton.icon(
      //   onPressed: () {
      //     widget.auth.signInWithGoogle();
      //     // Perform registration with Google logic here
      //   },
      //   icon: Image.asset('images/google.png',
      //       height: 24.0), // Replace with your Google icon
      //   label: Text('Sign in with Google'),
      //   style: ElevatedButton.styleFrom(
      //     primary: Colors.red, // Customize the button background color
      //     onPrimary: Colors.white, // Customize the button text color
      //   ),
      // ),
      TextButton(
          child: Text('Need an account? Register'),
          onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => EmailRegisterPage(),
                  fullscreenDialog: true,
                ),
              )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }
}
