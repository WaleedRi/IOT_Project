import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:start_esp_from_app/auth3_login_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wifi_setup_screen.dart';
import 'edit_patient_widget.dart';

import 'tests_widget.dart';
import 'globals.dart';
import 'add_patient_widget.dart';

class PatientsProgressWidget extends StatefulWidget {
  const PatientsProgressWidget({Key? key}) : super(key: key);

  @override
  State<PatientsProgressWidget> createState() => _PatientsProgressWidgetState();
}

class _PatientsProgressWidgetState extends State<PatientsProgressWidget> {
  double sliderValue1 = 75;
  double sliderValue2 = 45;
  double sliderValue3 = 60;
  List<String> PateintsName = [];
  List<String> filteredPatients = [];
  List<String> PateintsNameAndId = [];
  List<String> PateintsID = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    navigateLoginWidget();
    print('User logged out');
  }

  void navigateToTestsWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsWidget(),
      ),
    );
  }
  void navigateLoginWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Auth3LoginWidget(),
      ),
    );
  }
  void navigateToWifiSetUpWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WiFiSetupScreen(),
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
  Future<void> navigateToEditPatient(String id) async {
    await fetchPatientdetalis(id); // Wait for details to be fetched
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPatientWidget(
          patientId: id,
          patientName: PatientName,
          age: age, // Use the fetched age
          phoneNumber: phoneNumber, // Use the fetched phone number
          gender: Patientgender, // Use the fetched gender
          symptoms: symptoms, // Use the fetched symptoms
        ),
      ),
    );
  }

  Future<void> fetchPatientdetalis(String id) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .doc(id)
          .get();

      if (snapshot.exists) {
        age =snapshot.get('age');
        phoneNumber =snapshot.get('phone_number');
        Patientgender =snapshot.get('Gender');
        symptoms =snapshot.get('symptoms');
        PatientName = snapshot.get('full_name');
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }
  Future<void> fetchPatients() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(UID)
          .get();

      if (snapshot.exists) {
        DoctorName =snapshot.get('Name');

        setState(() {
          PateintsNameAndId = List<String>.from(snapshot.get('patients') ?? []);
          PateintsName = [];
          PateintsID = [];
          for (int i = 0; i < PateintsNameAndId.length; i++) {
            List<String> parts = PateintsNameAndId[i].split('+');
            PateintsName.add(parts[0].trim());
            PateintsID.add(parts[1].trim());
          }
          filteredPatients = PateintsNameAndId;
        });
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
  }

  void filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPatients = PateintsNameAndId;
      } else {
        filteredPatients = PateintsNameAndId.where((patient) {
          List<String> parts = patient.split('+');
          String name = parts[0].trim().toLowerCase();
          String id = parts[1].trim().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              id.contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      navigateToWifiSetUpWidget();
                    },
                    child: const Text('set ESP wifi'),
                  ),
                ),
               /* IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),*/
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: PatientSearchDelegate(
                            PateintsNameAndId: PateintsNameAndId,
                            onSearch: filterPatients,
                          ),
                        );
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement logout functionality
                        logout();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Patient Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Track and manage rehabilitation progress',
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
        color: Color(0xFFF7F8FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildOverview(context),
            const SizedBox(height: 16),
            const Text(
              'Patient List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            this.PateintsNameAndId.isEmpty
                ?   Center(
              child: Text(
              'No patients available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
             )
      //const Center(child: CircularProgressIndicator())
                : ListView.builder(
              shrinkWrap: true, // Makes ListView adjust its height dynamically
              physics: const NeverScrollableScrollPhysics(), // Disables inner scrolling
              itemCount: this.filteredPatients.length,
              itemBuilder: (context, index) {
                List<String> parts = filteredPatients[index].split('+');
                String name = parts[0].trim();
                String id = parts[1].trim();
                return _buildPatientCard(
                  context,
                  imageUrl:
                  'https://images.unsplash.com/photo-1576765608075-5875c74feac7?w=500&h=500',
                  name: name,
                  id: id,
                  //  progress: sliderValue1,
                  //  lastTestDate: 'May 15, 2023',
                  //  onProgressChanged: (value) => setState(() => sliderValue1 = value),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: FloatingActionButton(
                onPressed: () {
                  navigateAddPatientsWidget(); // Use Navigator for navigation
                  print('Add patient button pressed');
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOverviewColumn(context,this.PateintsNameAndId.length.toString(), 'Active Patients'),
            _buildOverviewColumn(context, '78%', 'Avg Progress'),
            _buildOverviewColumn(context, '156', 'Tests Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPatientCard(
      BuildContext context, {
        required String imageUrl,
        required String name,
        required String id,
        //   required double progress,
        //   required String lastTestDate,
        //  required ValueChanged<double> onProgressChanged,
      }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: '+name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Id: ' + id,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      PatientName = name;
                      PatientId = id;
                      navigateToTestsWidget();
                    },
                    child: const Text('View Details'),
                  ),
                  /*const SizedBox(height: 8),
                  Text(
                    'Progress: ${progress.toInt()}%',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Slider(
                    value: progress,
                    min: 0,
                    max: 100,
                    onChanged: onProgressChanged,
                  ),*/
                  /* Text(
                    'Last Test: $lastTestDate',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),*/
                ],
              ),
            ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              navigateToEditPatient(id);
            } else if (value == 'delete') {
              print('Delete option selected for $id');
              deletePatient(id);
              deletePatientFromArray(id, name);
              fetchPatients(); // Refresh the patient list
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          icon: const Icon(Icons.more_vert), // Icon for the menu
         ),
          ],
        ),
      ),
    );
  }

  Future<void> deletePatientFromArray(String documentId, String patientName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(UID).update({
        'patients': FieldValue.arrayRemove([patientName.trim() + ' + ' + documentId.trim()]),
      });
      print('Patient $patientName removed from array in document $documentId');
      /* print(patientName.trim() + ' + ' + documentId.trim());
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(UID).get();
      print(snapshot.get('patients'));*/
      /*  print(formattedString.codeUnits);
      print(snapshot.get('patients')[index].codeUnits); // Compare with the stored string*/

    } catch (e) {
      print('Error removing patient from array: $e');
    }
  }
  Future<void> deleteCollection(String collectionPath, int batchSize) async {
    try {
      // Reference to the collection
      final collectionRef = FirebaseFirestore.instance.collection(collectionPath);

      // Get a batch of documents
      QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();

      // Delete documents in the batch
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot document in snapshot.docs) {
        batch.delete(document.reference);
      }

      // Commit the batch
      await batch.commit();

      // If there are more documents, recursively delete the next batch
      if (snapshot.docs.isNotEmpty) {
        await deleteCollection(collectionPath, batchSize);
      } else {
        print('Collection $collectionPath deleted successfully');
      }
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }

  Future<void> deletePatient(String documentId) async {
    try {
      deleteCollection('patients/$documentId/results', 10);
      await FirebaseFirestore.instance.collection('patients').doc(documentId).delete();
      print('Document $documentId deleted successfully');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

}



class PatientSearchDelegate extends SearchDelegate {
  final List<String> PateintsNameAndId;
  final Function(String) onSearch;

  PatientSearchDelegate({
    required this.PateintsNameAndId,
    required this.onSearch,
  });


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = PateintsNameAndId.where((patient) {
      List<String> parts = patient.split('+');
      String name = parts[0].trim().toLowerCase();
      String id = parts[1].trim().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        List<String> parts = suggestions[index].split('+');
        String name = parts[0].trim();
        String id = parts[1].trim();
        return ListTile(
          title: Text(name),
          subtitle: Text(id),
          onTap: () {
            query = name;
            close(context, null);
            onSearch(name);
          },
        );
      },
    );
  }
}
