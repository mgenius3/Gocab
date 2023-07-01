import 'package:flutter/material.dart';
import 'widget/become_dispatch_button.dart';
import 'widget/become_taxi_button.dart';
import 'package:Gocab/app/auth/register/drivers/taxi.dart';
import 'package:Gocab/app/auth/register/drivers/dispatch.dart';
import 'package:Gocab/services/auth.dart';

class SideDrawer extends StatelessWidget {
  final AuthBase auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: null, // Remove account email
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://img.icons8.com/color/48/circled-user-male-skin-type-4--v1.png'), // Replace with user's profile image
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(
                fit: BoxFit.fill,
                // image: AssetImage('assets/images/cover.jpg'),
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1579267217516-b73084bd79a6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
                ),
              ),
            ),
            otherAccountsPictures: [
              CircleAvatar(
                child: Text(
                  'GO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.blue,
              ),
            ],
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.border_color),
                  title: Text('Feedback'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    Auth().signOut();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_sharp),
                  title: Text('About Us'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0), // Add spacing between the buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: BecomeTaxiRiderButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaxiDriverRegistrationPage(),
                    fullscreenDialog: true),
              );
            }),
          ),

          SizedBox(height: 16.0), // Add spacing between the list and buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: BecomeDispatchRiderButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DispatchRiderRegistrationPage(),
                    fullscreenDialog: true),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Rest of the code remains the same
