import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey_app/models/product.dart';
import 'package:journey_app/screens/choose_location_on_map.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:toast/toast.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController title = TextEditingController(),
      discription = TextEditingController(),
      price = TextEditingController();
  ImagePicker imagePicker;
  PickedFile file;
  GeoPoint geoPoint;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                width: MediaQuery.of(context).size.width * .5,
                height: 100,
                child: Stack(
                  children: [
                    file == null
                        ? Container()
                        : Image.file(
                            File(file.path),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded),
                        onPressed: _pickPhoto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: title,
              decoration: InputDecoration(hintText: 'Title'),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: discription,
              decoration: InputDecoration(hintText: 'Description'),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: price,
                            decoration: InputDecoration(hintText: 'Price'),

            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton.icon(
                  icon: Icon(Icons.location_on_outlined),
                  label: Text('Choose Product Location'),
                  onPressed: () async {
                    final loction = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ChooseLocationScreen()));
                    if (loction != null) {
                      setState(() {
                        geoPoint =
                            GeoPoint(loction.latitude, loction.longitude);
                      });
                    }
                  },
                ),
              ],
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RaisedButton(
                    child: Text('Add'),
                    onPressed: () async {
                      if (file == null ||
                          title.text.isEmpty ||
                          discription.text.isEmpty ||
                          geoPoint == null ||
                          price.text.isEmpty) {
                        Toast.show('All Fields is Required', context);
                        return;
                      }
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        await FirestoreDatabase().addProduct(
                            Product(
                                userId: FirebaseAuth.instance.currentUser.uid,
                                title: title.text,
                                description: discription.text,
                                image: '',
                                geoPoint: geoPoint,
                                price: double.parse(price.text),
                                dateTime: DateTime.now(),
                                isSold: false),
                            file);

                        Toast.show('Your Product Added!', context);
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        Toast.show(
                            'Something went wrong,please try again!', context);
                      }
                    })
          ],
        ),
      ),
    );
  }

  void _pickPhoto() async {
    file = await imagePicker.getImage(source: ImageSource.gallery);

    setState(() {});
  }
}
