import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'single_test_results.dart';
import 'test_statistics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package


class TestsWidget extends StatefulWidget {
  const TestsWidget({Key? key}) : super(key: key);

  @override
  State<TestsWidget> createState() => _TestsWidgetWidgetState();
}


class _TestsWidgetWidgetState extends State<TestsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, int> testLevels = {}; // Store selected levels for each test

  void updateTestLevel(String testName, int level) {
    setState(() {
      testLevels[testName] = level;
    });
  }

  void startTest(String patientId, String testName,String testLevel) async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      final response = await http.post(Uri.parse('http://$ESPIP/start'),
        body: {'patientId': patientId, 'testName': testName, 'testLevel': testLevel},);
      if (response.statusCode == 200) {
        print('Test started successfully: ${response.body}');
      } else {
        print('Failed to start the test');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100], // Primary background color
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          // Same as background
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            onPressed: () {
              // Handle back navigation
              Navigator.pop(context); // Navigate back to the previous page
            },
          ),
          title: const Text(
            'Patient Tests',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                _buildTestCard(
                  context,
                  title: 'Auditory Memory Test',
                  Testname: "Auditory",
                  description:
                  'Test patient ability to remember spoken colors and sequences',
                  imageUrl:
                  'https://images.unsplash.com/photo-1576089275954-40cd98bfcfdb?w=500&h=500',
                  selectedLevel: testLevels["Auditory"] ?? 1,
                  onLevelChange: (newLevel) => updateTestLevel("Auditory", newLevel),
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Visual Memory Test',
                  Testname: "Visual",
                  description:
                  'Test patient ability to remember visual colors and sequences',
                  imageUrl:
                  'https://images.unsplash.com/photo-1661347561109-92e1c0491904?w=500&h=500',
                  selectedLevel: testLevels["Visual"] ?? 1,
                  onLevelChange: (newLevel) => updateTestLevel("Visual", newLevel),
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Reading Text Test',
                  Testname: "Reading_text",
                  description:
                  'Evaluate patient recognize real words',
                  imageUrl:
                  'https://images.unsplash.com/photo-1520809227329-2f94844a9635?w=500&h=500',
                  selectedLevel: testLevels["Reading_text"] ?? 1,
                  onLevelChange: (newLevel) => updateTestLevel("Reading_text", newLevel),
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Basic Math Test',
                  Testname: "Basic_math",
                  description:
                  'Evaluate patient fundamental mathematical operations',
                  imageUrl:
                  'https://images.unsplash.com/photo-1622282971674-b36babc42070?w=500&h=500',
                  selectedLevel: testLevels["Basic_math"] ?? 1,
                  onLevelChange: (newLevel) => updateTestLevel("Basic_math", newLevel),
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Reflex Test',
                  Testname: "Reflex",
                  description:
                  'Assess patient reaction time and responsiveness to visual stimuli',
                  imageUrl:
                  'https://images.unsplash.com/photo-1622282971674-b36babc42070?w=500&h=500',
                  selectedLevel: testLevels["Reflex"] ?? 1,
                  onLevelChange: (newLevel) => updateTestLevel("Reflex", newLevel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(BuildContext context, {
    required String title,
    required String Testname,
    required String description,
    required String imageUrl,
    required int selectedLevel,
    required Function(int) onLevelChange,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter Tight',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Level Selection Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select Level: ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: selectedLevel,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  elevation: 8,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Theme.of(context).primaryColor,
                  ),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                        onLevelChange(newValue);
                    }
                  },
                  items: [1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Level $value'),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Handle view results
                    TestGameName = Testname;
                    navigateToTestHistoryWidget();
                    print('View Results Pressed');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    'View Results',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    startTest(PatientId, Testname,selectedLevel.toString());
                    print('PatientId= $PatientId  Testname=$Testname  Level=$selectedLevel');
                    // Handle take test with selected level
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    'Take Test',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*
  void navigateToSingleTestResultWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleTestResultWidget(),
      ),
    );
  }*/
  void navigateToTestHistoryWidget() async{
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      _showNoWiFiDialog();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestHistoryWidget(),
      ),
    );
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
          content: const Text(
              "Please connect to a Wi-Fi network and try again."),
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
}
