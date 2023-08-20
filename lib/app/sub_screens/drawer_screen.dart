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
            accountEmail: null, // Remove account email
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(userModelCurrentInfo?.image_url
                      ?.toString() ??
                  'https://img.icons8.com/color/48/circled-user-male-skin-type-4--v1.png'), // Replace with user's profile image
            ),
            decoration: BoxDecoration(
              color: Color(0xFF0D0B81),
              // image: DecorationImage(
              //   fit: BoxFit.fill,
              //   // image: AssetImage('assets/images/cover.jpg'),
              //   image: NetworkImage(
              //     'https://images.unsplash.com/photo-1579267217516-b73084bd79a6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
              //   ),
              // ),
            ),
            // otherAccountsPictures: [
            //   CircleAvatar(
            //     child: Text(
            //       'USER',
            //       style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 12,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     backgroundColor: Colors.blue,
            //   ),
            // ],
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
