/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestsWidget extends StatefulWidget {
  const TestsWidget({super.key});

  @override
  State<TestsWidget> createState() => _TestsWidgetState();
}

class _TestsWidgetState extends State<TestsWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: const Text(
            'Patient Tests',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                print('Notifications Icon Pressed');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTestCard(
                    context,
                    title: 'Auditory Memory Test',
                    status: 'Not completed',
                    statusColor: Colors.red,
                    buttonText: 'Take Test',
                    buttonAction: startTest,
                  ),
                  const SizedBox(height: 16.0),
                  _buildTestCard(
                    context,
                    title: 'Visual Memory Test',
                    status: 'Completed on May 15, 2023',
                    statusColor: Colors.green,
                    buttonText: 'View Results',
                    buttonAction: () {
                      print('View Results Pressed');
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildTestCard(
                    context,
                    title: 'Number Test',
                    status: 'Not completed',
                    statusColor: Colors.red,
                    buttonText: 'Take Test',
                    buttonAction: startTest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard(
      BuildContext context, {
        required String title,
        required String status,
        required Color statusColor,
        required String buttonText,
        required VoidCallback buttonAction,
      }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              status,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.0,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startTest() async {
    const esp32Url = 'http://10.0.0.14/start'; // Replace with ESP32's IP address
    try {
      final response = await http.get(Uri.parse(esp32Url));
      if (response.statusCode == 200) {
        print('Test started successfully: ${response.body}');
      } else {
        print('Failed to start test');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
*/


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart';

class TestsWidget extends StatelessWidget {
 // final String espIp;
 // final String PatientName;

  const TestsWidget({Key? key}) : super(key: key);

  void startTest(String patientName,String testName) async {
    try {
      final response = await http.post(Uri.parse('http://$ESPIP/start'),
         body : {'patientName': patientName, 'testName': testName},);
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
    return Scaffold(
      appBar: AppBar(title: Text('Patient Tests')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTestCard(
              context,
              title: 'Auditory Memory Test',
           //   status: 'Not completed',
              backgroundColor: Colors.blue,
            //  statusColor: Colors.red,
              buttonText: 'Take Test',
              buttonAction: () => startTest(PatientName,"Auditory"),
              ResultsbackgroundColor: Colors.green,
              //   statusColor: Colors.green,
              ResultsbuttonText: 'View Results',
              ResultsbuttonAction: () {
                print('View Results Pressed');
              },
            ),
            const SizedBox(height: 16.0),
            _buildTestCard(
              context,
              title: 'Visual Memory Test',
           //   status: 'Completed on May 15, 2023',
              backgroundColor: Colors.blue,
              //  statusColor: Colors.red,
              buttonText: 'Take Test',
              buttonAction: () => startTest(PatientName,"Visual"),
              ResultsbackgroundColor: Colors.green,
              //   statusColor: Colors.green,
              ResultsbuttonText: 'View Results',
              ResultsbuttonAction: () {
                print('View Results Pressed');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
      BuildContext context, {
        required String title,
      //  required String status,
      //  required Color statusColor,
        required Color backgroundColor,
        required String buttonText,
        required VoidCallback buttonAction,
        required Color ResultsbackgroundColor,
        required String ResultsbuttonText,
        required VoidCallback ResultsbuttonAction,
      }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
          /*  Text(
              status,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.0,
                color: statusColor,
              ),
            ),*/
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: buttonAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResultsbackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text(
                  ResultsbuttonText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),],
        ),
      ),
    );
  }
}


