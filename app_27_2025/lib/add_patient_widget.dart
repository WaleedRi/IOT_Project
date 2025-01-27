import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'add_patientdart';
import 'tests_widget.dart';
import 'wifi_setup_screen.dart';
import 'globals.dart';
import 'patients_progress_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package



class AddPatientWidget extends StatefulWidget {
  //final String UID;
  //const AddPatientWidget({super.key});
  const AddPatientWidget({Key? key}) : super(key: key);

//  final List<DocumentReference>? patients;

  @override
  State<AddPatientWidget> createState() => _AddPatientWidgetState();
}

class _AddPatientWidgetState extends State<AddPatientWidget> {
 // late AddPatientModel _model;
  final TextEditingController  IDTextController = TextEditingController();
  final TextEditingController fullNameTextController = TextEditingController();
  final TextEditingController ageTextController = TextEditingController();
  final TextEditingController phoneNumberTextController = TextEditingController();
  final TextEditingController descriptionTextController = TextEditingController();
  String? Function(String?)? fullNameTextControllerValidator = (String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter the patient\'s full name.';
    }
    return null;
  };
  String? Function(String?)? IDTextControllerValidator = (String? val) {
    if (val == null || val.length!=9) {
      return 'Please enter right ID .';
    }
    return null;
  };
  String? Function(String?)? ageTextControllerValidator = (String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an age for the patient.';
    }
    return null;
  };

  String? choiceChipsValue;

  // late String UID;
 /* _AddPatientWidgetState(String UID) {
    this.UID=UID;
  }
*/
//  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

//  @override
 /* void initState() {
    super.initState();
 //   _model = AddPatientModel();
  //  initState(context);

    IDTextController ??= TextEditingController();
    fullNameTextController ??= TextEditingController();
    ageTextController ??= TextEditingController();
    phoneNumberTextController ??= TextEditingController();
    descriptionTextController ??= TextEditingController();
  }*/




  @override
  void dispose() {
  IDTextController.dispose();
  fullNameTextController.dispose();
  ageTextController.dispose();
  phoneNumberTextController.dispose();
  descriptionTextController.dispose();
  super.dispose();
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
  Future<void> addPatient() async {
    try {
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).set({
        'full_name': fullNameTextController!.text.trim(),
        'ID': IDTextController!.text.trim(),
        'age': ageTextController!.text.trim(),
        'phone_number': phoneNumberTextController!.text.trim(),
        'Gender': choiceChipsValue,
        'symptoms': descriptionTextController!.text.trim(),
        'DoctorName': DoctorName ,
        'DoctorID' : DoctorID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    //  navigateToWifiSetUpWidget();
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
    try {
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).collection('results').doc('Auditory').set({
        'tests_numbers': 0,
        'goals' : '1,1,1,1,5,1',
    });
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).collection('results').doc('Basic_math').set({
        'tests_numbers': 0,
        'goals' : '1,1,1,1,5,1',
      });
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).collection('results').doc('Reading_text').set({
        'tests_numbers': 0,
        'goals' : '1,1,1,1,5,1',
      });
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).collection('results').doc('Reflex').set({
        'tests_numbers': 0,
        'goals' :'1,1,1,1,5,1',
      });
      await FirebaseFirestore.instance.collection('patients').doc(IDTextController!.text.trim()).collection('results').doc('Visual').set({
        'tests_numbers': 0,
        'goals' : '1,1,1,1,5,1',
      });


      //  navigateToWifiSetUpWidget();
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayUnion([fullNameTextController!.text.trim()+' + '+IDTextController!.text.trim()]),
      });
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
    navigateToPatientProgressWidget();

  }

  void navigateToPatientProgressWidget() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PatientsProgressWidget(),
      ),
          (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      //  key: formKey,
        appBar: AppBar(
          title: const Text('Add New Patient'),
        ),
        body: SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name Input
                  TextFormField(
                    controller: fullNameTextController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: fullNameTextControllerValidator,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: IDTextController,
                    decoration: const InputDecoration(
                      labelText: 'ID*',
                      border: OutlineInputBorder(),
                    ),
                    validator: IDTextControllerValidator,
                  ),
                  const SizedBox(height: 16),


                  // Age Input
                  TextFormField(
                    controller: ageTextController,
                    decoration: const InputDecoration(
                      labelText: 'Age*',
                      border: OutlineInputBorder(),
                    ),
                    validator: ageTextControllerValidator,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Input
                  TextFormField(
                    controller: phoneNumberTextController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Dropdown
                  const Text('Gender'),
                  DropdownButtonFormField<String>(
                    value: choiceChipsValue,
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                    //  DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        choiceChipsValue = val;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  TextFormField(
                    controller: descriptionTextController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Describe symptoms...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                          addPatient();
                        if (formKey.currentState?.validate() ?? false) {
                          // Handle form submission
                          print('Form submitted');
                        }
                      },
                      child: const Text('Submit Form'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
