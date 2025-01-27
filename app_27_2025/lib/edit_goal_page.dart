import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package
import 'dart:math';



class EditGoalPage extends StatefulWidget {
  final String goalTitle;
  final String Testname;
  final int firstAttempt;
  final int secondAttempt;
  final int thirdAttempt;
  final int bestScore;
  final int timesPerfectScore;
  final double averageScore;
 // final double successRate;

  const EditGoalPage({
    Key? key,
    required this.goalTitle,
    required this.firstAttempt,
    required this.Testname,
    required this.secondAttempt,
    required this.thirdAttempt,
    required this.bestScore,
    required this.timesPerfectScore,
    required this.averageScore,
   // required this.successRate,
  }) : super(key: key);

  @override
  _EditGoalPageState createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  late TextEditingController firstAttemptController;
  late TextEditingController secondAttemptController;
  late TextEditingController thirdAttemptController;
 // late TextEditingController bestScoreController;
  late String bestScoreController;
  late TextEditingController timesPerfectScoreController;
  late TextEditingController averageScoreController;
 // late TextEditingController successRateController;



  @override
  void initState() {
    super.initState();
    firstAttemptController =
        TextEditingController(text: widget.firstAttempt.toString());
    secondAttemptController =
        TextEditingController(text: widget.secondAttempt.toString());
    thirdAttemptController =
        TextEditingController(text: widget.thirdAttempt.toString());
    bestScoreController = (max(max(widget.firstAttempt, widget.secondAttempt),
        widget.thirdAttempt)).toString();
     //   widget.bestScore.toString();
       // TextEditingController(text: widget.bestScore.toString());
    timesPerfectScoreController =
        TextEditingController(text: widget.timesPerfectScore.toString());
    averageScoreController =
        TextEditingController(text: widget.averageScore.toString());
   // successRateController =
     //   TextEditingController(text: widget.successRate.toString());
  }

  @override
  void dispose() {
    firstAttemptController.dispose();
    secondAttemptController.dispose();
    thirdAttemptController.dispose();
  //  bestScoreController.dispose();
    timesPerfectScoreController.dispose();
    averageScoreController.dispose();
   // successRateController.dispose();
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

  Future<void> _saveGoals() async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      // Update the patient's details in Firestore
      await FirebaseFirestore.instance.collection('patients').doc(PatientId).collection('results').doc(widget.Testname).update({
        'goals': firstAttemptController.text.trim()+','+
                  secondAttemptController.text.trim()+','+
                  thirdAttemptController.text.trim()+','+
            (max(max(int.parse(firstAttemptController.text),  int.parse(secondAttemptController.text)),
                int.parse(thirdAttemptController.text))).toString().trim()+','+
                timesPerfectScoreController.text.trim()+','+
                  averageScoreController.text.trim()+',',

      });


    } catch (e) {
      print('Error updating patient: $e');
    }
  //  print('Error updating patient: $e');
    Navigator.pop(context, {
      'firstAttempt': int.parse(firstAttemptController.text),
      'secondAttempt': int.parse(secondAttemptController.text),
      'thirdAttempt': int.parse(thirdAttemptController.text),
      'bestScore': (max(max(int.parse(firstAttemptController.text),  int.parse(secondAttemptController.text)),
          int.parse(thirdAttemptController.text))),
      'timesPerfectScore': int.parse(timesPerfectScoreController.text),
      'averageScore': double.parse(averageScoreController.text),
   //   'successRate': double.parse(successRateController.text),
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.goalTitle} Goals'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView( // <-- Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Goals for ${widget.goalTitle}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField('First Attempt', firstAttemptController),
              _buildTextField('Second Attempt', secondAttemptController),
              _buildTextField('Third Attempt', thirdAttemptController),
        //      _buildTextField('Best Score', bestScoreController),
              _buildTextField('Times Perfect Score', timesPerfectScoreController),
              _buildTextField('Average Score', averageScoreController),
           //   _buildTextField('Success Rate', successRateController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Goals'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
