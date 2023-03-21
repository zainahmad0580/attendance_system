import 'package:attendance_system/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../admin panel/admin_home_screen.dart';
import '../student panel/student_home_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var hideText = true;

  Future<void> _setAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isAdmin', true);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg.png'), fit: BoxFit.fill)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/user.png'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: screenWidth / 1.2,
                    child: const FittedBox(
                        child: Text('Student Attendance System',
                            style: TextStyle(color: Colors.white)))),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 40,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                                textInputAction: TextInputAction.next,
                                controller: emailController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.mail),
                                    hintText: 'Email',
                                    labelText: 'Email')),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                                textInputAction: TextInputAction.done,
                                controller: passwordController,
                                obscureText: hideText,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                      onPressed: () {
                                        if (hideText == true) {
                                          hideText = false;
                                        } else {
                                          hideText = true;
                                        }
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.remove_red_eye)),
                                  hintText: 'Password',
                                  labelText: 'Password',
                                )),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                String email = emailController.text.trim();
                                String password =
                                    passwordController.text.trim();

                                //Check if fields are empty
                                if (email.isEmpty || password.isEmpty) {
                                  //toast
                                  Fluttertoast.showToast(
                                      msg: 'PLEASE FILL ALL THE FIELDS',
                                      backgroundColor: Colors.red);
                                } else {
                                  //Remove keyboard
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  //Show progress dialog due to processing
                                  ProgressDialog progressDialog =
                                      ProgressDialog(context,
                                          title: const Text('Please wait'),
                                          message: const Text('Signing In'));

                                  progressDialog.show();

                                  //Validating input
                                  try {
                                    //Authenticate from firebase
                                    FirebaseAuth auth = FirebaseAuth
                                        .instance; //firebase instance
                                    UserCredential userCredentials =
                                        await auth.signInWithEmailAndPassword(
                                            email: email, password: password);

                                    //If credentials match
                                    if (userCredentials.user != null) {
                                      if (email.contains('admin')) {
                                        _setAdmin();
                                        progressDialog.dismiss();
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushReplacement(PageTransition(
                                          type: PageTransitionType.fade,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: const AdminHomeScreen(),
                                        ));
                                      } else {
                                        progressDialog.dismiss();
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pushReplacement(PageTransition(
                                          type: PageTransitionType.fade,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: const StudentHomeScreen(),
                                        ));
                                      }
                                    }
                                    //else Exception caught
                                  } on FirebaseAuthException catch (e) {
                                    progressDialog.dismiss(); //dismiss dialog

                                    if (e.code == 'user-not-found') {
                                      Fluttertoast.showToast(
                                          msg: 'User not found');
                                    } else if (e.code == 'wrong-password') {
                                      Fluttertoast.showToast(
                                          msg: 'Wrong password');
                                    } else if (e.code == 'invalid-email') {
                                      Fluttertoast.showToast(
                                          msg: 'Invalid email');
                                    } else {
                                      Fluttertoast.showToast(msg: e.code);
                                    }
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: 'Something went wrong');
                                    progressDialog.dismiss();
                                  }
                                } //ends else
                              },
                              child: const Text('Sign In'),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Dont have an account?'),
                                    TextButton(
                                      onPressed: () {
                                        //To close the keyboard
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        Navigator.of(context)
                                            .push(PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          reverseDuration:
                                              const Duration(milliseconds: 500),
                                          child: const RegistrationScreen(),
                                        ));
                                      },
                                      child: const Text(
                                        'Sign Up!',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
