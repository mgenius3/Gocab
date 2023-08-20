import 'package:Gocab/app/main_screen/index.dart';
import 'package:flutter/material.dart';
import "package:Gocab/common_widgets/form_submit_button.dart";
import 'package:Gocab/app/auth/signIn/email_sign_in_page.dart';
import 'package:Gocab/services/auth.dart';
import 'package:Gocab/app/home_page.dart';
import 'package:Gocab/helper/alertbox.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:Gocab/app/sub_screens/map_screen.dart';
import 'package:Gocab/Assistants/assistant_method.dart';

class EmailRegisterForm extends StatefulWidget {
  EmailRegisterForm({required this.auth});

  final AuthBase auth;
  final AlertBox alertBox = AlertBox();

  @override
  _EmailRegisterFormState createState() => _EmailRegisterFormState();
}

class _EmailRegisterFormState extends State<EmailRegisterForm> {
  bool _isPasswordVisible = false;

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _confirmTextEditingController = TextEditingController();
  final nameTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();

  //declare a Global key
  final _formkey = GlobalKey<FormState>();

  bool loading = false;

  void _submit() async {
    try {
      if (_formkey.currentState!.validate()) {
        setState(() {
          loading = true;
        });
        Map<String, dynamic> userMap = {
          "name": nameTextEditingController.text.trim(),
          "email": _emailTextController.text.trim(),
          "address": addressTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
          "password": _passwordTextController.text.trim(),
        };
        await widget.auth.createUserWithEmailAndPassword(userMap);

        AssistantMethods.readCurrentOnlineUserInfo();

        await Fluttertoast.showToast(msg: "Successfully Registered");
        Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreen()));
      } else {
        await Fluttertoast.showToast(msg: "Enter valid details");
        loading = false;
      }
      // Navigator.of(context).pop();
    } catch (e) {
      String errorMessage = e.toString();
// Find the position of the opening bracket
      int startIndex = errorMessage.indexOf("[");
// Find the position of the closing bracket
      int endIndex = errorMessage.indexOf("]");

// Extract the error code substring
      String errorCode = errorMessage.substring(startIndex + 1, endIndex);

// Find the position of the first space after the closing bracket
      int spaceIndex = errorMessage.indexOf(" ", endIndex);

// Extract the error message substring
      String extractedErrorMessage = errorMessage.substring(spaceIndex + 1);

      await Fluttertoast.showToast(
          msg: "Failed Registration: $extractedErrorMessage");
      setState(() {
        loading = false;
      });
    }
  }

  List<Widget> _buildChildren() {
    return [
      Form(
        key: _formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(child: Image.asset("images/logo.png")),
            SizedBox(height: 26),
            Text(
              "Register",
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 26),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Name',
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
                prefixIcon: Icon(Icons.person),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Name can\'t be empty';
                }
                if (text.length < 2) {
                  return "Please enter a valid name";
                }
                if (text.length > 49) {
                  return 'Name can\t be more than 50';
                }
              },
              onChanged: (text) => setState(() {
                nameTextEditingController.text = text;
              }),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
                prefixIcon: Icon(Icons.email_outlined),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Email can\'t be empty';
                }
                if (EmailValidator.validate(text) == true) {
                  return null;
                }
                if (text.length < 2) {
                  return "Please enter a valid email";
                }
                if (text.length > 99) {
                  return 'Email can\t be more than 50';
                }
              },
              onChanged: (text) => setState(() {
                _emailTextController.text = text;
              }),
            ),
            SizedBox(height: 16.0),
            IntlPhoneField(
              showCountryFlag: true,
              initialCountryCode: "NG",
              dropdownIcon: Icon(
                Icons.arrow_drop_down,
              ),
              decoration: InputDecoration(
                labelText: 'Phone',
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onChanged: (text) => setState(() {
                phoneTextEditingController.text = text.completeNumber;
              }),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Address',
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
                prefixIcon: Icon(Icons.location_city),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Address can\'t be empty';
                }
                if (text.length < 2) {
                  return "Please enter a valid address";
                }
                if (text.length > 200) {
                  return 'Address can\t be more than 200 characters';
                }
              },
              onChanged: (text) => setState(() {
                addressTextEditingController.text = text;
              }),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Password can\'t be empty';
                }
                if (text.length < 6) {
                  return "Password can not be less than 6";
                }
                if (text.length > 25) {
                  return 'Password can\'t be more than 25';
                }
              },
              onChanged: (text) =>
                  setState(() => {_passwordTextController.text = text}),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border:
                    OutlineInputBorder(), // Set the border to a rectangular shape
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Confirm Password can\'t be empty';
                }
                if (text != _passwordTextController.text) {
                  return "Confirm Password do not match";
                }
                if (text.length < 6) {
                  return "Please enter a valid confirm password";
                }
                if (text.length > 25) {
                  return 'Confirm Password can\'t be more than 25';
                }
              },
              onChanged: (text) =>
                  setState(() => {_confirmTextEditingController.text = text}),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: !loading ? _submit : null,
              child: Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: !loading ? _submit : null,
                      child: !loading
                          ? Text(
                              "Create Account",
                              style: TextStyle(color: Colors.white),
                            )
                          : CircularProgressIndicator(
                              color: Colors.white,
                              backgroundColor: Color(0xFF0D47A1),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     widget.auth.signInWithGoogle();
            //     // Perform registration with Google logic here
            //   },
            //   icon: Image.asset('images/google.png',
            //       height: 24.0), // Replace with your Google icon
            //   label: Text('Create Account with Google'),
            //   style: ElevatedButton.styleFrom(
            //     primary: Colors.red, // Customize the button background color
            //     onPrimary: Colors.white, // Customize the button text color
            //   ),
            // ),
            // SizedBox(height: 8.0),
            TextButton(
              child: Text('Have an account? Sign in'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => EmailSignInPage(),
                  fullscreenDialog: true,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        ),
      ),
    );
  }
}
