import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart'; // Ensure permission_handler is imported
import 'package:device_info_plus/device_info_plus.dart'; // Add this import
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io';
import 'dart:math';


class MyPatientsDataWidget extends StatefulWidget {
  const MyPatientsDataWidget({Key? key}) : super(key: key);

  @override
  State<MyPatientsDataWidget> createState() => _MyPatientsDataWidgetState();
}

class _MyPatientsDataWidgetState extends State<MyPatientsDataWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'My Patient Data',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Download All Data',
                                  style: TextStyle(
                                    fontFamily: 'Inter Tight',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Export your complete patient records',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.cloud_download,
                                color: Color(0xFF6050F6),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This will download all your patient records, test results, and medical history in a secure format.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Format: CSV',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            downloadAllData();
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            'Download All Data',
                            style: TextStyle(
                              fontFamily: 'Inter Tight',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color(0xFF6050F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<int> _getAndroidSdkVersion() async {
    if (kIsWeb) return 0; // Web doesn't have SDK versions
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      return 0; // Unknown SDK version
    }
  }

  Future<void> downloadAllData() async {
    try {
      int sdkVersion = await _getAndroidSdkVersion();

      // Determine required permissions based on SDK version
      if (sdkVersion >= 30) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Manage External Storage permission permanently denied. Please enable it in settings.'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Manage External Storage permission denied')),
            );
          }
          return;
        }
      } else {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Storage permission permanently denied. Please enable it in settings.'),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
          }
          return;
        }
      }

      // Get current doctor ID
      String doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      print("DoctorID: $doctorId");

      if (doctorId.isEmpty) {
        throw Exception("Doctor ID is not available.");
      }

      // Fetch patients data
      DocumentSnapshot doctorDoc;
      try {
        doctorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(doctorId)
            .get();

        if (!doctorDoc.exists) {
          throw Exception("Doctor document does not exist.");
        }

        List<dynamic> patients = doctorDoc['patients'] ?? [];
        if (patients.isEmpty) {
          throw Exception("No patient data found.");
        }
      } catch (e) {
        throw Exception("Error fetching patients data: $e");
      }

      // CSV Header
      List<List<String>> csvData = [
        [
          'DoctorID',
          'DoctorName',
          'PatientID',
          'PatientFullName',
          'PatientGender',
          'PatientAge',
         // 'CreatedAt',
        //  'PhoneNumber',
          'Symptoms',
          'TestName',
        //  'Goals',
        //  'TestType',
          'Level',
          'AverageScore',
          'BestScore',
          'FirstAttempt',
          'SecondAttempt',
          'ThirdAttempt',
          "PerfectScore"
          'Timestamp',
        ]
      ];

      // Add patient data to CSV
      print('first patient');

      for (var patient in doctorDoc['patients'] ?? []) {
        List<String> parts = patient.split('+');

        String patientID = parts[1].trim();
        String patientName = parts[0].trim();
        print('patientName to: $patientName');
        print('patientID to: $patientID');

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientID)//
            .get();

        String gender = snapshot['Gender'];
        print('gender to: $gender');

        String age = snapshot['age'] ;
        String phoneNumber = snapshot['phone_number'];
        String symptoms = snapshot['symptoms'];
        String createdAt =
        snapshot['createdAt']?.toDate().toIso8601String(); //to remove
        print('age to: $age');
        print('phone_number to: $phoneNumber');
        print('symptoms to: $symptoms');
     //   print('createdAt to: $createdAt');



        QuerySnapshot PatientsSnapshot = await FirebaseFirestore.instance
            .collection('patients')
            .doc(patientID)
            .collection('results')
            .get();

        for (var doc in PatientsSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          var testNumbers = data['tests_numbers'];
          if (testNumbers != 0) {
            for (int k = 0; k < testNumbers; k++) {
              String testValue = data['test' + (k + 1).toString()];
              print('testValue to: $testValue');
              Timestamp? lastTestDate = data['timestamp' + (k + 1).toString()];
              String timestampValue = lastTestDate.toString();
              if (lastTestDate != null) {
                DateTime date = lastTestDate.toDate();
                timestampValue =('${date.day}/${date.month}/${date.year}' + ' ${date.hour}:${date.minute}:${date.second}');
              }
              String testName =doc.id;
              List<String> parts = testValue.split('+');
              int FirstAttempt =(int.parse(parts[0].trim()));
              int SecondAttempt= (int.parse(parts[1].trim()));
              int ThirdAttempt = (int.parse(parts[2].trim()));
              String level = parts[3].trim();
              String best_score = (max(max(FirstAttempt,SecondAttempt),ThirdAttempt)).toString();
              int times_perfect_score=0;
              if (FirstAttempt==5) {
                times_perfect_score +=1;
              }
              if (SecondAttempt==5) {
                times_perfect_score +=1;
              }
              if (ThirdAttempt==5) {
                times_perfect_score +=1;
              }

              double  success_rate= ((FirstAttempt +
                  SecondAttempt +
                  ThirdAttempt) /
                  15);
              String average_score= (success_rate * 5).toString();
              // Add the row for each test with its corresponding timestamp
              csvData.add([
                doctorDoc['ID'] ?? '',
                doctorDoc['Name'] ?? '',
                patientID,
                patientName,
                gender,
                age,
               // createdAt,

               // phoneNumber,
                symptoms,
                testName,
                level,
                average_score,
                best_score,
                FirstAttempt.toString(),
                SecondAttempt.toString(),
                ThirdAttempt.toString(),
                times_perfect_score.toString(),
              //  test['goals'] ?? '',
              //  testName,
               // test['result'] ?? '',
              //  testValue,
                timestampValue,
              ]);
            }
          }
        }
      }



      // Add timestamp to the file name to avoid overwriting
      DateTime now = DateTime.now();
      String timestamp =('${now.day}_${now.month}_${now.year}' +'T${now.hour}-${now.minute}-${now.second}');
     /* String timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');*/
      String fileName = 'patient_data_$timestamp.csv';

      // Define the directory based on SDK version
      String directoryPath = sdkVersion >= 30
          ? '/storage/emulated/0/Download'
          : '/storage/emulated/0/Documents';
      final directory = Directory(directoryPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      String path = '$directoryPath/$fileName';
      print('Saving CSV to: $path');

      // Write the CSV data to the file
      File file = File(path);
      await file.writeAsString(const ListToCsvConverter().convert(csvData));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data downloaded successfully! Saved at: $path'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
