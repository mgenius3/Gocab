import 'package:flutter/material.dart';
import 'package:Gocab/app/auth/register/drivers/taxi.dart';
import 'package:Gocab/app/auth/register/drivers/dispatch.dart';
import 'package:Gocab/services/auth.dart';
import 'package:Gocab/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Gocab/splash.dart';
import "./profile_screen.dart";
import "./about_screen.dart";
import './trips_history_screen.dart';
import './report.dart';
import './add_card_sceen.dart';

class DrawerScreen extends StatelessWidget {
  final AuthBase auth = Auth();
  final getFirebase = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: userModelCurrentInfo != null
                ? Text(
                    userModelCurrentInfo?.name ?? "",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(""),
            accountEmail:
                Text("${userModelCurrentInfo?.email}"), // Remove account email
            // currentAccountPicture: CircleAvatar(
            //   backgroundImage: NetworkImage(userModelCurrentInfo?.image_url
            //           ?.toString() ??
            //       '${userModelCurrentInfo?.name.toString()[0]}'), // Replace with user's profile image
            // ),
            currentAccountPicture: CircleAvatar(
              child: Text("${userModelCurrentInfo?.name.toString()[0]}",
                  style: TextStyle(fontSize: 30)),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0D0B81),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Edit Profile'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => ProfileScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text('Payment'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => AddCardScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flight),
                  title: Text('My Trips'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => TripsHistoryScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Message Us'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => ReportPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_sharp),
                  title: Text('About Us'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => AboutPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    getFirebase.signOut();
                    Auth().signOut();
                    userModelCurrentInfo = null;
                    Navigator.push(
                        context, MaterialPageRoute(builder: (c) => Splash()));
                  },
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
