
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  String title, description, id;
  String image;
  GeoPoint geoPoint;
  double price;
  DateTime dateTime;
  String userId;
  bool isSold;

  Product({
    @required this.price,
    @required this.userId,
    @required this.title,
    @required this.description,
    @required this.image,
    @required this.geoPoint,
    @required this.dateTime,
    @required this.isSold,
  });
  Product.fromJson(Map<String, dynamic> json, String id) {
    this.id = id;
    this.title = json['title'];
    this.description = json['description'];
    this.image = json['image'];
    this.geoPoint =
        json['jeopoint'] == null ? GeoPoint(0, 0) : json['jeopoint'];
    this.dateTime = DateTime.parse(json['datetime']);
    this.price = json['price'];
    this.userId = json['user'];
    this.isSold = json['isSold'];
  }
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'title': title,
      'description': description,
      'image': image,
      'jeopoint': geoPoint,
      'datetime': dateTime.toIso8601String(),
      'user': userId,
      'isSold': isSold
    };
  }
}
