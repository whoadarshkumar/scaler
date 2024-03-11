import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evaluation_dashboard/models/student_model.dart';
import 'package:evaluation_dashboard/models/mentor_model.dart';

class EvaluationDashboardApp extends StatelessWidget {
  const EvaluationDashboardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentors Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const EvaluationDashboardPage(),
    );
  }
}

class EvaluationDashboardPage extends StatefulWidget {
  const EvaluationDashboardPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EvaluationDashboardPageState createState() =>
      _EvaluationDashboardPageState();
}

class _EvaluationDashboardPageState extends State<EvaluationDashboardPage> {
  List<Student> studentsAssign = [];
  List<Student> allStudents = [];
  List<Mentor> mentors = [];
  Mentor? selectedMentor;
  Student? selectedStudent;
  bool isDisabled = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchMentorsFromFirebase();
    fetchUnassignedStudentsFromFirebase();
  }

  Future<void> fetchMentorsFromFirebase() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('mentors').get();
    mentors = querySnapshot.docs.map((doc) {
      List<String> studentsAssign = List<String>.from(doc['studentsAssign']);
      return Mentor(
        name: doc['name'],
        uid: doc['uid'],
        studentsAssign: studentsAssign,
      );
    }).toList();
    setState(() {
      selectedMentor = mentors.isNotEmpty ? mentors[0] : null;
    });
  }

  Future<void> fetchUnassignedStudentsFromFirebase() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('students').get();
    allStudents = querySnapshot.docs.map((doc) {
      return Student(
        name: doc['name'],
        uid: doc['uid'],
        ideation: doc['ideation'],
        execution: doc['execution'],
        viva: doc['viva'],
        isAssigned: doc['isAssigned'],
      );
    }).toList();

    studentsAssign =
        allStudents.where((element) => element.isAssigned == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mentors Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Mentors",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: GestureDetector(
                onTap: () {
                  // Open a dialog or navigate to a new screen for mentor selection
                  // Add your logic here
                },
                child: Center(
                  child: Column(
                    children: mentors.map((mentor) {
                      return ListTile(
                        title: Center(
                          child: Text(
                            mentor.name,
                            style: TextStyle(
                              color: selectedMentor == mentor
                                  ? Colors.grey[700]
                                  : Colors.black,
                              fontWeight: selectedMentor == mentor
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selectedMentor = mentor;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Unassigned Students",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: studentsAssign.length,
                itemBuilder: (context, index) {
                  Student student = studentsAssign[index];
                  bool isSelected = selectedStudent == student;

                  return ListTile(
                    title: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[200] : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Center(
                        child: Text(
                          student.name,
                          style: TextStyle(
                            color: isSelected ? Colors.grey[700] : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedStudent = student;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudent != null && selectedMentor != null) {
                  if (selectedMentor!.studentsAssign.length < 4) {
                    // Update the Firestore documents
                    log(selectedStudent!.uid);
                    await updateFirestore(
                        selectedStudent!.uid, selectedMentor!.uid);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Mentor can only have a maximum of 4 students.',
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
              ),
              child: const Text(
                'Assign Students to this Mentor',
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: selectedMentor?.studentsAssign.length ?? 0,
              itemBuilder: (context, index) {
                String id = selectedMentor!.studentsAssign[index];
                Student s =
                    allStudents.firstWhere((element) => element.uid == id);
                TextEditingController executionController =
                    TextEditingController(text: s.ideation);
                TextEditingController ideationController =
                    TextEditingController(text: s.execution);
                TextEditingController vivaController =
                    TextEditingController(text: s.viva);

                // print(s);
                return Card(
                  elevation: 10,
                  child: ListTile(
                    title: Center(
                        child: Text(s.name,
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    subtitle: Center(child: Text('Marks not assigned')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_attributes_rounded),
                          onPressed: () async {
                            // Open a dialog or navigate to a new screen for editing marks
                            showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // Dialog cannot be dismissed by tapping outside
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Edit Marks'),
                                  content: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          TextFormField(
                                            enabled: isDisabled,
                                            validator: (value) {
                                              if (value == "") {
                                                return "Please enter a value";
                                              }
                                              return null;
                                            },
                                            controller: executionController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                labelText: 'Execution Marks'),
                                          ),
                                          TextFormField(
                                            enabled: isDisabled,
                                            validator: (value) {
                                              if (value == "") {
                                                return "Please enter a value";
                                              }
                                              return null;
                                            },
                                            controller: ideationController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                labelText: 'Ideation Marks'),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == "") {
                                                return "Please enter a value";
                                              }
                                              return null;
                                            },
                                            controller: vivaController,
                                            enabled: isDisabled,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                labelText: 'Viva Marks'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  actions: !isDisabled
                                      ? [
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  isDisabled = false;
                                                });
                                              },
                                              icon: const Icon(Icons.lock))
                                        ]
                                      : [
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Save'),
                                            onPressed: () async {
                                              if (!(_formKey.currentState!
                                                  .validate())) {
                                                return;
                                              }
                                              await FirebaseFirestore.instance
                                                  .collection('students')
                                                  .doc(s.uid)
                                                  .update({
                                                'viva': vivaController.text,
                                                'execution':
                                                    executionController.text,
                                                'ideation':
                                                    ideationController.text
                                              });
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                              }
                                            },
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  isDisabled = false;
                                                });
                                              },
                                              icon: const Icon(Icons.lock))
                                        ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_outlined),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('students')
                                .doc(s.uid)
                                .update({'isAssigned': false});
                            await FirebaseFirestore.instance
                                .collection('mentors')
                                .doc(selectedMentor!.uid)
                                .update({
                              'studentsAssign': FieldValue.arrayRemove([s.uid]),
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateStudentMarksInFirestore(
      String Name, int execution, int ideation, int viva) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(Name).update({
        'execution': execution,
        'ideation': ideation,
        'viva': viva,
      });
    } catch (error) {
      // print('Error updating student marks: $error');
      // Handle error
    }
  }

  Future<void> fetchStudentMarksFromFirestore(String studentId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .get();

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          selectedStudent!.execution = data['execution'] ?? 0;
          selectedStudent!.ideation = data['ideation'] ?? 0;
          selectedStudent!.viva = data['viva'] ?? 0;
        });
      } else {
        // print('No data found for student with ID: $studentId');
      }
    } catch (error) {
      // print('Error fetching student marks: $error');
      // Handle error
    }
  }

  Future<void> updateFirestore(String studentId, String mentorId) async {
    try {
      // Remove the student from the unassigned students list in Firestore
      await FirebaseFirestore.instance
          .collection('students')
          .doc(studentId)
          .update({
        "isAssigned": true,
      });

      // Add the student to the mentor's assigned students list in Firestore
      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(mentorId)
          .update({
        'studentsAssign': FieldValue.arrayUnion([studentId]),
      });
    } catch (error) {
      // print('Error updating Firestore: $error');
      // Handle the error here, e.g., show a snackbar or display an error message
    }
  }
}
