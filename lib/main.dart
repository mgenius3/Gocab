import 'package:flutter/material.dart';
import 'package:Gocab/app/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:Gocab/services/auth.dart';
import 'package:Gocab/splash.dart';

import 'infoHandler/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GoApp());
}

class GoApp extends StatelessWidget {
  const GoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MaterialColor customPrimarySwatch = MaterialColor(
      0xFF0D47A1,
      <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      },
    );

    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'GoCab Travels',
        theme: ThemeData(
          primarySwatch: customPrimarySwatch,
        ),
        debugShowCheckedModeBanner: false,
        home: Splash(),
      )
    );
  }
}
