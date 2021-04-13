import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  String email, gender, status, firstname, lastname, profilePic,phonenumber;
  bool isCompleted,auth;
  GeoPoint locationLatLng;
  String uid;
  List<dynamic> following;
  List<dynamic> posts;

  UserModel(
      {@required following,
        @required posts,
        @required this.email,
        @required this.uid,
        @required this.gender,
        @required this.status,
        @required this.firstname,
        @required this.lastname,
        @required this.profilePic,
        @required this.isCompleted,
        @required this.locationLatLng,
        @required this.auth,
        @required this.phonenumber});
  UserModel.fromJson(Map<String, dynamic> json, String uid) {
    this.uid = uid;
    this.email = json['email'];
    this.gender = json['gender'];
    this.status = json['status'];
    this.firstname = json['firstname'];
    this.lastname = json['lastname'];
    this.profilePic = json['profilePic'] == null ? '' : json['profilePic'];
    this.isCompleted = json['isCompleted'];
    this.locationLatLng = json['locationLatLng'] == null
        ? GeoPoint(0, 0)
        : json['locationLatLng'];
    this.following = json['following'] == null ? [] : json['following'];
    this.posts = json['posts'] == null ? [] : json['posts'];
    this.auth = json['auth'];
    this.phonenumber = json['phonenumber'];
  }
  updateUser(UserModel userModel) {
    email = userModel.email;
    uid = userModel.uid;
    gender = userModel.gender;
    status = userModel.status;
    firstname = userModel.firstname;
    lastname = userModel.lastname;
    profilePic = userModel.profilePic;
    isCompleted = userModel.isCompleted;
    locationLatLng = userModel.locationLatLng;
    posts = userModel.posts;
    following = userModel.following;
    phonenumber = userModel.phonenumber;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'gender': gender,
      'status': status,
      'firstname': firstname,
      'lastname': lastname,
      'profilePic': profilePic,
      'isCompleted': isCompleted,
      'locationLatLng': locationLatLng,
      'posts': posts,
      'following': following,
      'auth':false,
      'phonenumber':phonenumber,
    };
  }
  bool getauth(){
    return this.auth;
  }

}
