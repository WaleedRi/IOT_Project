import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';
import 'patients_progress_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package


class EditPatientWidget extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String age;
  final String phoneNumber;
  final String? gender;
  final String symptoms;

  const EditPatientWidget({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.phoneNumber,
    required this.gender,
    required this.symptoms,
  }) : super(key: key);

  @override
  State<EditPatientWidget> createState() => _EditPatientWidgetState();
}

class _EditPatientWidgetState extends State<EditPatientWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  String? Gender;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with existing patient details
    nameController.text = widget.patientName;
    idController.text = widget.patientId;
    ageController.text = widget.age;
    phoneController.text = widget.phoneNumber;
    symptomsController.text = widget.symptoms;
    Gender = widget.gender;
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
  Future<void> updatePatient() async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      // Update the patient's details in Firestore
      await FirebaseFirestore.instance.collection('patients').doc(widget.patientId).update({
        'full_name': nameController.text.trim(),
        'age': ageController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'Gender': Gender ?? widget.gender,
        'symptoms': symptomsController.text.trim(),
      });

      // Update the user's patient list in Firestore
      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayRemove([widget.patientName + ' + ' + widget.patientId]),
      });

      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayUnion([nameController.text.trim() + ' + ' + idController.text.trim()]),
      });


    } catch (e) {
      print('Error updating patient: $e');
    }
    print('Patient updated successfully');
    age =ageController.text.trim();
    phoneNumber = phoneController.text.trim();
    Patientgender = Gender ?? widget.gender;
    symptoms =symptomsController.text.trim();
    PatientName = nameController.text.trim();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientsProgressWidget(),
      ),
          (Route<dynamic> route) => false,

    );
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    ageController.dispose();
    phoneController.dispose();
    symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false, // Disable editing the ID
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Gender'),
                DropdownButtonFormField<String>(
                  value: Gender,
                  items: const [
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                  //  DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      Gender = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: symptomsController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Describe symptoms...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: updatePatient,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
