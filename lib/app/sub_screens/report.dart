import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReportPage(),
    );
  }
}

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  bool isloading = false;

  final userid = FirebaseAuth.instance.currentUser!.uid;

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('reports');

  _submit() {
    // Perform the action when the user submits the report.
    final email = emailController.text;
    final subject = subjectController.text;
    final message = messageController.text;

    // Create a map with the report data.
    final reportData = {
      'email': email,
      'subject': subject,
      'message': message,
    };

    setState(() {
      isloading = true;
    });
    // Push the data to Firebase Realtime Database.
    _database.child(userid).set(reportData);

    // Reset the text fields after submission.
    emailController.clear();
    subjectController.clear();
    messageController.clear();

    setState(() {
      isloading = false;
    });
    // Show a confirmation dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Submitted'),
          content: Text(
              'Thank you for reporting the message!, we will get back to you shortly'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Messages'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: !isloading ? _submit : null,
              child: !isloading
                  ? Text('Submit Report')
                  : CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
