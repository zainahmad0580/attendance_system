import 'dart:async';
import 'package:attendance_system/student%20panel/student_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ndialog/ndialog.dart';
import 'package:flutter/material.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
DocumentSnapshot? userSnapshot;
final DateTime now = DateTime.now();
final DateFormat formatter = DateFormat('dd-MM-yyyy');
String date = formatter.format(now);
//String date = '06-03-2023';
List courses = ['mc', 'pf', 'cn', 'ispr', 'ap'];

//to check if today's date exists in the db
void checkDate() async {
  print('inside checkDate');
  late bool dateExists;
  for (var id in courses) {
    var doc = await firestore
        .collection('attendance')
        .doc(uid)
        .collection(id)
        .doc(date)
        .get();
    if (doc.exists) {
      dateExists = true;
      print('dateExists');
    } else {
      print('date does not Exists');
      dateExists = false;
      break;
    }
  }
  // if date does not exist, set attedance
  if (!dateExists) {
    print('setting attendance for today $date');
    setAttendance();
  }
}

//set attendance but not marked by student
void setAttendance() {
  for (var id in courses) {
    print('setting attendance of $id');
    firestore
        .collection('attendance')
        .doc(uid)
        .collection(id)
        .doc(date)
        .set({'value': 'P', 'isMarked': false});
  }
}

//Student has marked his attendance
void saveAttendance(List values) async {
  int i = 0;
  for (var id in courses) {
    String val = '';
    bool isPresent = values[i];
    if (isPresent) {
      val = 'P';
    } else {
      val = 'A';
    }
    await firestore
        .collection('attendance')
        .doc(uid)
        .collection(id)
        .doc(date)
        .update({'isMarked': true, 'value': val});
    var total = await firestore
        .collection('attendance')
        .doc(uid)
        .collection(id)
        .doc('total')
        .get();
    if (isPresent) {
      int count = total.data()?['P'];
      count++;
      await firestore
          .collection('attendance')
          .doc(uid)
          .collection(id)
          .doc('total')
          .update({'P': count});
    } else {
      int count = total.data()?['A'];
      count++;
      await firestore
          .collection('attendance')
          .doc(uid)
          .collection(id)
          .doc('total')
          .update({'A': count});
    }
    i++;
    print('$date $id $val');
  }
}

void reqLeave(String courseName, String courseID) async {
  userSnapshot = await firestore.collection('users').doc(uid).get();
  String photoID = userSnapshot?.get('photoID');
  String name = userSnapshot?.get('fullName');
  await firestore.collection('leaves').doc().set({
    'date': date,
    'courseID': courseID,
    'courseName': courseName,
    'userID': uid,
    'photoID': photoID,
    'userName': name
  });
}

bool leaveExists(
    QuerySnapshot<Map<String, dynamic>> leaveRef, String courseID) {
  for (var element in leaveRef.docs) {
    if (element.data().values.contains(date) &&
        element.data().values.contains(courseID)) {
      return true;
    }
  }
  return false;
}

//when the user registers first time
void setTotal(String newUserID) {
  print('setting total in all courses');
  for (var id in courses) {
    firestore
        .collection('attendance')
        .doc(newUserID)
        .collection(id)
        .doc('total')
        .set({'P': 0, 'A': 0, 'L': 0});
  }
}
