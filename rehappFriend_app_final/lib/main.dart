import 'globals.dart';
import 'package:flutter/material.dart';
import 'wifi_setup_screen.dart';
import 'auth3_login_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patients_progress_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'overdue_patient.dart';


// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initializes Firebase

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize WorkManager for background tasks
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,  // Set to false for production
  );

  Workmanager().registerPeriodicTask(
    "10",
    "checkPatientTests",
    frequency: const Duration(minutes: 15),
    initialDelay: Duration(seconds: 10),
    constraints: Constraints(
      networkType: NetworkType.connected,  // Run only when connected to the network
      requiresBatteryNotLow: false,  // Prevent running when battery is low
      requiresCharging: false,  // Prevent running while charging
      requiresDeviceIdle: false,  // Don't wait until device is idle
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Function to check Wi-Fi connection status
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      return true;
    }
    return false;
  }

  // Asynchronous function to check user authentication with Wi-Fi check
  Future<bool> tryToConnectToAccount() async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      return Future.error('No Wi-Fi connection');
    }

    final User? user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user != null) {
      UID = user.uid; // As suming UID is a  global variable in globals.dart
      print("UID" + UID);
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            // Show alert dialog if no internet connection
            return Scaffold(
              body: Center(
                child: AlertDialog(
                  title: const Text('No Internet Connection'),
                  content: const Text('Please connect to Wi-Fi and try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Restart the connection check when clicked
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MyApp()),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            print(ESPIP) ;
            print (DoctorName);
            print (DoctorID);
            print (age);
            print (phoneNumber );
            print (Patientgender);
            print (symptoms);
            print (PatientId);
            print (TestGameName);
            print (UID);
            print (PatientName );
            // User is logged in, navigate to the main screen
            checkPatientTestDates();
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

// Background task handler
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background task triggered: $task");
      await checkPatientTestDates();
      return Future.value(true);
  });
}

// Function to check for overdue tests and send notification
Future<void> checkPatientTestDates() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == "overdue_tests") {
          runApp(MaterialApp(home: OverduePatientsPage()));
        }
      });

  // Query Firestore for patient test records
  QuerySnapshot snapshot =
  await FirebaseFirestore.instance.collection('patients').get();

  DateTime now = DateTime.now();
  List<String> overduePatients = [];

  for (var doc in snapshot.docs) {
    String patientId = doc.id;  // Get patient document ID
    String fullName = doc['full_name'];

    // Get the 'tests' subcollection for the current patient
    QuerySnapshot testsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('results')
       // .orderBy('last_test_date', descending: true) // Get the latest test first
       // .limit(1)
        .get();

    for (var doc in testsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var lastTest =data['tests_numbers'];
      if(lastTest!=0){
        Timestamp? lastTestDate = data['timestamp'+(lastTest).toString()];
        if (lastTestDate != null) {
          DateTime lastTest = lastTestDate.toDate();

          if (now.difference(lastTest).inDays > 7) {
            overduePatients.add(fullName+doc.id);
          }
        }
      }
      else{
        overduePatients.add(fullName+doc.id);
      }
    }

  }

  if (overduePatients.isNotEmpty) {
    String notificationBody =
       // "Patients with overdue tests: ${overduePatients.join(", ")}";
    "There are Patients with overdue tests";

    // Send a notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'overdue_tests_channel',
      'Overdue Test Reminders',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    try {
    await flutterLocalNotificationsPlugin.show(
      0,
      'Patient Test Reminder',
      notificationBody,
      platformChannelSpecifics,
      payload: "overdue_tests",
    );
    print("Notification should be shown now");
    } catch (e) {
      print("Error showing notification: $e");
    }
  } else {
    print("No overdue patients found");
  }
}


