import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';
import 'single_test_results.dart';
import 'test_statistics.dart';

class TestsWidget extends StatefulWidget {
  const TestsWidget({Key? key}) : super(key: key);

  @override
  State<TestsWidget> createState() => _TestsWidgetWidgetState();
}

class _TestsWidgetWidgetState extends State<TestsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void startTest(String patientId,String testName) async {
    try {
      final response = await http.post(Uri.parse('http://$ESPIP/start'),
        body : {'patientId': patientId, 'testName': testName},);
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
          backgroundColor: Colors.grey[100], // Same as background
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
                  'Test your ability to remember spoken words and sequences',
                  imageUrl:
                  'https://images.unsplash.com/photo-1576089275954-40cd98bfcfdb?w=500&h=500',
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Visual Memory Test',
                  Testname:"Visual",
                  description:
                  'Challenge your ability to remember visual patterns',
                  imageUrl:
                  'https://images.unsplash.com/photo-1661347561109-92e1c0491904?w=500&h=500',
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Reading Text Test',
                  Testname:"Reading_text",
                  description:
                  'Evaluate your reading comprehension skills',
                  imageUrl:
                  'https://images.unsplash.com/photo-1520809227329-2f94844a9635?w=500&h=500',
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context,
                  title: 'Basic Math Test',
                  Testname:"Basic_math",
                  description:
                  'Practice fundamental mathematical operations',
                  imageUrl:
                  'https://images.unsplash.com/photo-1622282971674-b36babc42070?w=500&h=500',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(
      BuildContext context, {
        required String title,
        required String Testname,
        required String description,
        required String imageUrl,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Handle view results
                    TestGameName=Testname;
                    navigateToTestHistoryWidget();
                   // navigateToSingleTestResultWidget();
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
                    startTest(PatientId,Testname);
                    print('PatientId= $PatientId  Testname=$Testname ');
                    // Handle take test
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Updated parameter
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
  void navigateToTestHistoryWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestHistoryWidget(),
      ),
    );
  }
}


