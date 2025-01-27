import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:start_esp_from_app/auth3_login_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wifi_setup_screen.dart';
import 'edit_patient_widget.dart';

import 'tests_widget.dart';
import 'globals.dart';
import 'add_patient_widget.dart';

class SingleTestResultWidget extends StatefulWidget {
  final String firstAttempt;
  final String secondAttempt;
  final String thirdAttempt;
  final String bestScore;
  final String timesPerfectScore;
  final String averageScore;
  final String successRate;

  const SingleTestResultWidget({
    super.key,
    required this.firstAttempt,
    required this.secondAttempt,
    required this.thirdAttempt,
    required this.bestScore,
    required this.timesPerfectScore,
    required this.averageScore,
    required this.successRate,
  });

  @override
  State<SingleTestResultWidget> createState() => _SingleTestResultWidgetState();
}

class _SingleTestResultWidgetState extends State<SingleTestResultWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {
    super.initState();
    //fetchTest();
  }

@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous page
              print('Back button pressed');
            },
          ),
          title: Text(
            'Test Results',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Inter Tight',
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildPerformanceCard(context),
                  const SizedBox(height: 24),
                  _buildTestHistoryCard(context),
                  const SizedBox(height: 24),
                  _buildProgressOverviewCard(context),
                  const SizedBox(height: 24),
                  _buildTryAgainButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Your Performance',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter Tight',
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Best Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).hintColor,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.bestScore,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/5',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    letterSpacing: 0.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Perfect Scores: ' + widget.timesPerfectScore + ' times',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestHistoryCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Test History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter Tight',
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16),
            _buildTestHistoryItem(context, 'First Attempt', 'June 15, 2023', widget.firstAttempt),
            const SizedBox(height: 16),
            _buildTestHistoryItem(context, 'Second Attempt', 'June 16, 2023', widget.secondAttempt),
            const SizedBox(height: 16),
            _buildTestHistoryItem(context, 'Third Attempt', 'June 17, 2023', widget.thirdAttempt),
          ],
        ),
      ),
    );
  }

  Widget _buildTestHistoryItem(
      BuildContext context, String title, String date, String score) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Inter Tight',
                  letterSpacing: 0.0,
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                score,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/5',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverviewCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'Progress Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Inter Tight',
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Inter Tight',
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      widget.averageScore +'/5',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Rate',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Inter Tight',
                        letterSpacing: 0.0,
                      ),
                    ),
                    Text(
                      (widget.successRate),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryAgainButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print('Try Again button pressed');
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: Theme.of(context).primaryColor, // Updated parameter
      ),
      child: Text(
        'Try Again',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontFamily: 'Inter Tight',
          letterSpacing: 0.0,
        ),
      ),
    );
  }

}
