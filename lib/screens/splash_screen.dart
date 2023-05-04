import 'dart:async';
import 'package:attendance_system/student%20panel/student_home_screen.dart';
import 'package:attendance_system/student%20panel/view_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin panel/admin_home_screen.dart';
import 'log_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isAdmin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  void getUser() {
    FirebaseAuth.instance.currentUser?.uid == null
        ? Future.delayed(const Duration(seconds: 3), () {
            // 5s over, navigate to a new page
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LogInScreen()));
          })
        : _isAdmin();
  }

  Future<void> _isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isAdmin = (prefs.getBool('isAdmin') ?? false);
    });

    if (isAdmin) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminHomeScreen(),
          ));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentHomeScreen(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: Image.asset('assets/images/splash.jpg')));
  }
}
