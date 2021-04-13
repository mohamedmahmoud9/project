
import 'package:flutter/material.dart';

class Post {
  String body, image, id;
  DateTime dateTime;

  Post(
      {@required this.body,
      @required this.image,
      @required this.id,
      @required this.dateTime});
  Post.fromJson(Map<String, dynamic> json, String id) {
    body = json['body'];
    image = json['image'] == null ? '' : json['image'];
    dateTime = DateTime.parse(json['date']);
    id = id;
  }
  Map<String, dynamic> toJson() {
    return {'body': body, 'image': image, 'date': dateTime.toIso8601String()};
  }
}
