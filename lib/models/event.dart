import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  String title, description, id;
  String image;
  GeoPoint geoPoint;
  List<dynamic> usersInEvent;
  DateTime dateTime;
  DateTime startDate;
  DateTime endDate;
  String userId;
  String orgnaizer;

  Event(
      {@required this.userId,
      @required this.title,
      @required this.description,
      @required this.image,
      @required this.geoPoint,
      @required this.usersInEvent,
      @required this.dateTime,
      @required this.startDate,
        @required this.orgnaizer,
      @required this.endDate});
  Event.fromJson(Map<String, dynamic> json, String id) {
    this.id = id;
    this.title = json['title'];
    this.description = json['description'];
    this.image = json['image'];
    this.geoPoint = json['jeopoint'];
    this.dateTime = DateTime.parse(json['datetime']);
    this.startDate = DateTime.parse(json['start']);
    this.endDate = DateTime.parse(json['end']);
    this.usersInEvent = json['usersInEvent'];
    this.userId = json['user'];
    this.orgnaizer = json['username'];
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'jeopoint': geoPoint,
      'datetime': dateTime.toIso8601String(),
      'start': startDate.toIso8601String(),
      'username': orgnaizer,
      'end': endDate.toIso8601String(),
      'usersInEvent': usersInEvent,
      'user': userId
    };
  }
}
