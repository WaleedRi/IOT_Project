import 'package:flutter/material.dart';

class AddPatientModel {
  /// State fields for stateful widgets on this page.

  final formKey = GlobalKey<FormState>();

  // State field(s) for Full Name widget.
  TextEditingController? fullNameTextController;
  String? Function(String?)? fullNameTextControllerValidator = (String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter the patient\'s full name.';
    }
    return null;
  };

  // State field(s) for Age widget.
  TextEditingController? ageTextController;
  String? Function(String?)? ageTextControllerValidator = (String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an age for the patient.';
    }
    return null;
  };

  // State field(s) for Phone Number widget.
  TextEditingController? phoneNumberTextController;

  // State field(s) for Gender dropdown.
  String? choiceChipsValue;

  // State field(s) for Description widget.
  TextEditingController? descriptionTextController;

  /// Initialization and disposal methods.
  void initState(BuildContext context) {
    fullNameTextController = TextEditingController();
    ageTextController = TextEditingController();
    phoneNumberTextController = TextEditingController();
    descriptionTextController = TextEditingController();
  }

  void dispose() {
    fullNameTextController?.dispose();
    ageTextController?.dispose();
    phoneNumberTextController?.dispose();
    descriptionTextController?.dispose();
  }
}
