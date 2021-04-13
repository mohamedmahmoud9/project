import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_database.dart';
import '../models/user.dart';
import 'package:location/location.dart';

import '../main.dart';

class UnCompleteProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final bool isEdit;
  final FirebaseAuth firbaseAuth;
  UnCompleteProfileScreen({
    Key key,
    this.userModel,
    this.firbaseAuth,
    this.isEdit,
  }) : super(key: key);

  @override
  _UnCompleteProfileScreenState createState() =>
      _UnCompleteProfileScreenState();
}

class _UnCompleteProfileScreenState extends State<UnCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  TextEditingController firstName = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController lastName = TextEditingController();
  String gender;
  PickedFile pickedFile;
  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      firstName.text = widget.userModel.firstname;
      phonenumber.text = widget.userModel.phonenumber;
      lastName.text = widget.userModel.lastname;
      gender = widget.userModel.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text(widget.isEdit
            ? 'Update You inforamtion'
            : 'Complete your information'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: pickedFile != null
                      ? FileImage(File(pickedFile.path))
                      : NetworkImage(widget.userModel.profilePic),
                  maxRadius: 80,
                  child: IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      pickedFile = await imagePicker.getImage(
                          source: ImageSource.gallery);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      // size: 50,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: firstName,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'required*';
                    }
                    return null;
                  },
                  decoration: InputDecoration(hintText: 'First Name'),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: lastName,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'required*';
                    }
                    return null;
                  },
                  decoration: InputDecoration(hintText: 'Last Name'),
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(10)],
                  controller: phonenumber,
                  validator: (value) {
                    String controller = null;
                    if (value.isEmpty) {
                      return 'required*';
                    }
                    if (phonenumber.text.length !=10) {

                      return 'invalid number*';
                    }
                    FirestoreDatabase().getAllUsers().forEach((element) {element.forEach((element)  {
                      print(phonenumber.text==element.phonenumber);

                    });});
                    return null;
                  },
                  decoration: InputDecoration(hintText: 'Phone Number',),
                ),
                SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField(
                    validator: (value) {
                      if (value == null) {
                        return 'required*';
                      }
                      return null;
                    },
                    decoration: InputDecoration(hintText: 'Gender'),
                    value: gender,
                    items: List.generate(
                        2,
                            (index) => DropdownMenuItem(
                          child: Text(index == 0 ? 'Male' : 'Female'),
                          value: index == 0 ? 'Male' : 'Female',
                        )),
                    onChanged: (value) {
                      gender = value;
                    }),
                SizedBox(
                  height: 16,
                ),

                isLoading
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : RaisedButton(
                  onPressed: () async {
                    try {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }

                      bool _serviceEnabled;

                      final Location location = Location();
                      PermissionStatus _permissionGranted;
                      _serviceEnabled = await location.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled = await location.requestService();
                        if (!_serviceEnabled) {
                          return;
                        }
                      }
                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted =
                        await location.requestPermission();
                        if (_permissionGranted !=
                            PermissionStatus.granted) {
                          return;
                        }
                      }
                      setState(() {
                        isLoading = true;
                      });
                      final userLocaion = await location.getLocation();
                      await FirestoreDatabase().addUserToFirestore(
                          UserModel(
                            uid: widget.firbaseAuth.currentUser.uid,
                            email: widget.userModel.email,
                            gender: gender,
                            status: '1',
                            phonenumber: phonenumber.text,
                            firstname: firstName.text.trim(),
                            lastname: lastName.text.trim(),
                            profilePic: widget.userModel.profilePic,
                            isCompleted: true,
                            posts: widget.isEdit ? widget.userModel.posts : [],
                            following:
                            widget.isEdit ? widget.userModel.following : [],
                            locationLatLng: GeoPoint(
                                userLocaion.latitude, userLocaion.longitude),
                          ),
                          pickedFile);
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => MyApp()));
                    } on FirebaseException catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      _scaffoldkey.currentState.showSnackBar(
                          SnackBar(content: Text(e.message)));
                    }
                  },
                  child: Text('Submit'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
