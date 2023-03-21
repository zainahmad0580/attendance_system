import 'package:attendance_system/student%20panel/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();
  var _hideText1 = true;
  var _hideText2 = true;
  final List<String> _genders = ['Male', 'Female'];
  String _gender = 'Male';
  int _genderValue = 1;
  File? _imageFile;
  bool _showLocalFile = false;
  bool _photoUploaded = false;

  _pickImageFrom(ImageSource imageSource) async {
    XFile? _xFile = await ImagePicker().pickImage(source: imageSource);

    if (_xFile == null) return;

    final tempImage = File(_xFile.path);

    _imageFile = tempImage;
    _showLocalFile = true;
    _photoUploaded = true;
    setState(() {});

    // ignore: use_build_context_synchronously
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _showLocalFile
                                    ? FileImage(_imageFile!) as ImageProvider
                                    : const AssetImage(
                                        'assets/images/user.png')),
                          ),
                          Positioned(
                            right: 0,
                            left: 50,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  size: 30,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20)),
                                                onTap: () {
                                                  _pickImageFrom(
                                                      ImageSource.camera);
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                                onTap: () {
                                                  _pickImageFrom(
                                                      ImageSource.gallery);
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
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _nameController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return '*Field cannot be empty';
                            } else if (input.length > 30 || input.length < 3) {
                              return '*Name must be between 3-30 characters';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Full Name',
                              labelText: 'Full Name')),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _emailController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return '*Field cannot be empty';
                            } else if (input.length > 100) {
                              return '*Error! Too lengthy email';
                            } else if (!(input
                                .contains('@students.au.edu.pk'))) {
                              return '*Email must contain @students.au.edu.pk';
                            } else if (input.contains('admin')) {
                              return '*Invalid email address';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail),
                              hintText: 'Email',
                              labelText: 'Email')),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _rollNoController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return '*Field cannot be empty';
                            } else if (input.length != 6) {
                              return '*Roll number must be of length: 6';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 16),
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.app_registration),
                              hintText: 'Roll Number',
                              labelText: 'Roll Number')),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _phoneController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return '*Field cannot be empty';
                            } else if (input.length != 11 ||
                                input.contains('-')) {
                              return '*Length must be 11 digits';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              hintText: '03331111111',
                              labelText: 'Phone Number')),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Row(
                            children: [
                              Radio(
                                  value: 1,
                                  groupValue: _genderValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _genderValue = value as int;
                                      _gender = _genders[0];
                                    });
                                  }),
                              Text(_genders[0]),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                  value: 2,
                                  groupValue: _genderValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _genderValue = value as int;
                                      _gender = _genders[1];
                                    });
                                  }),
                              Text(_genders[1]),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                          obscureText: _hideText1,
                          controller: _passwordController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return '*Field cannot be empty';
                            } else if (input.length <= 5) {
                              return '*Weak-password, minimum length > 5';
                            } else if (input.length > 100) {
                              return '*Error! Too lengthy password';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    if (_hideText1 == true) {
                                      _hideText1 = false;
                                    } else {
                                      _hideText1 = true;
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.remove_red_eye)),
                              hintText: 'Password',
                              labelText: 'Password')),
                      const SizedBox(height: 20),
                      TextFormField(
                          obscureText: _hideText2,
                          controller: _confirmPassController,
                          validator: (input) {
                            if (input == null || input.isEmpty) {
                              return 'Field cannot be empty';
                            } else if (input.length <= 5) {
                              return '*Weak-password, minimum length > 5';
                            } else if (input.length > 100) {
                              return '*Error! Too lengthy password';
                            } else {
                              return null;
                            }
                          },
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    if (_hideText2 == true) {
                                      _hideText2 = false;
                                    } else {
                                      _hideText2 = true;
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.remove_red_eye)),
                              hintText: 'Confirm Password',
                              labelText: 'Confirm Password')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          //if no error in form validation
                          if (_formKey.currentState!.validate()) {
                            String fullName = _nameController.text.trim();
                            String email = _emailController.text.trim();
                            String rollNo = _rollNoController.text.trim();
                            String phoneNo = _phoneController.text.trim();
                            String password = _passwordController.text.trim();
                            String confirmPass =
                                _confirmPassController.text.trim();
                            String validateEmail =
                                email.substring(0, 6); //stores roll no

                            if (password != confirmPass) {
                              Fluttertoast.showToast(
                                  msg: 'Passwords do not match',
                                  backgroundColor: Colors.red);
                            }
                            //roll number & email id must be same
                            else if (validateEmail != rollNo) {
                              Fluttertoast.showToast(
                                  msg: 'Email & rollNo do not match',
                                  backgroundColor: Colors.red);
                            } else if (_photoUploaded == false) {
                              Fluttertoast.showToast(
                                  msg: 'Upload a picture to proceed',
                                  backgroundColor: Colors.red);
                            } else {
                              //To close the keyboard
                              FocusManager.instance.primaryFocus?.unfocus();

                              ProgressDialog progressDialog = ProgressDialog(
                                  context,
                                  title: const Text('Please wait'),
                                  message: const Text(''));
                              try {
                                // ignore: use_build_context_synchronously

                                progressDialog.show();

                                var fileName = '$rollNo.jpg';

                                UploadTask uploadTask = FirebaseStorage.instance
                                    .ref()
                                    .child('profile_images')
                                    .child(fileName)
                                    .putFile(_imageFile!);

                                TaskSnapshot snapshot = await uploadTask;

                                String profileImageUrl =
                                    await snapshot.ref.getDownloadURL();
                                //save to user to firebase authentication
                                FirebaseAuth auth = FirebaseAuth.instance;
                                //creating user, if exception caught, user will not be created
                                UserCredential userCredentials =
                                    await auth.createUserWithEmailAndPassword(
                                        email: email, password: password);

                                //now store user information in firestore database
                                FirebaseFirestore firestore =
                                    FirebaseFirestore.instance;

                                String uid = userCredentials.user!.uid;
                                int dt = DateTime.now()
                                    .millisecondsSinceEpoch; //to get the time when user was registered

                                await firestore
                                    .collection('users')
                                    .doc(uid)
                                    .set({
                                  'uid': uid,
                                  'photoID': profileImageUrl,
                                  'fullName': fullName,
                                  'email': email,
                                  'rollNo': rollNo,
                                  'phoneNo': phoneNo,
                                  'gender': _gender,
                                  'dt': dt,
                                });
                                //to keep count of attendance of user
                                setTotal(uid);
                                progressDialog.dismiss();
                                Fluttertoast.showToast(
                                    msg: 'Sign up successful!',
                                    backgroundColor: Colors.green);
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'email-already-in-use') {
                                  Fluttertoast.showToast(
                                      msg: 'Email already in use');
                                } else if (e.code == 'invalid-email') {
                                  progressDialog.dismiss;
                                  Fluttertoast.showToast(msg: 'Invalid Email');
                                } else if (e.code == 'operation-not-allowed') {
                                  progressDialog.dismiss;
                                  Fluttertoast.showToast(
                                      msg: 'Operation not allowed');
                                } else if (e.code == 'weak-password') {
                                  progressDialog.dismiss;
                                  Fluttertoast.showToast(
                                      msg:
                                          'Weak Password. Password length must be greather than 6');
                                } else {
                                  progressDialog.dismiss;
                                  Fluttertoast.showToast(msg: '${e.code}');
                                }
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: 'Something went wrong');
                              }
                              progressDialog.dismiss();
                            }
                          }
                        },
                        child: const FittedBox(
                          //fit: BoxFit.cover,
                          child: Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
