import 'package:attendance_system/admin%20panel/leave_screen.dart';
import 'package:attendance_system/screens/log_in_screen.dart';
import 'package:attendance_system/student%20panel/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? uid;

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  CollectionReference? usersRef;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    usersRef = firestore.collection('users');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                foregroundColor: Colors.white,
                title: const Text('Admin Panel'),
                actions: [
                  IconButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isAdmin', false);
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogInScreen(),
                          ));
                    },
                    icon: Icon(Icons.login),
                  )
                ],
                bottom: TabBar(indicatorWeight: 3, tabs: [
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(
                        Icons.people,
                        color: Colors.white,
                      ),
                      Text('Students', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10)
                    ],
                  )),
                  Tab(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(
                        Icons.bookmarks_sharp,
                        color: Colors.white,
                      ),
                      Text('Leaves', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 10)
                    ],
                  )),
                ])),
            body: TabBarView(children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: usersRef!.orderBy('rollNo').snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        int count = 0; //to count number of students
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data!.docs[index]['uid'] == uid) {
                              return const SizedBox.shrink();
                            }
                            count++;
                            return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                      leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(snapshot
                                              .data!.docs[index]['photoID'])),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '$count. ${snapshot.data!.docs[index]['fullName']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(snapshot.data!.docs[index]
                                              ['rollNo'])
                                        ],
                                      )),
                                ));
                          },
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })),
              ),
              const LeaveScreen()
            ])));
  }
}
