import 'package:Gocab/Assistants/assistant_method.dart';
import 'package:flutter/material.dart';
import 'package:Gocab/app/landing_page.dart';
import 'package:Gocab/services/auth.dart';
import 'package:Gocab/services/auth.dart';
import 'dart:async';
import "package:firebase_auth/firebase_auth.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Gocab/app/main_screen/index.dart';
import 'package:Gocab/app/auth/signIn/email_sign_in_page.dart';
import 'package:Gocab/app/sub_screens/map_screen.dart';
import 'package:Gocab/app/sub_screens/search_places_screen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final auth = Auth();

  startTimer() {
    Timer(Duration(seconds: 3), () async {
      if (await FirebaseAuth.instance.currentUser != null) {
        print(FirebaseAuth.instance.currentUser);
        FirebaseAuth.instance.currentUser != null
            ? AssistantMethods.readCurrentOnlineUserInfo()
            : null;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MapScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => EmailSignInPage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // _navigatetohome();
    startTimer();
  }

  // _navigatetohome() async {
  //   await Future.delayed(Duration(milliseconds: 1500), () {});
  //   Navigator.pushReplacement(context,
  //       MaterialPageRoute(builder: (context) => LandingPage(auth: Auth())));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/Gb.png', // Replace with the path to your image
              fit: BoxFit.cover, // Adjust the image fit as needed
            ),
          ],
        ),
      ),
    );
  }
}
