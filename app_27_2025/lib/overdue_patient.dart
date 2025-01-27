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
import 'patients_progress_widget.dart';


class OverduePatientsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overdue Patients"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PatientsProgressWidget()), // Replace with your page
            );
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('patients').get(),
        builder: (context, patientSnapshot) {
          if (!patientSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> overduePatientsList = [];

          return FutureBuilder<void>(
            future: Future.forEach(patientSnapshot.data!.docs, (patientDoc) async {
              print(patientDoc['DoctorName'] + ' ' +DoctorName );
              print(patientDoc['DoctorID'] + ' ' +DoctorID );
             if(patientDoc['DoctorName'] == DoctorName && patientDoc['DoctorID']==DoctorID){
                String patientId = patientDoc.id;
                String fullName = patientDoc['full_name'];

                QuerySnapshot testsSnapshot = await FirebaseFirestore.instance
                    .collection('patients')
                    .doc(patientId)
                    .collection('results')
                    .get();

                for (var testDoc in testsSnapshot.docs) {
                  Map<String, dynamic> data = testDoc.data() as Map<
                      String,
                      dynamic>;
                  var lastTest = data['tests_numbers'];
                  if (lastTest != null && lastTest != 0) {
                    Timestamp? lastTestDate = data['timestamp' +
                        lastTest.toString()];
                    if (lastTestDate != null) {
                      DateTime lastTest = lastTestDate.toDate();
                      if (DateTime
                          .now()
                          .difference(lastTest)
                          .inDays > 7) {
                        overduePatientsList.add({
                          'name': fullName,
                          'patientId': patientId,
                          'lastTestDate': lastTest,
                          'testName': testDoc.id
                        });
                      }
                    }
                  } else {
                   overduePatientsList.add({
                      'name': fullName,
                      'patientId': patientId,
                      'lastTestDate': 'No tests available',
                      'testName': testDoc.id
                    });
                  }
                }
              }
            }),
            builder: (context, snapshot) {
              if (overduePatientsList.isEmpty) {
                return const Center(child: Text("No overdue patients"));
              }

              return ListView.builder(
                itemCount: overduePatientsList.length,
                itemBuilder: (context, index) {
                  var patient = overduePatientsList[index];
                  return  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${patient['name']}'),
                        Text('Patient ID: ${patient['patientId']}'),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient['lastTestDate'] is DateTime
                              ? 'Last test: ${patient['lastTestDate']}'
                              : 'No tests available',
                        ),
                        Text('Test Name: ${patient['testName'] ?? "Unknown"}'),  // Add test name
                      ],
                    ),
                    trailing: Icon(Icons.warning, color: Colors.red),
                  );

                },
              );
            },
          );
        },
      ),
    );
  }

}