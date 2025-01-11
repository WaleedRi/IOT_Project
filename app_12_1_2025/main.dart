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
import 'package:firebase_auth/firebase_auth.dart';
import 'patients_progress_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Asynchronous function to check user authentication
  Future<bool> tryToConnectToAccount() async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user != null) {
      UID = user.uid; // Assuming UID is a global variable in globals.dart
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: tryToConnectToAccount(), // Async function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while waiting for the result
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            // User is logged in, navigate to the main screen
            return const PatientsProgressWidget();
          } else {
            // User is not logged in, navigate to the login screen
            return const Auth3LoginWidget();
          }
        },
      ),
    );
  }
}







