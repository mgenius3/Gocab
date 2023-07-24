import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About GoCab'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gocab Logistics',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'GoCab is a leading logistics company that specializes in providing reliable transportation services for both individuals and businesses. We are committed to delivering exceptional customer service and ensuring the safe and timely delivery of goods.',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.0),
            Text(
              'Our Services',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '- Delivery and Distribution\n'
              '- Warehousing and Inventory Management\n'
              '- Last-Mile Delivery Solutions\n'
              '- Freight Forwarding\n'
              '- Supply Chain Consulting',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                height: 2,
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                launch('mailto:contact@gocab.com');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
