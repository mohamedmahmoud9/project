import 'package:flutter/material.dart';

class Message {
  String from, to, message;
  DateTime dateTime;
  String id;

  Message(
      {@required this.to,
      @required this.from,
      @required this.id,
      @required this.message,
      @required this.dateTime});
  Message.fromJson(Map<String, dynamic> map, String id) {
    to = map['to_id'];
    from = map['from_id'];
    id = id;
    message = map['message'];
    dateTime = DateTime.parse(map['date']);
  }
  Map<String ,dynamic> toMap(){
    return {
      'to_id':to,
      'from_id':from,
      'message':message,
      'date':dateTime.toIso8601String()
    };
  }
}
