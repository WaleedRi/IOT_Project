import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'single_test_results.dart';
import 'globals.dart';
import 'graph.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package

import 'tests_widget.dart';


class TestHistoryWidget extends StatefulWidget {
  const TestHistoryWidget({super.key});

  @override
  State<TestHistoryWidget> createState() => _TestHistoryWidgetState();
}

class _TestHistoryWidgetState extends State<TestHistoryWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int lastTest=0;
  List<int> FirstAttempt = [];
  List<int> SecondAttempt = [];
  List<int> ThirdAttempt = [];
  List<int> best_score = [];
  List<int> times_perfect_score=[];
  List<double> average_score=[];
  List<double> success_rate=[];
  List<String> timestamps=[];
  List<int> levels=[];


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

  Future<void> fetchTests() async {
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(PatientId)
          .collection('results')
          .doc(TestGameName)
          .get();

      print('patients/$PatientId/results/$TestGameName');
      if (snapshot.exists) {
        lastTest =snapshot.get('tests_numbers');
        times_perfect_score = List.filled(lastTest , 0);
        print(lastTest);
        setState(() {
          for(int i =0; i<lastTest;i++){
            String result =snapshot.get('test'+(i+1).toString());
            List<String> parts = result.split('+');
            FirstAttempt.add(int.parse(parts[0].trim()));
            SecondAttempt.add(int.parse(parts[1].trim()));
            ThirdAttempt.add(int.parse(parts[2].trim()));
            levels.add(int.parse(parts[3].trim()));
            print('First Attempt for test $i: ${FirstAttempt[i]}');
            print('Second Attempt for test $i: ${SecondAttempt[i]}');
            print('Third Attempt for test $i: ${ThirdAttempt[i]}');
            best_score.add(max(max(FirstAttempt[i],SecondAttempt[i]),ThirdAttempt[i]));
            if (FirstAttempt[i]==5) {
              times_perfect_score[i] +=1;
            }
            if (SecondAttempt[i]==5) {
              times_perfect_score[i] +=1;
            }
            if (ThirdAttempt[i]==5) {
              times_perfect_score[i] +=1;
            }

            success_rate.add((FirstAttempt[i] +
                SecondAttempt[i] +
                ThirdAttempt[i]) /
                15);
            average_score.add(success_rate[i] * 5);
            Timestamp? timestamp = snapshot['timestamp'+(i+1).toString()];
            if (timestamp != null) {
              DateTime date = timestamp.toDate();
              timestamps.add('${date.day}/${date.month}/${date.year}');
              print('Document written at: $date');
            } else {
              print('No timestamp available');
            }
          }
        }
        );
      }
    } catch (e) {
      print('Error fetching Tests: $e');
    }
  }

  Future<void> _refreshPage() async {
    // Fetch the latest data and rebuild the UI
    await fetchTests();
  }
  @override
  void initState() {
    super.initState();
    fetchTests();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,

          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
            onPressed: () {
              // Handle back navigation
              navigateToTestWidget(); // Navigate back to the previous page
            },
          ),
          title: Text(
            'Test History & Analytics',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
         /* actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                // Handle filter button
              },
            ),
          ],*/
          elevation: 0,
        ),
        body: SafeArea(
    child: RefreshIndicator(
    onRefresh: _refreshPage,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildSectionTitle('Recent Tests'),
                  ...buildRecentTests(),
                  SizedBox(height: 24),
                  buildSmallGraphContainer(
                    context,
                    title: 'Average Score Progression',
                  //  placeholder: 'Graph showing average score trend across tests',
                    successRates: average_score,
                    max_y: 5,
                    healthy_baseline: 3.5,
                    colorgraph:  Colors.blue
                  ),
                /*  SizedBox(height: 24),
                      buildSmallGraphContainer(
                        context,
                        title: 'Success Rate',
                      //  placeholder: 'Success rate graph',
                        successRates: success_rate.map((num) => num * 100).toList(),
                          max_y: 100,
                          healthy_baseline: 80,
                          colorgraph:  Colors.cyanAccent

                      ),*/
                  SizedBox(height: 24),
                  buildSmallGraphContainer(
                    context,
                    title: 'Best Scores',
                  //  placeholder: 'Best scores graph',
                    successRates:   best_score.map((e) => e.toDouble()).toList(),
                      max_y: 5,
                      healthy_baseline: 5,
                      colorgraph:  Colors.green

                  ),
                  SizedBox(height: 24),
                  buildSmallGraphContainer(
                    context,
                    title: 'Perfect Scores',
                  //  placeholder: 'Perfect scores graph',
                    successRates: times_perfect_score.map((e) => e.toDouble()).toList(),
                    max_y: 3,
                    healthy_baseline: 1.5,
                    colorgraph:  Colors.yellow

                  ),
                  SizedBox(height: 24),
                      buildSmallGraphContainer(
                        context,
                        title: 'First Attempt',
                    //    placeholder: 'First attempt performance graph',
                        successRates: FirstAttempt.map((e) => e.toDouble()).toList(),

                        max_y: 5,
                        healthy_baseline: 3,
                        colorgraph:  Colors.purple

                      ),
                  SizedBox(height: 24),
                      buildSmallGraphContainer(
                        context,
                        title: 'Second Attempt',
                  //      placeholder: 'Second attempt performance graph',
                        successRates: SecondAttempt.map((e) => e.toDouble()).toList(),
                        max_y: 5,
                        healthy_baseline: 4,
                        colorgraph:  Colors.pink


                      ),
                  SizedBox(height: 24),
                      buildSmallGraphContainer(
                        context,
                        title: 'Third Attempt',
                   //     placeholder: 'Third attempt performance graph',
                        successRates: ThirdAttempt.map((e) => e.toDouble()).toList(),
                        max_y: 5,
                        healthy_baseline: 4.5,
                        colorgraph:  Colors.orange

                      ),

                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter Tight',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> buildRecentTests() {
    return [
      const SizedBox(height: 16),
      lastTest==0
          ?  Center(
        child: Text(
          'No test available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      )//const Center(child: CircularProgressIndicator())
          : ListView.builder(
        shrinkWrap: true, // Makes ListView adjust its height dynamically
        physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
        itemCount: lastTest,
        itemBuilder: (context, index) {
          return  buildRecentTestTile(
            testNumber: 'Test #'+(lastTest-index).toString(),
            firstAttempt: FirstAttempt[lastTest-index-1].toString(),
            secondAttempt: SecondAttempt[lastTest-index-1].toString(),
            thirdAttempt: ThirdAttempt[lastTest-index-1].toString(),
            bestScore: best_score[lastTest-index-1].toString(),
            timesPerfectScore: times_perfect_score[lastTest-index-1].toString(),
            averageScore:  average_score[lastTest-index-1].toStringAsFixed(2),
            date: timestamps[lastTest-index-1],
            level: levels[lastTest-index-1].toString(),
            successRate: (success_rate[lastTest-index-1]*100).toStringAsFixed(1)+'%',
          );
        },
      ),
      /*
      buildRecentTestTile(
        testNumber: 'Test #12',
        date: 'May 15, 2023',
        score: '85%',
      ),
      buildRecentTestTile(
        testNumber: 'Test #11',
        date: 'May 10, 2023',
        score: '92%',
      ),*/
    ];
  }

  Widget buildRecentTestTile({
    required String testNumber,
    required String date,
    required String level,
    required String firstAttempt,
    required String secondAttempt,
    required String thirdAttempt,
    required String bestScore,
    required String timesPerfectScore,
    required String averageScore,
    required String successRate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                testNumber,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                'Level:' + level,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  successRate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  navigateToSingleTestResultWidget(firstAttempt,secondAttempt,thirdAttempt,bestScore,timesPerfectScore,averageScore,successRate,);
                  // Handle "View Results" button press
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text('View Results'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<double> sanitizeData(List<double> data) {
    return data.map((value) => value.isFinite ? value : 0.0).toList();
  }

  Widget buildSmallGraphContainer(BuildContext context,
      {required String title,
        required List<double> successRates,
        required double max_y,
        required double healthy_baseline,
        required Color colorgraph
      }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 450,
            child: SuccessRateGraph(
              successRates: sanitizeData(successRates),
              max_y: max_y,
              healthy_baseline: healthy_baseline,
              colorgraph: colorgraph,
              times: timestamps,
              levels: levels,
            ),
          ),
        ],
      ),
    );
  }
  void navigateToTestWidget() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestsWidget(),
      ),
    );
  }
  void navigateToSingleTestResultWidget(String firstAttempt,
      String secondAttempt,
      String thirdAttempt,
      String bestScore,
      String timesPerfectScore,
      String averageScore,
      String successRate
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingleTestResultWidget(
             firstAttempt: firstAttempt,
             secondAttempt: secondAttempt,
             thirdAttempt: thirdAttempt,
             bestScore: bestScore,
             timesPerfectScore: timesPerfectScore,
             averageScore: averageScore,
             successRate: successRate,
        )
      ),
    );
  }
}
