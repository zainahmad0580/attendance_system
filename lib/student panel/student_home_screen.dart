import 'package:attendance_system/student%20panel/profile_screen.dart';
import 'package:attendance_system/student%20panel/view_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'functions.dart';

String? uid;

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference? coursesRef;
  bool isMarked = false;
  List values = [
    true, //mc
    true, //pf
    true, //cn
    true, //ispr
    true //ap
  ]; //attendance values for check boxes
  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    print('USER ID: $uid');
    coursesRef = firestore.collection('courses');
    print('init state calling checkDate');
    checkDate();
    checkIfMarked();
  }

  //to check if user has marked today's attendance
  void checkIfMarked() async {
    print('inside check if marked');
    for (var id in courses) {
      var doc = await firestore
          .collection('attendance')
          .doc(uid)
          .collection(id)
          .doc(date)
          .get();
      if (doc.exists) {
        if (doc.get('isMarked')) {
          isMarked = true;
          break;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                toolbarHeight: 20,
                bottom: TabBar(indicatorWeight: 3, tabs: [
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(
                        Icons.app_registration_sharp,
                        color: Colors.white,
                      ),
                      Text('Attendance', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10)
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      Text('Profile', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10)
                    ],
                  )),
                ])),
            body: TabBarView(children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(children: [
                          Text(date),
                          const Expanded(child: SizedBox.shrink()),
                          const Text('Marked:'),
                          CircleAvatar(
                              backgroundColor: Colors.white,
                              child: isMarked
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : const Icon(Icons.close, color: Colors.red))
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen),
                                  onPressed: () async {
                                    if (isMarked) {
                                      Fluttertoast.showToast(
                                          msg:
                                              '''You have already marked today's attendance!''',
                                          backgroundColor: Colors.red);
                                    } else {
                                      try {
                                        saveAttendance(values);
                                        setState(() {
                                          isMarked = true;
                                        });
                                      } catch (e) {
                                        SnackBar(
                                          content: Text(e.toString()),
                                        );
                                      }

                                      Fluttertoast.showToast(
                                          msg: 'Attendance Saved Successfully!',
                                          backgroundColor: Colors.green);
                                    }
                                  },
                                  child: const Text('Save')),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ViewScreen()));
                                  },
                                  child: const Text('View')),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 2),
                  ElevatedButton(
                      onPressed: () {
                        print('Adding Task');
                        firestore.collection('tasks').doc().set({'date': date});
                        Fluttertoast.showToast(msg: 'Task added successfully');
                      },
                      child: Text('Add Record')),
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                    stream: coursesRef!.orderBy('index').snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            String courseID = snapshot.data!.docs[index]['id'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(10.0),
                                    padding: const EdgeInsets.all(5.0),
                                    width: screenWidth / 3,
                                    height: screenHeight / 4,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/mc.jpg'))),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data!.docs[index]['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(snapshot.data!.docs[index]
                                              ['code']),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            const Text('Present'),
                                            Checkbox(
                                                value: values[index],
                                                onChanged: ((value) async {
                                                  values[index] = value;

                                                  setState(() {});
                                                }))
                                          ]),
                                          Row(children: [
                                            const Text('Absent '),
                                            Checkbox(
                                                value: !values[index],
                                                onChanged: ((value) async {
                                                  values[index] = false;

                                                  setState(() {});
                                                }))
                                          ]),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.amber),
                                              onPressed: () async {
                                                if (isMarked) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          '''You have already marked today's attendance!''',
                                                      backgroundColor:
                                                          Colors.red);
                                                } else {
                                                  var leaveRef = await firestore
                                                      .collection('leaves')
                                                      .get();
                                                  if (leaveExists(
                                                      leaveRef, courseID)) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'You have already sent a leave request!',
                                                        backgroundColor:
                                                            Colors.red);
                                                  } else {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (ctx) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Confirmation'),
                                                            content: const Text(
                                                              'Are you sure to request for leave?',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .pop(
                                                                            ctx);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'No')),
                                                              TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    String
                                                                        courseName =
                                                                        snapshot
                                                                            .data!
                                                                            .docs[index]['name'];
                                                                    String
                                                                        courseID =
                                                                        snapshot
                                                                            .data!
                                                                            .docs[index]['id'];

                                                                    reqLeave(
                                                                      courseName,
                                                                      courseID,
                                                                    );

                                                                    // ignore: use_build_context_synchronously
                                                                    Navigator
                                                                        .pop(
                                                                            ctx);
                                                                    Fluttertoast.showToast(
                                                                        msg:
                                                                            'Request Sent!!',
                                                                        backgroundColor:
                                                                            Colors.green);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          'Yes'))
                                                            ],
                                                          );
                                                        });
                                                  }
                                                }
                                              },
                                              child: const Text('Leave'))
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
                  )),
                ],
              ),
              const ProfileScreen()
            ])));
  }
}
