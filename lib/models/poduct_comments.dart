
import 'package:flutter/material.dart';

class ProductComment {
  String commentId, username, price, uid;
  DateTime dateTime;

  ProductComment(
      {@required this.commentId,
      @required this.dateTime,
      @required this.username,
      @required this.uid,
      @required this.price});
  ProductComment.formJson(Map<String, dynamic> json, String id) {
    commentId = id;
    username = json['username'];
    dateTime = DateTime.parse(json['date']);
    price = json['price'];
    uid = json['uid'];
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'date': dateTime.toIso8601String(),
      'price': price,
      'uid': uid
    };
  }
}
