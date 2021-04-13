
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Activity {
  DateTime date,enddate;
  String time;
  String meters, calories;
  List<GeoPoint> geopoints;

  Activity(
      {@required this.date,
      @required this.time,
      @required this.meters,
      @required this.calories,
      @required this.geopoints,
      this.enddate});
  Activity.formJson(Map<String, dynamic> json) {
    time = json['time'];
    date = DateTime.parse(json['date']);
    enddate = DateTime.parse(json['enddate']);
    meters = json['meters'];
    calories = json['cal'];
    geopoints = json['geopint'].cast<GeoPoint>();
    
  }
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'date': date.toIso8601String(),
      'enddate': enddate.toIso8601String(),
      'meters': meters,
      'cal': calories,
      'geopint': geopoints,
    };
  }
}
