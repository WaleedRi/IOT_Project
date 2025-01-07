import 'package:flutter/material.dart';

class Auth3CreateModel {
  // State fields for email address.
  FocusNode? emailAddressFocusNode;
  TextEditingController emailAddressTextController = TextEditingController();

  // State fields for password.
  FocusNode? passwordFocusNode;
  TextEditingController passwordTextController = TextEditingController();
  bool passwordVisibility = false;

  // State fields for confirm password.
  FocusNode? passwordConfirmFocusNode;
  TextEditingController passwordConfirmTextController = TextEditingController();
  bool passwordConfirmVisibility = false;

  void initState(BuildContext context) {
    emailAddressFocusNode = FocusNode();
    emailAddressTextController = TextEditingController();

    passwordFocusNode = FocusNode();
    passwordTextController = TextEditingController();

    passwordConfirmFocusNode = FocusNode();
    passwordConfirmTextController = TextEditingController();
  }

  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }
}
