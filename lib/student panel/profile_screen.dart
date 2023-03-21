import 'dart:io';
import 'package:attendance_system/student%20panel/student_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/log_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot? userSnapshot;

  void getUser() async {
    userSnapshot = await firestore.collection('users').doc(uid).get();
    setState(() {});
  }

  File? imageFile;
  bool showLocalFile = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  _pickImageFrom(ImageSource imageSource) async {
    XFile? xFile = await ImagePicker().pickImage(source: imageSource);

    if (xFile == null) return;

    final tempImage = File(xFile.path);

    imageFile = tempImage;
    showLocalFile = true;
    setState(() {});

    // upload to firebase storage

    // ignore: use_build_context_synchronously
    ProgressDialog progressDialog = ProgressDialog(
      context,
      title: const Text('Uploading !!!'),
      message: const Text('Please wait'),
    );
    progressDialog.show();
    try {
      var fileName = userSnapshot!['email'] + '.jpg';

      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName)
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      String profileImageUrl = await snapshot.ref.getDownloadURL();

      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'profileImage': profileImageUrl});

      Fluttertoast.showToast(msg: 'Profile image uploaded');

      print(profileImageUrl);

      progressDialog.dismiss();
    } catch (e) {
      progressDialog.dismiss();

      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Column(children: [
      Container(
        width: double.infinity,
        height: screenHeight / 4,
        padding: const EdgeInsets.all(20.0),
        color: Colors.lightBlue,
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white, fontSize: 20),
          child: FittedBox(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                      radius: 30,
                      backgroundImage: showLocalFile
                          ? FileImage(imageFile!) as ImageProvider
                          : NetworkImage(userSnapshot!['photoID'])),
                ),
                Positioned(
                  right: 0,
                  left: 30,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 20,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.lightBlue,
                                      ),
                                      leading: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.lightBlue,
                                      ),
                                      title: const Text('From Camera',
                                          style: TextStyle(
                                              color: Colors.lightBlue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      onTap: () {
                                        _pickImageFrom(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.lightBlue,
                                    ),
                                    ListTile(
                                      trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.lightBlue),
                                      leading: const Icon(Icons.image,
                                          color: Colors.lightBlue),
                                      title: const Text(
                                        'From Gallery',
                                        style: TextStyle(
                                            color: Colors.lightBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      onTap: () {
                                        _pickImageFrom(ImageSource.gallery);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(children: [
          ListTile(
              leading: const Icon(Icons.person),
              title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text('${userSnapshot!['fullName']}'))),
          ListTile(
              leading: const Icon(Icons.numbers),
              title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text('${userSnapshot!['rollNo']}'))),
          ListTile(
              leading: const Icon(Icons.accessibility),
              title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text('${userSnapshot!['gender']}'))),
          ListTile(
              leading: const Icon(Icons.mail),
              title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text('${userSnapshot!['email']}'))),
          ListTile(
              leading: const Icon(Icons.call),
              title: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(userSnapshot!['phoneNo']))),
        ]),
      )),
      ListTile(
        trailing: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () async {
          FirebaseAuth.instance.signOut();
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isAdmin', false);
          uid = '';
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LogInScreen(),
              ));
        },
      ),
    ]));
  }
}
