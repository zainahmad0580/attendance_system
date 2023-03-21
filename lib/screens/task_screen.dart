import 'package:attendance_system/student%20panel/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TaskScreen extends StatelessWidget {
  TaskScreen({super.key});
  final CollectionReference? tasksRef = firestore.collection('tasks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  print('Adding Task');
                  firestore.collection('tasks').doc().set({'date': date});
                  Fluttertoast.showToast(msg: 'Task added successfully');
                },
                child: Text('Add Record')),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: tasksRef!.snapshots(),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onDoubleTap: () {
                                  tasksRef!
                                      .doc(snapshot.data!.docs[index].id)
                                      .delete();
                                },
                                child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    elevation: 20,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Text('$index. ' +
                                        snapshot.data!.docs[index]['date'])),
                              );
                            });
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })))
          ],
        ));
  }
}
