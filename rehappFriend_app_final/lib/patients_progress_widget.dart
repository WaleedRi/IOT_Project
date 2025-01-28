import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:start_esp_from_app/auth3_login_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wifi_setup_screen.dart';
import 'edit_patient_widget.dart';
import 'patient_goals.dart';
import 'graph_summery.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'my_patients_data_widget.dart';
import 'tests_widget.dart';
import 'globals.dart';
import 'add_patient_widget.dart';
import 'overdue_patient.dart';

class PatientsProgressWidget extends StatefulWidget {
  const PatientsProgressWidget({Key? key}) : super(key: key);

  @override
  State<PatientsProgressWidget> createState() => _PatientsProgressWidgetState();
}

class _PatientsProgressWidgetState extends State<PatientsProgressWidget> {
  double sliderValue1 = 75;
  double sliderValue2 = 45;
  double sliderValue3 = 60;
  List<String> PateintsName = [];
  List<String> filteredPatients = [];
  List<String> PateintsNameAndId = [];
  List<String> PateintsID = [];
  //List<String> overduePatients = [];
  Map<String, String> overduePatients = {};

  void updatePateintStatus(String pateintName, String Status) {
    setState(() {
      overduePatients[pateintName] = Status;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> logout() async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    await FirebaseAuth.instance.signOut();
    navigateLoginWidget();
    print('User logged out');
  }

  void navigateToTestsWidget() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsWidget(),
      ),
    );
  }
  void navigateToOverduePatientsPage() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OverduePatientsPage(),
      ),
    );
  }

  void navigateToTestsAverageHistoryWidgetWidget() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsAverageHistoryWidget(),
      ),
    );
  }

  void navigateToGoalsWidget() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientGoalsWidget(),
      ),
    );
  }
  void navigateLoginWidget() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Auth3LoginWidget(),
      ),
    );
  }
  void navigateToWifiSetUpWidget() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WiFiSetupScreen(),
      ),
    );
  }

  void navigateAddPatientsWidget() async{
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientWidget(),
      ),
    );
  }
  Future<void> navigateToEditPatient(String id) async {
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    await fetchPatientdetalis(id); // Wait for details to be fetched
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientWidget(
          patientId: id,
          patientName: PatientName,
          age: age, // Use the fetched age
          phoneNumber: phoneNumber, // Use the fetched phone number
          gender: Patientgender, // Use the fetched gender
          symptoms: symptoms, // Use the fetched symptoms
        ),
      ),
    );
  }

  Future<void> fetchPatientdetalis(String id) async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(id)//
          .get();

      if (snapshot.exists) {
        age =snapshot.get('age');
        phoneNumber =snapshot.get('phone_number');
        Patientgender =snapshot.get('Gender');
        symptoms =snapshot.get('symptoms');
        PatientName = snapshot.get('full_name');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }
  Future<void> fetchPatients() async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(UID)
          .get();

      if (snapshot.exists) {
        DoctorName =snapshot.get('Name');
        DoctorID =snapshot.get('ID');
        print("DoctorID= " + DoctorID);
        print("DoctorName= " + DoctorName);

        setState(() {


          PateintsNameAndId = List<String>.from(snapshot.get('patients') ?? []);
          PateintsName = [];
          PateintsID = [];
          for (int i = 0; i < PateintsNameAndId.length; i++) {
            List<String> parts = PateintsNameAndId[i].split('+');
            PateintsName.add(parts[0].trim());
            PateintsID.add(parts[1].trim());

          }
          filteredPatients = PateintsNameAndId;
        });
        DateTime now = DateTime.now();
        for (int i = 0; i < PateintsNameAndId.length; i++) {
          String  fullName = PateintsName[i];  // Get patient document ID
          String  patientId  = PateintsID[i];
          updatePateintStatus(patientId, '');

          // Get the 'tests' subcollection for the current patient

          QuerySnapshot testsSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .collection('results')
          // .orderBy('last_test_date', descending: true) // Get the latest test first
          // .limit(1)
              .get();

          bool isOutdated= false;
          for (var doc in testsSnapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            var lastTest =data['tests_numbers'];
            if(lastTest!=0){
              Timestamp? lastTestDate = data['timestamp'+(lastTest).toString()];
              if (lastTestDate != null) {
                DateTime lastTest = lastTestDate.toDate();

                if (now.difference(lastTest).inDays > 7) {
                  updatePateintStatus(patientId, 'Tests Outdated');
                  print(overduePatients[patientId].toString() + 'Tests Outdated'+ patientId);
                 // overduePatients.add();
                  isOutdated= true;
                  break;
                }
              }
            }
            else{
              updatePateintStatus(patientId, 'Tests Not Taken');
              print(overduePatients[patientId].toString() + 'Tests Not Taken'+ patientId);
              isOutdated= true;
              break;
            }
          }
          if(isOutdated== false){
            print(overduePatients[patientId].toString() + 'Tests Completed'+ patientId);
            updatePateintStatus(patientId, 'Tests Completed');
          }


        }
      }
      // Query Firestore for patient test records



    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  void filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPatients = PateintsNameAndId;
      } else {
        filteredPatients = PateintsNameAndId.where((patient) {
          List<String> parts = patient.split('+');
          String name = parts[0].trim().toLowerCase();
          String id = parts[1].trim().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              id.contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
          onRefresh: _refreshPage, // Trigger refresh when pulled
          child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Required for pull-to-refresh
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildHeader(context),
          _buildBody(context),
          ],
          ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _refreshPage() async {
    // Fetch the latest data and rebuild the UI
    await fetchPatients();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
    //  height: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3B5998),
            Color(0xFF6050F6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      navigateToWifiSetUpWidget();
                    },
                    child: const Text('set ESP wifi'),
                  ),
                ),
               /* IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),*/
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: PatientSearchDelegate(
                            PateintsNameAndId: PateintsNameAndId,
                            onSearch: filterPatients,
                          ),
                        );
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement logout functionality
                        logout();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement logout functionality
                        navigateToOverduePatientsPage();
                      },
                      icon: const Icon(Icons.warning_rounded, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Patient Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Track and manage rehabilitation progress',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildOverview(context),
            const SizedBox(height: 16),
            const Text(
              'Patient List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            this.PateintsNameAndId.isEmpty
                ?   Center(
              child: Text(
              'No patients available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
             )
      //const Center(child: CircularProgressIndicator())
                : ListView.builder(
              shrinkWrap: true, // Makes ListView adjust its height dynamically
              physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
              itemCount: this.filteredPatients.length,
              itemBuilder: (context, index) {
                List<String> parts = filteredPatients[index].split('+');
                String name = parts[0].trim();
                String id = parts[1].trim();
                return _buildPatientCard(
                  context,
                  imageUrl:
                  'https://images.unsplash.com/photo-1576765608075-5875c74feac7?w=500&h=500',
                  name: name,
                  id: id,
                  //  progress: sliderValue1,
                  lastTestDate: overduePatients[id].toString(),
                  //  onProgressChanged: (value) => setState(() => sliderValue1 = value),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: FloatingActionButton(
                onPressed: () {
                  navigateAddPatientsWidget(); // Use Navigator for navigation
                  print('Add patient button pressed');
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewColumn(context,this.PateintsNameAndId.length.toString(), 'Active Patients'),
           // _buildOverviewColumn(context, '78%', 'Avg Progress'),
           // _buildOverviewColumn(context, '156', 'Tests Completed'),
            // Download Data Column
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyPatientsDataWidget(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.cloud_download,
                    color: Color(0xFF6050F6), // Adjust color to match theme
                    size: 64,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Download Data',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    letterSpacing: 0.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPatientCard(
      BuildContext context, {
        required String imageUrl,
        required String name,
        required String id,
        //   required double progress,
        required String lastTestDate,
        //  required ValueChanged<double> onProgressChanged,
      }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ''+name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Id: ' + id,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    'Status: $lastTestDate',
                    style: TextStyle(fontSize: 14,
                        color: lastTestDate=='Tests Completed' ? Colors.green : lastTestDate=='Tests Not Taken' ? Color(0xFFFBC02D) : Colors.red),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),

                ElevatedButton(
                    onPressed: () {
                      PatientName = name;
                      PatientId = id;
                      navigateToTestsWidget();
                    },
                    child: const Text('View Tests'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      PatientName = name;
                      PatientId = id;
                      navigateToGoalsWidget();
                    },
                    child: const Text('View Goals'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      PatientName = name;
                      PatientId = id;
                      navigateToTestsAverageHistoryWidgetWidget();
                    },
                    child: const Text('View Overall Results'),
                  ),
         /*     ElevatedButton(
                onPressed: () async {
                  checkPatientTestDates();
                },
                child: Text('Send Test Notification'),
              ),*/

              /*const SizedBox(height: 8),
                  Text(
                    'Progress: ${progress.toInt()}%',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Slider(
                    value: progress,
                    min: 0,
                    max: 100,
                    onChanged: onProgressChanged,
                  ),*/

                ],
              ),
            ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              navigateToEditPatient(id);
            } else if (value == 'delete') {
              print('Delete option selected for $id');
              deletePatient(id);
              deletePatientFromArray(id, name);
              fetchPatients(); // Refresh the patient list
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          icon: const Icon(Icons.more_vert), // Icon for the menu
         ),
          ],
        ),
      ),
    );
  }
// Function to check Wi-Fi connection status
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      return true;
    }
    return false;
  }
/*
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

            if (now.difference(lastTest).inDays > 2) {
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
*/
// Function to show no Wi-Fi connection dialog
  void _showNoWiFiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Wi-Fi Connection"),
          content: const Text("Please connect to a Wi-Fi network and try again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> deletePatientFromArray(String documentId, String patientName) async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayRemove([patientName.trim() + ' + ' + documentId.trim()]),
      });
      print('Patient $patientName removed from array in document $documentId');
      /* print(patientName.trim() + ' + ' + documentId.trim());
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(UID).get();
      print(snapshot.get('patients'));*/
      /*  print(formattedString.codeUnits);
      print(snapshot.get('patients')[index].codeUnits); // Compare with the stored string*/

    } catch (e) {
      print('Error removing patient from array: $e');
    }
  }
  Future<void> deleteCollection(String collectionPath, int batchSize) async {
    try {
      // Reference to the collection
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      final collectionRef = FirebaseFirestore.instance.collection(collectionPath);

      // Get a batch of documents
      QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();

      // Delete documents in the batch
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot document in snapshot.docs) {
        batch.delete(document.reference);
      }

      // Commit the batch
      await batch.commit();

      // If there are more documents, recursively delete the next batch
      if (snapshot.docs.isNotEmpty) {
        await deleteCollection(collectionPath, batchSize);
      } else {
        print('Collection $collectionPath deleted successfully');
      }
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }

  Future<void> deletePatient(String documentId) async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      deleteCollection('patients/$documentId/results', 10);
      await FirebaseFirestore.instance.collection('patients').doc(documentId).delete();
      print('Document $documentId deleted successfully');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

}



class PatientSearchDelegate extends SearchDelegate {
  final List<String> PateintsNameAndId;
  final Function(String) onSearch;

  PatientSearchDelegate({
    required this.PateintsNameAndId,
    required this.onSearch,
  });


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSearch(query);
    });
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = PateintsNameAndId.where((patient) {
      List<String> parts = patient.split('+');
      String name = parts[0].trim().toLowerCase();
      String id = parts[1].trim().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        List<String> parts = suggestions[index].split('+');
        String name = parts[0].trim();
        String id = parts[1].trim();
        return ListTile(
          title: Text(name),
          subtitle: Text(id),
          onTap: () {
            query = name;
            close(context, null);
            onSearch(name);
          },
        );
      },
    );
  }
}
