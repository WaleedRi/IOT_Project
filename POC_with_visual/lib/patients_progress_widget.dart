import 'package:flutter/material.dart';
import 'patients_progress_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tests_widget.dart';
import 'globals.dart';
import 'add_patient_widget.dart';
class PatientsProgressWidget extends StatefulWidget {
  //final String UID;
  const PatientsProgressWidget({super.key});

  @override
  State<PatientsProgressWidget> createState() => _PatientsProgressWidgetState();
}

class _PatientsProgressWidgetState extends State<PatientsProgressWidget> {
  late PatientsProgressModel _model;
  List<String> PateintsName = [];
  //late String UID;
  /*_PatientsProgressWidgetState(String UID) {
    this.UID=UID;
  }*/
  @override
  void initState() {
    super.initState();
    _model = PatientsProgressModel();
    _model.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      // Replace `patients` and `documentId` with your collection and document ID.
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(UID) // Replace with actual document ID
          .get();

      if (snapshot.exists) {
        setState(() {
          PateintsName = List<String>.from(snapshot.get('patients') ?? []);
          if(this.PateintsName.isEmpty){
            print('PateintsName.isEmpty');
          }
        });
      }
    } catch (e) {
      print('Error fetching tags: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rehabilitation Overview',
                style: Theme.of(context).textTheme.titleLarge ,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOverviewColumn('24', 'Active Patients'),
                  _buildOverviewColumn('78%', 'Avg Progress'),
                  _buildOverviewColumn('156', 'Tests Completed'),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Patient List',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              this.PateintsName.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                shrinkWrap: true, // Makes ListView adjust its height dynamically
                physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
                  itemCount: this.PateintsName.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(
                      name: this.PateintsName[index],
                     // progress: _model.sliderValue1,
                      lastTestDate: 'May 15, 2023',
                      onSliderChanged: (value) {
                         setState(() => _model.sliderValue1 = value);
                      },
                    );
                  },
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor, // Replace with your primary color
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    navigateAddPatientsWidget(); // Use Navigator for navigation
                  },
                ),
              ),
              /* _buildPatientCard(
                name: 'Sarah Johnson',
                progress: _model.sliderValue1,
                lastTestDate: 'May 15, 2023',
                onSliderChanged: (value) {
                  setState(() => _model.sliderValue1 = value);
                },
              ),
              _buildPatientCard(
                name: 'Michael Chen',
                progress: _model.sliderValue2,
                lastTestDate: 'May 14, 2023',
                onSliderChanged: (value) {
                  setState(() => _model.sliderValue2 = value);
                },
              ),
              _buildPatientCard(
                name: 'Emma Davis',
                progress: _model.sliderValue3,
                lastTestDate: 'May 12, 2023',
                onSliderChanged: (value) {
                  setState(() => _model.sliderValue3 = value);
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }
  void navigateToTestsWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsWidget(),
      ),
    );
  }

  void navigateAddPatientsWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPatientWidget(),
      ),
    );
  }
  Widget _buildOverviewColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildPatientCard({
    required String name,
 //   required double progress,
    required String lastTestDate,
    required ValueChanged<double> onSliderChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
           /* Row(
              children: [
                const Text('Progress:'),
                Expanded(
                  child: Slider(
                    value: progress,
                    min: 0.0,
                    max: 100.0,
                    onChanged: onSliderChanged,
                  ),
                ),
                Text('${progress.toInt()}%'),
              ],
            ),*/
            Text('Last Test: $lastTestDate'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                PatientName=name;
                navigateToTestsWidget();
                // Implement view details functionality
              },
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
