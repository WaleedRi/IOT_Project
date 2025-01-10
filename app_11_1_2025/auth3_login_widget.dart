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
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisibility = false;

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  Future<void> _loginAccount() async {
    if (emailAddressController == null || passwordController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email or Password field is not initialized.')),
      );
      return;
    }

    if (emailAddressController!.text.isEmpty ||
        passwordController!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    setState(() {
      // _isLoading = true;
    });

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddressController!.text.trim(),
        password: passwordController!.text.trim(),
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
        // _isLoading = false;
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
  /* void navigateToAddPatientWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientWidget(),
      ),
    );
  }*/
  void navigateToPatientsProgressWidget() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PatientsProgressWidget()),
          (Route<dynamic> route) => false, // Removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (MediaQuery.of(context).size.width > 600) // For larger screens
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context).primaryColorLight,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 570),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).cardColor,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 24),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          _buildLoginButton(context),
                          const SizedBox(height: 16),
                          _buildSignUpLink(context),
                          const Divider(height: 32, thickness: 1),
                          _buildForgotPasswordLink(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.medical_services,
          color: Theme.of(context).primaryColor,
          size: 44,
        ),
        const SizedBox(width: 12),
        Text(
          'RehappFriend',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailAddressController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: !passwordVisibility,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisibility ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              passwordVisibility = !passwordVisibility;
            });
          },
        ),
      ),
      autofillHints: const [AutofillHints.password],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password.';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _loginAccount();
        // Replace this with your login logic
        print('Login pressed');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Login'),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to sign-up page
        navigateToCreateWidget();
        print('Sign Up link pressed');
      },
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Sign Up here',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to forgot password page
        print('Forgot Password link pressed');
      },
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Forgot Password? ',
              style: TextStyle(color: Colors.black),
            ),
            TextSpan(
              text: 'Reset It Now',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
