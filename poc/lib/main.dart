/*import 'package:flutter/material.dart';
import 'tests_widget.dart'; // Import the TestsWidget file

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Tests',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100], // Default background color
      ),
      home: const TestsWidget(), // Set TestsWidget as the home screen
    );
  }
}
*/

import 'globals.dart';
import 'package:flutter/material.dart';
import 'wifi_setup_screen.dart';
import 'auth3_login_widget.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WiFiSetupScreen(), // Initial screen of the app
    );
  }
}











