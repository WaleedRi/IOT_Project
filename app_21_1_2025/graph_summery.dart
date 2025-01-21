import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';
import 'dart:math';


class Graphs extends StatelessWidget {
  final List<List<double>> allSuccessRates;
  final double max_y;
  final int max_x;
  final List<Color> graphColors;

  Graphs({
    required this.allSuccessRates,
    required this.max_y,
    required this.max_x,
    required this.graphColors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Test ${value.toInt()}'),
                            );
                          },
                          reservedSize: 40, // Space for x-axis titles
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: _buildMultipleGraphs(),

                    minX: 1,
                    maxX: 10,
                    minY: 0,
                    maxY: max_y,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildMultipleGraphs() {
    List<LineChartBarData> lineCharts = [];

    for (int i = 0; i < allSuccessRates.length; i++) {
      lineCharts.add(
        LineChartBarData(
          spots: allSuccessRates[i]
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble() + 1, entry.value))
              .toList(),
          isCurved: true,
          color: graphColors[i],
          barWidth: 3,
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: true),
        ),
      );
    }

    return lineCharts;
  }
}

class TestsAverageHistoryWidget extends StatefulWidget {
  const TestsAverageHistoryWidget({super.key});

  @override
  State<TestsAverageHistoryWidget> createState() => _TestsAverageHistoryWidgetState();
}

class _TestsAverageHistoryWidgetState extends State<TestsAverageHistoryWidget> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int lastTest=0;
  List<int> FirstAttempt = [];
  List<int> SecondAttempt = [];
  List<int> ThirdAttempt = [];
  //List<int> best_score = [];
  //List<int> times_perfect_score=[];
  List<List<double>> average_score=[];
  List<double> success_rate=[];
  int numOfTests=0;




  Future<void> fetchAllTests() async {

    try {
      CollectionReference collectionRef = FirebaseFirestore.instance.collection(
          'patients').doc(PatientId).collection('results');

      QuerySnapshot querySnapshot = await collectionRef.get();
      int j = 0;
      average_score = List.generate(5, (_) => []);
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        lastTest = data['tests_numbers'];
        numOfTests = lastTest>numOfTests ? lastTest : numOfTests;
        success_rate =[];
        FirstAttempt = [];
        SecondAttempt = [];
        ThirdAttempt = [];
        //average_score = List.filled(lastTest , []);
      //  average_score = List.generate(lastTest+1, (_) => []);
        print('average_score list : ${average_score}');
        print("lastTest : ${lastTest}");
        print("numOfTests : ${numOfTests}");
        for(int i =0; i<lastTest;i++){
          String result =data['test'+(i+1).toString()];
          List<String> parts = result.split('+');
          FirstAttempt.add(int.parse(parts[0].trim()));
          SecondAttempt.add(int.parse(parts[1].trim()));
          ThirdAttempt.add(int.parse(parts[2].trim()));
          print('First Attempt for test $i: ${FirstAttempt[i]}');
          print('Second Attempt for test $i: ${SecondAttempt[i]}');
          print('Third Attempt for test $i: ${ThirdAttempt[i]}');
        //  best_score.add(max(max(FirstAttempt[i],SecondAttempt[i]),ThirdAttempt[i]));
      /*    if (FirstAttempt[i]==5) {
       //     times_perfect_score[i] +=1;
          }
          if (SecondAttempt[i]==5) {
       //     times_perfect_score[i] +=1;
          }
          if (ThirdAttempt[i]==5) {
      //      times_perfect_score[i] +=1;
          }
*/
          success_rate.add((FirstAttempt[i] +
              SecondAttempt[i] +
              ThirdAttempt[i]) /
              15);
          print('First Attempt for test : ${success_rate}');

          average_score[j].add(success_rate[i] * 5);


        }

         j++;
      }

    } catch (e) {
      print('Error fetching Tests: $e');
    }
  }

  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    fetchAllTests().then((_) {
      setState(() {
        _isLoading = false; // Data has been fetched
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())  //
        : GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Test History & Analytics',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                // Handle filter button
              },
            ),
          ],
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildSectionTitle('Recent Tests'),
                 // ...buildRecentTests(),
                  SizedBox(height: 24),
                  buildSmallGraphContainer(
                      context,
                      title: 'Average Score Progression',
                      //  placeholder: 'Graph showing average score trend across tests',
                      successRates: average_score,
                      max_y: 5,
                      max_x: numOfTests,
                   //   healthy_baseline: 3.5,
                      graphColors:  [Colors.blue,Colors.green, Colors.yellow,Colors.purple,Colors.orange]
                  ),

                ],
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
/*
  List<Widget> buildRecentTests() {
    return [
      const SizedBox(height: 16),
      lastTest==0
          ?  Center(
        child: Text(
          'No patients available',
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
            date: 'May 15, 2023',
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

 */

  Widget buildRecentTestTile({
    required String testNumber,
    required String date,
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
             //     navigateToSingleTestResultWidget(firstAttempt,secondAttempt,thirdAttempt,bestScore,timesPerfectScore,averageScore,successRate);
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

  Widget buildGraphContainer(
      BuildContext context, {
        required String title,
        required List<List<double>> successRates,
        required double max_y,
        required int max_x,
     //   required double healthy_baseline,
        required List<Color> graphColors,

      }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 450,
            child: Graphs(allSuccessRates: successRates,max_y: max_y,max_x:max_x,graphColors: graphColors,),
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
        required List<List<double>>  successRates,
        required double max_y,
        required int max_x,
        //required double healthy_baseline,
        required List<Color> graphColors}) {
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
            child: Graphs(allSuccessRates: successRates,max_y: max_y,max_x:max_x,graphColors: graphColors,),

          ),
        ],
      ),
    );
  }

/*  void navigateToSingleTestResultWidget(String firstAttempt,
      String secondAttempt,
      String thirdAttempt,
      String bestScore,
      String timesPerfectScore,
      String averageScore,
      String successRate) {
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
              successRate: successRate)
      ),
    );
  }*/
}

