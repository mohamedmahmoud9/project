import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journey_app/models/event.dart';
import 'package:journey_app/models/user.dart';
import 'package:journey_app/screens/choose_location_on_map.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toast/toast.dart';


class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController title = TextEditingController(),
      discription = TextEditingController();
  ImagePicker imagePicker;
  PickedFile file;
  GeoPoint geoPoint;
  bool isLoading = false;
  DateTime startDate;
  DateTime endDate;
  DateTime starttime;
  DateTime endTime;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }
final auth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
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
            Row(
              children: [
                Expanded(
                  child: RaisedButton(
                    child: Text(startDate != null
                        ? '${DateFormat.yMMMEd().format(startDate)}'
                        : 'Start Date'),
                    onPressed: () async {
                      final start = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 300)));
                      if (start != null) {
                        setState(() {
                          startDate = start;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: RaisedButton(
                    child: Text(endDate != null
                        ? '${DateFormat.yMMMEd().format(endDate)}'
                        : 'End Date'),
                    onPressed: () async {
                      final end = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 300)));
                      if (end != null) {
                        setState(() {
                          endDate = end;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  child: Text(starttime != null
                      ? '${DateFormat.jm().format(starttime)}'
                      : 'Start Time'),
                  onPressed: () async{
                    final eTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now());
                    if (eTime != null) {
                      setState(() {
                        startDate = DateTime(startDate.year,startDate.month,startDate.day,eTime.hour,eTime.minute);
                        starttime = DateTime(endDate.year,endDate.month,endDate.day,eTime.hour,eTime.minute);
                      });
                    }
                  },

                ),
                SizedBox(width: 25,),
                RaisedButton(
                  child: Text(endTime != null
                      ? '${DateFormat.jm().format(endTime)}'
                      : 'End Time'),
                  onPressed: () async{
                    final eTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now());
                    if (eTime != null) {
                      setState(() {
                        endDate = DateTime(endDate.year,endDate.month,endDate.day,eTime.hour,eTime.minute);
                        endTime = DateTime(endDate.year,endDate.month,endDate.day,eTime.hour,eTime.minute);
                      });
                    }
                  },

                ),
              ],
            ),
            Row(
              children: [
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton.icon(
                  icon: Icon(Icons.location_on_outlined),
                  label: Text('Choose Event Location'),
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
                      UserModel userorg = await FirestoreDatabase().getUserById(auth.currentUser.uid);
                      String orgnaizer = userorg.firstname+' '+userorg.lastname;
                      if (file == null ||
                          title.text.isEmpty ||
                          discription.text.isEmpty ||
                          geoPoint == null ||
                          startDate == null ||
                          endDate == null||
                      endTime == null ||
                      starttime == null) {
                        Toast.show('All Fields is Required', context);
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      var event;
                      try {
                       event =Event(
                           startDate: startDate,
                           endDate: endDate,
                           userId: FirebaseAuth.instance.currentUser.uid,
                           title: title.text,
                           description: discription.text,
                           orgnaizer: orgnaizer,
                           image: '',
                           geoPoint: geoPoint,
                           usersInEvent: [],
                           dateTime: DateTime.now());
                       event.usersInEvent.add(auth.currentUser.uid);
                        await FirestoreDatabase().addEvent(
                        event ,
                            file);


                        Toast.show('Your Event Added!', context);
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                      } catch (e) {
                        print(e);
                        Toast.show(
                            'Something went wrong,please try again!', context);
                        setState(() {
                          isLoading = false;
                        });
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
