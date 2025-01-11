import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_patient_model.dart';
import 'tests_widget.dart';
import 'wifi_setup_screen.dart';
import 'globals.dart';
import 'patients_progress_widget.dart';


class AddPatientWidget extends StatefulWidget {
  //final String UID;
  const AddPatientWidget({super.key});


//  final List<DocumentReference>? patients;

  @override
  State<AddPatientWidget> createState() => _AddPatientWidgetState();
}

class _AddPatientWidgetState extends State<AddPatientWidget> {
  late AddPatientModel _model;
 // late String UID;
 /* _AddPatientWidgetState(String UID) {
    this.UID=UID;
  }
*/
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = AddPatientModel();
    _model.initState(context);

    _model.IDTextController ??= TextEditingController();
    _model.fullNameTextController ??= TextEditingController();
    _model.ageTextController ??= TextEditingController();
    _model.phoneNumberTextController ??= TextEditingController();
    _model.descriptionTextController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  Future<void> addPatient() async {
    try {
      await FirebaseFirestore.instance.collection('patients').doc(_model.IDTextController!.text.trim()).set({
        'full_name': _model.fullNameTextController!.text.trim(),
        'ID': _model.IDTextController!.text.trim(),
        'age': _model.ageTextController!.text.trim(),
        'phone_number': _model.phoneNumberTextController!.text.trim(),
        'Gender': _model.choiceChipsValue,
        'symptoms': _model.descriptionTextController!.text.trim(),
        'DoctorName and Id ': DoctorName + DoctorID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    //  navigateToWifiSetUpWidget();
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
    try {
      await FirebaseFirestore.instance.collection('patients').doc(_model.IDTextController!.text.trim()).collection('results').doc('Auditory').set({
        'tests_numbers': 0,
    });
      await FirebaseFirestore.instance.collection('patients').doc(_model.IDTextController!.text.trim()).collection('results').doc('Visual').set({
        'tests_numbers': 0,
      });
      await FirebaseFirestore.instance.collection('patients').doc(_model.IDTextController!.text.trim()).collection('results').doc('Reading_text').set({
        'tests_numbers': 0,
      });
      await FirebaseFirestore.instance.collection('patients').doc(_model.IDTextController!.text.trim()).collection('results').doc('Basic_math').set({
        'tests_numbers': 0,
      });


      //  navigateToWifiSetUpWidget();
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
    try {
      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayUnion([_model.fullNameTextController!.text.trim()+' + '+_model.IDTextController!.text.trim()]),
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
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Add New Patient'),
        ),
        body: SafeArea(
          child: Form(
            key: _model.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name Input
                  TextFormField(
                    controller: _model.fullNameTextController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name*',
                      border: OutlineInputBorder(),
                    ),
                    validator: _model.fullNameTextControllerValidator,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _model.IDTextController,
                    decoration: const InputDecoration(
                      labelText: 'ID*',
                      border: OutlineInputBorder(),
                    ),
                    validator: _model.IDTextControllerValidator,
                  ),
                  const SizedBox(height: 16),


                  // Age Input
                  TextFormField(
                    controller: _model.ageTextController,
                    decoration: const InputDecoration(
                      labelText: 'Age*',
                      border: OutlineInputBorder(),
                    ),
                    validator: _model.ageTextControllerValidator,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Input
                  TextFormField(
                    controller: _model.phoneNumberTextController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender Dropdown
                  const Text('Gender'),
                  DropdownButtonFormField<String>(
                    value: _model.choiceChipsValue,
                    items: const [
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _model.choiceChipsValue = val;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  TextFormField(
                    controller: _model.descriptionTextController,
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
                        if (_model.formKey.currentState?.validate() ?? false) {
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
