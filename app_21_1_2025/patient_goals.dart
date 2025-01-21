import 'package:flutter/material.dart';
import 'edit_goal_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'globals.dart';

import 'dart:math';


class PatientGoalsWidget extends StatefulWidget {
  const PatientGoalsWidget({super.key});

  @override
  State<PatientGoalsWidget> createState() => _PatientGoalsWidgetState();
}

class _PatientGoalsWidgetState extends State<PatientGoalsWidget> {
  List<int> curr_firstAttempt=[];
  List<int> curr_secondAttempt=[];
  List<int> curr_thirdAttempt=[];
  List<int> curr_bestScore=[];
  List<int> curr_timesPerfectScore=[];
  List<double> curr_averageScore=[];
  //List<double> curr_successRate=[];

  List<int> goal_firstAttempt=[];
  List<int> goal_secondAttempt=[];
  List<int> goal_thirdAttempt=[];
  List<int> goal_bestScore=[];
  List<int> goal_timesPerfectScore=[];
  List<double> goal_averageScore=[];
  //List<double> goal_successRate=[60,60,60,60,60];



  Future<void> fetchAllDocuments() async {
    try {
      CollectionReference collectionRef = FirebaseFirestore.instance.collection('patients').doc(PatientId).collection('results');

      QuerySnapshot querySnapshot = await collectionRef.get();
        int i=0;
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Extract specific fields
        var goal = data['goals'];
        var testNumbers = data['tests_numbers'];
        int times_perfect_score = 0;



        List<String> goalsParts = goal.split(',');
        goal_firstAttempt.add(int.parse(goalsParts[0].trim()));
        goal_secondAttempt.add(int.parse(goalsParts[1].trim()));
        goal_thirdAttempt.add(int.parse(goalsParts[2].trim()));
        goal_bestScore.add(int.parse(goalsParts[3].trim()));
        goal_timesPerfectScore.add(int.parse(goalsParts[4].trim()));
        goal_averageScore.add(double.parse(goalsParts[5].trim()));
      if(testNumbers==0){
        curr_firstAttempt.add(0);
        curr_secondAttempt.add(0);
        curr_thirdAttempt.add(0);
        curr_bestScore.add(0);
        curr_timesPerfectScore.add(0);
        curr_averageScore.add(0);
      }else {
        String result = data['test' + (testNumbers).toString()];
        List<String> parts = result.split('+');
        curr_firstAttempt.add(int.parse(parts[0].trim()));
        curr_secondAttempt.add(int.parse(parts[1].trim()));
        curr_thirdAttempt.add(int.parse(parts[2].trim()));
        curr_bestScore.add(max(max(curr_firstAttempt[i], curr_secondAttempt[i]),
            curr_thirdAttempt[i]));
        if (curr_firstAttempt[i] == 5) {
          times_perfect_score += 1;
        }
        if (curr_secondAttempt[i] == 5) {
          times_perfect_score += 1;
        }
        if (curr_thirdAttempt[i] == 5) {
          times_perfect_score += 1;
        }
        curr_timesPerfectScore.add(times_perfect_score);

        double success_rate = ((curr_firstAttempt[i] +
            curr_secondAttempt[i] +
            curr_thirdAttempt[i]) /
            15);
        curr_averageScore.add(success_rate * 5);
      }
        print('First Attempt for test $i: ${curr_firstAttempt[i]}');
        print('Second Attempt for test $i: ${curr_secondAttempt[i]}');
        print('Third Attempt for test $i: ${curr_thirdAttempt[i]}');
        print('curr_bestScore for test $i: ${curr_bestScore[i]}');
        print('curr_timesPerfectScore for test $i: ${curr_timesPerfectScore[i]}');
        print('curr_averageScore for test $i: ${curr_averageScore[i]}');

        print('goal_firstAttempt for test $i: ${goal_firstAttempt[i]}');
        print('goal_secondAttempt for test $i: ${goal_secondAttempt[i]}');
        print('goal_thirdAttemptfor test $i: ${goal_thirdAttempt[i]}');
        print('goal_bestScore for test $i: ${goal_bestScore[i]}');
        print('goal_timesPerfectScorefor test $i: ${goal_timesPerfectScore[i]}');
        print('goal_averageScore for test $i: ${goal_averageScore[i]}');
        i++;
      }
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    fetchAllDocuments().then((_) {
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
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildBody(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF3B5998),
            Color(0xFF6050F6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const Text(
              'Recovery Goals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Track rehabilitation milestones and targets',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildGoalCard(
              context,
              title: 'Auditory Memory Test',
              Testname: "Auditory",
              subtitle: 'First Attempt',
              i: 0,
              cardColor: const Color(0xFFE3F2FD),
            ),
            const SizedBox(height: 24),
            _buildGoalCard(
              context,
              title: 'Basic Math Test',
              Testname:"Basic_math",
              subtitle: 'First Attempt',
              i: 1,
              cardColor: const Color(0xFFF3E5F5),
            ),
            const SizedBox(height: 24),
            _buildGoalCard(
              context,
              title: 'Reading Text Test',
              Testname:"Reading_text",
              subtitle: 'First Attempt',
              i: 2,
              cardColor: const Color(0xFFFFF3E0),
            ),
            const SizedBox(height: 24),
            _buildGoalCard(
              context,
              title: 'Reflex Test',
              Testname:"Reflex",
              subtitle: 'First Attempt',
              i: 3,
              cardColor:const Color(0xFFFFEBEE),
            ),
            const SizedBox(height: 24),
            _buildGoalCard(
              context,
              title: 'Visual Memory Test',
              Testname:"Visual",
              subtitle: 'First Attempt',
              i: 4,
              cardColor: const Color(0xFFE8F5E9),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummary(String title, String current, String goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Current: $current',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text(
          'Goal: $goal' +'/3',
          style: TextStyle(
            fontSize: 14,
            color: (double.parse(current)) >= (double.parse(goal))
                ? Colors.green
                : Colors.blue,
          ),
        ),
      ],
    );
  }



  Widget _buildGoalCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required String Testname,
        required int i,
        required Color  cardColor,
      }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor ,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final updatedValues = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditGoalPage(
                    goalTitle: title,
                    Testname: Testname,
                    firstAttempt: goal_firstAttempt[i],
                    secondAttempt: goal_secondAttempt[i],
                    thirdAttempt: goal_thirdAttempt[i],
                    bestScore: goal_bestScore[i],
                    timesPerfectScore: goal_timesPerfectScore[i],
                    averageScore: goal_averageScore[i],
                 //   successRate: goal_successRate[i],
                  ),
                ),
              );

              if (updatedValues != null) {
                setState(() {
                  goal_firstAttempt[i] = updatedValues['firstAttempt'];
                  goal_secondAttempt[i] = updatedValues['secondAttempt'];
                  goal_thirdAttempt[i] = updatedValues['thirdAttempt'];
                  goal_bestScore[i] = updatedValues['bestScore'];
                  goal_timesPerfectScore[i] = updatedValues['timesPerfectScore'];
                  print('imesPerfectScore' + updatedValues['timesPerfectScore'].toString());
                  goal_averageScore[i] = updatedValues['averageScore'];
              //    goal_successRate[i] = updatedValues['successRate'];
                });
              }
            },
          ),

        ],
            ),
            _buildSummary('First Attempt', curr_firstAttempt[i].toString(), goal_firstAttempt[i].toString()),
            _buildSummary('Second Attempt', curr_secondAttempt[i].toString(), goal_secondAttempt[i].toString()),
            _buildSummary('Third Attempt', curr_thirdAttempt[i].toString(), goal_thirdAttempt[i].toString()),
            _buildSummary('Best Score', curr_bestScore[i].toString(), goal_bestScore[i].toString()),
            _buildSummary('Times Perfect Score', curr_timesPerfectScore[i].toString(), goal_timesPerfectScore[i].toString()),
            _buildSummary('Average Score', curr_averageScore[i].toString(), goal_averageScore[i].toString()),
       //     _buildSummary('Success Rate', curr_successRate[i].toString() + '%', goal_successRate[i].toString() + '%'),

          ],
        ),
      ),
    );
  }



}



/*
import 'package:flutter/material.dart';
import 'add_goal.dart';

import 'package:flutter/material.dart';

class PatientGoalsWidget extends StatefulWidget {
  const PatientGoalsWidget({super.key});

  @override
  State<PatientGoalsWidget> createState() => _PatientGoalsWidgetState();
}

class _PatientGoalsWidgetState extends State<PatientGoalsWidget> {
  double sliderValue1 = 85;
  double sliderValue2 = 90;
  double sliderValue3 = 95;
  double sliderValue4 = 80;
  double sliderValue5 = 85;
  double sliderValue6 = 90;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Test Goals',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildGoalCard(
                    context,
                    title: 'Auditory Memory Test',
                    attempts: [
                      _buildAttempt(
                        context,
                        title: 'First Attempt',
                        goal: '85%',
                        sliderValue: sliderValue1,
                        onChanged: (value) => setState(() => sliderValue1 = value),
                      ),
                      _buildAttempt(
                        context,
                        title: 'Second Attempt',
                        goal: '90%',
                        sliderValue: sliderValue2,
                        onChanged: (value) => setState(() => sliderValue2 = value),
                      ),
                      _buildAttempt(
                        context,
                        title: 'Third Attempt',
                        goal: '95%',
                        sliderValue: sliderValue3,
                        onChanged: (value) => setState(() => sliderValue3 = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGoalCard(
                    context,
                    title: 'Visual Memory Test',
                    attempts: [
                      _buildSummary(context, 'Best Score', '98/100', '100'),
                      _buildSummary(context, 'Times Perfect Score', '3', '5'),
                      _buildSummary(context, 'Average Score', '92.5', '95'),
                      _buildSummary(context, 'Success Rate', '88%', '95%'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGoalCard(
                    context,
                    title: 'Reading Text Test',
                    attempts: [
                      _buildAttempt(
                        context,
                        title: 'First Attempt',
                        goal: '80%',
                        sliderValue: sliderValue4,
                        onChanged: (value) => setState(() => sliderValue4 = value),
                      ),
                      _buildAttempt(
                        context,
                        title: 'Second Attempt',
                        goal: '85%',
                        sliderValue: sliderValue5,
                        onChanged: (value) => setState(() => sliderValue5 = value),
                      ),
                      _buildAttempt(
                        context,
                        title: 'Third Attempt',
                        goal: '90%',
                        sliderValue: sliderValue6,
                        onChanged: (value) => setState(() => sliderValue6 = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildGoalCard(
                    context,
                    title: 'Basic Math Test',
                    attempts: [
                      _buildSummary(context, 'Best Score', '95/100', '98'),
                      _buildSummary(context, 'Times Perfect Score', '2', '4'),
                      _buildSummary(context, 'Average Score', '90.5', '93'),
                      _buildSummary(context, 'Success Rate', '85%', '90%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, {required String title, required List<Widget> attempts}) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...attempts,
          ],
        ),
      ),
    );
  }

  Widget _buildAttempt(BuildContext context, {
    required String title,
    required String goal,
    required double sliderValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Goal: $goal',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Slider(
          value: sliderValue,
          min: 0,
          max: 100,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, String title, String current, String goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Current: $current',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text(
          'Goal: $goal',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
  void navigateAddGoalWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalWidget(),
      ),
    );
  }
}






 */