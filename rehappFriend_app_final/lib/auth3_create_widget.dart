import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth3_login_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package

import 'wifi_setup_screen.dart';


class Auth3CreateWidget extends StatefulWidget {
  const Auth3CreateWidget({Key? key}) : super(key: key);

  @override
  State<Auth3CreateWidget> createState() => _Auth3CreateWidgetState();
}

class _Auth3CreateWidgetState extends State<Auth3CreateWidget> {
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
  TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();

  bool _isLoading = false;
  bool passwordVisibility = false;
  bool passwordConfirmVisibility = false;

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    doctorNameController.dispose();
    doctorIdController.dispose();
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
  Future<void> _createAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate email and password
      if (passwordController!.text !=
          passwordConfirmController!.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create user with Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddressController!.text.trim(),
        password: passwordController!.text.trim(),
      );

      // Save user details in Firestore
      try {
        // Save user details in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'Name' : doctorNameController!.text.trim(),
          'ID'   :doctorIdController!.text.trim(),
          'email': emailAddressController!.text.trim(),
          'patients': [],
          'created_at': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        // Log Firestore-specific errors
        print('Firestore error: ${e.message}');
      } catch (e) {
        print('Unexpected error: $e');
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
        ),
      );

      // Navigate to another screen, e.g., login or home
      navigateToLoginWidget();

      // Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
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
  void navigateToLoginWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Auth3LoginWidget(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (MediaQuery.of(context).size.width > 600) // Responsive layout
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.background,
                          theme.primaryColorLight,
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surface,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 32),
                          _buildTitle(context),
                          const SizedBox(height: 16),
                          _buildDoctorNameField(),
                          const SizedBox(height: 16),
                          _buildDoctorIdField(),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          _buildPasswordConfirmField(),
                          const SizedBox(height: 16),
                          _buildCreateAccountButton(context),
                          const SizedBox(height: 16),
                          _buildSignInLink(context),
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
      children: [
        Icon(
          Icons.medical_services,
          color: Theme.of(context).primaryColor,
          size: 44,
        ),
        const SizedBox(width: 12),
        Text(
          'RehappFriend',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Let\'s get started by filling out the form below.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDoctorNameField() {
    return TextFormField(
      controller: doctorNameController,
      decoration: InputDecoration(
        labelText: 'Doctor Name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name.';
        }
        return null;
      },
    );
  }

  Widget _buildDoctorIdField() {
    return TextFormField(
      controller: doctorIdController,
      decoration: InputDecoration(
        labelText: 'Doctor ID',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Doctor ID.';
        }
        return null;
      },
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
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
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
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
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

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      controller: passwordConfirmController,
      obscureText: !passwordConfirmVisibility,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        suffixIcon: IconButton(
          icon: Icon(
            passwordConfirmVisibility ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              passwordConfirmVisibility = !passwordConfirmVisibility;
            });
          },
        ),
      ),
      validator: (value) {
        if (value != passwordController.text) {
          return 'Passwords don\'t match.';
        }
        return null;
      },
    );
  }

  Widget _buildCreateAccountButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (passwordController.text != passwordConfirmController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords don\'t match!')),
          );
          return;
        }
        _createAccount();
        // Add your account creation logic here
        print('Create Account button pressed');
        print('Doctor Name: ${doctorNameController.text}');
        print('Doctor ID: ${doctorIdController.text}');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Create Account'),
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Sign In page
        navigateToLoginWidget();
        print('Sign In link pressed');
      },
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: 'Sign In here',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
