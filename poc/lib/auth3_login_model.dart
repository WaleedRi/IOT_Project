import 'package:flutter/material.dart';

class Auth3LoginModel {
  /// State fields for stateful widgets on this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController = TextEditingController();

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController = TextEditingController();
  bool passwordVisibility = false;

  /// Initialization and disposal methods.
  void initState(BuildContext context) {
    emailAddressFocusNode = FocusNode();
    emailAddressTextController = TextEditingController();

    passwordFocusNode = FocusNode();
    passwordTextController = TextEditingController();
  }

  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
