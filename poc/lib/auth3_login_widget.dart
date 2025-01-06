import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth3_login_model.dart';
import 'auth3_create_widget.dart';
import 'add_patient_widget.dart';
import 'patients_progress_widget.dart';
import 'wifi_setup_screen.dart';
import 'globals.dart';

class Auth3LoginWidget extends StatefulWidget {

  const Auth3LoginWidget({Key? key}) : super(key: key);

  @override
  State<Auth3LoginWidget> createState() => _Auth3LoginWidgetState();
}

class _Auth3LoginWidgetState extends State<Auth3LoginWidget> {
  late Auth3LoginModel _model;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _model = Auth3LoginModel();
    _model.initState(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  Future<void> _loginAccount() async {
    if (_model.emailAddressTextController == null || _model.passwordTextController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email or Password field is not initialized.')),
      );
      return;
    }

    if (_model.emailAddressTextController!.text.isEmpty ||
        _model.passwordTextController!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _model.emailAddressTextController!.text.trim(),
        password: _model.passwordTextController!.text.trim(),
      );

      // Navigate to the next screen if successful
    //  navigateToAddPatientWidget(userCredential.user!.uid);
      UID =userCredential.user!.uid;
      navigateToPatientsProgressWidget();
     // navigateToWifiSetUpWidget();
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToCreateWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Auth3CreateWidget(),
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
  void navigateToAddPatientWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientWidget(),
      ),
    );
  }
  void navigateToPatientsProgressWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientsProgressWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please log in to your account.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  // Email Input Field
                  TextField(
                    controller: _model.emailAddressTextController,
                    focusNode: _model.emailAddressFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  // Password Input Field
                  TextField(
                    controller: _model.passwordTextController,
                    focusNode: _model.passwordFocusNode,
                    obscureText: !_model.passwordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _model.passwordVisibility
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _model.passwordVisibility =
                            !_model.passwordVisibility;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginAccount,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) : const Text('Log In'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        navigateToCreateWidget();

                        // Navigate to "Forgot Password" or "Sign Up" screen.
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: 'Sign up here',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
