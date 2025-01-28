import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'single_test_results.dart';
import 'test_statistics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'patients_progress_widget.dart';

class TestsWidget extends StatefulWidget {
  const TestsWidget({Key? key}) : super(key: key);

  @override
  State<TestsWidget> createState() => _TestsWidgetWidgetState();
}


class _TestsWidgetWidgetState extends State<TestsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false; // Added loading state

  Map<String, String> overduePatients = {};
  Map<String, Color> dateColors = {};



  Map<String, int> testLevels = {}; // Store selected levels for each test

  void updateTestLevel(String testName, int level) {
    setState(() {
      testLevels[testName] = level;
    });
  }

  void updateLastTestStatus(String testName, String Status) {
    setState(() {
      overduePatients[testName] = Status;
    });
  }

  void updateLastDateColors(String testName, Color color) {
    setState(() {
      dateColors[testName] = color;
    });
  }

  @override
  void initState() {
    super.initState();
    LastTestDate();
  }

  Future<void> _refreshPage() async {
    // Fetch the latest data and rebuild the UI
    await LastTestDate();
  }

  void startTest(String patientId, String testName,String testLevel) async {
    setState(() {
      isLoading = true; // Show loading animation
    });
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
    }finally {
      setState(() {
        isLoading = false; // Hide loading animation
      });
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
              navigateToPatientsProgressWidget(); // Navigate back to the previous page
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
        body: Stack(

            children: [
              RefreshIndicator(
                  onRefresh: _refreshPage, // Fu


        child: SafeArea(

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
                  'https://as2.ftcdn.net/v2/jpg/11/61/38/43/1000_F_1161384317_EmYPTfCbnMhnyjQJUfSBMlJuhyfCZBtr.jpg',
                  selectedLevel: testLevels["Auditory"] ?? 1,
                  lastTestDate: overduePatients["Auditory"].toString(),
                  dateColor: dateColors["Auditory"],
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
                  'https://as2.ftcdn.net/v2/jpg/09/14/19/27/1000_F_914192776_W4kSEF2SHATdRBLYcPvNLW8E5uPLvtkV.jpg',
                  selectedLevel: testLevels["Visual"] ?? 1,
                  dateColor: dateColors["Visual"],
                  lastTestDate: overduePatients["Visual"].toString(),

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
                  'https://as2.ftcdn.net/v2/jpg/01/45/49/15/1000_F_145491552_CFsyUBY9onH7UUz9wgqPL2XDRRLUE7DG.jpg',
                  selectedLevel: testLevels["Reading_text"] ?? 1,
                    dateColor: dateColors["Reading_text"],
                  lastTestDate: overduePatients["Reading_text"].toString(),

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
                  'https://as2.ftcdn.net/v2/jpg/01/55/88/37/1000_F_155883764_1Cuuhmf83evlSzFAGftRYSzqD7utLVSC.jpg',
                  selectedLevel: testLevels["Basic_math"] ?? 1,
                  lastTestDate: overduePatients["Basic_math"].toString(),
                    dateColor: dateColors["Basic_math"],
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
                  'https://as1.ftcdn.net/v2/jpg/09/80/87/82/1000_F_980878277_HnP8Qc7VWO7Dzih9G6wgNisTlfagk1Pn.jpg',
                  selectedLevel: testLevels["Reflex"] ?? 1,
                  lastTestDate: overduePatients["Reflex"].toString(),
                    dateColor: dateColors["Reflex"],
                  onLevelChange: (newLevel) => updateTestLevel("Reflex", newLevel),
                ),
              ],
            ),
          ),
        ),
              ),
            if (isLoading)
    Container(
    color: Colors.black.withOpacity(0.5), // Semi-transparent background
    child: const Center(
    child: CircularProgressIndicator(
    color: Colors.white, // Adjust to your theme
    ),
    ),
    ),
    ],
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
    required String lastTestDate,
    required Color? dateColor,
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
            Text(
              'Last Test: $lastTestDate',
              style: TextStyle(fontSize: 14,
                  color: dateColor),
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


  void navigateToPatientsProgressWidget() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PatientsProgressWidget(),
      ),
    );
  }
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
  Future<void> LastTestDate() async {
    QuerySnapshot testsSnapshot = await FirebaseFirestore.instance
        .collection('patients')
        .doc(PatientId)
        .collection('results')
    // .orderBy('last_test_date', descending: true) // Get the latest test first
    // .limit(1)
        .get();

    bool isOutdated = false;
    for (var doc in testsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var lastTest = data['tests_numbers'];
      if (lastTest != 0) {
        Timestamp? lastTestDate = data['timestamp' + (lastTest).toString()];
        if (lastTestDate != null) {
          DateTime lastTest = lastTestDate.toDate();
          if( DateTime.now()
              .difference(lastTest)
              .inDays > 7){
            updateLastDateColors(doc.id, Colors.red);
          } else{
            updateLastDateColors(doc.id, Colors.green);
          }
          updateLastTestStatus(
              doc.id, '${lastTest.day}/${lastTest.month}/${lastTest.year}');
              print(overduePatients[doc.id].toString() +
              '${lastTest.day}/${lastTest.month}/${lastTest.year}' + doc.id);
        }
      }else {
        updateLastTestStatus(doc.id, 'Tests Not Taken');
        updateLastDateColors(doc.id, Color(0xFFFBC02D));
        print(overduePatients[doc.id].toString() + 'Tests Not Taken' +
            doc.id);
      }


      }
  }
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
