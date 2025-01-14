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

  TextEditingController? IDTextController;
  String? Function(String?)? IDTextControllerValidator = (String? val) {
    if (val == null || val.length!=9) {
      return 'Please enter right ID .';
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
    IDTextController = TextEditingController();
    fullNameTextController = TextEditingController();
    ageTextController = TextEditingController();
    phoneNumberTextController = TextEditingController();
    descriptionTextController = TextEditingController();
  }

  void dispose() {
    IDTextController?.dispose();
    fullNameTextController?.dispose();
    ageTextController?.dispose();
    phoneNumberTextController?.dispose();
    descriptionTextController?.dispose();
  }
}
