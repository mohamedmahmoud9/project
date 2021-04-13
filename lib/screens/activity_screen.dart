import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journey_app/models/activity.dart';
import 'package:journey_app/models/user.dart';
import 'package:journey_app/screens/activity_map.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:location/location.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'dart:math' show cos, sqrt, asin;

import 'activity_history_screen.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _isHours = true;
  final store = FirestoreDatabase();
  final _service = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );
  String displayTime;
  DateTime startdate;
  Location location;
  bool isPause;
  List<LocationData> lineData;
  bool showResult = false;
  bool isReset;
  double distance;
  int milleSecond;
  @override
  void initState() {
    super.initState();
    displayTime = '00:00:00.00';
    // _stopWatchTimer.rawTime.listen((value) =>
    //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
    //
    location = Location();
    lineData = [];
    distance = 0.0;
    milleSecond = 0;
    isPause = false;
    isReset = false;

    /// Can be set preset time. This case is "00:01.23".
    // _stopWatchTimer.setPresetTime(mSec: 1234);
  }

  @override
  void dispose() async {
    super.dispose();
    FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser.uid)
        .update({'status': '1'});
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: true,
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ActivityHistoryScreen()));
            },
            child: Text('History'),
            textColor: Colors.white,
          )
        ],
      ),
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                'Get Ready for Journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.orange),
              ),
            ),

            /// Display stop watch time
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  milleSecond = snap.data;
                  displayTime =
                      StopWatchTimer.getDisplayTime(snap.data, hours: _isHours);
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  Text(
                                    displayTime,
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Container(
              height: MediaQuery.of(context).size.height / 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: ListTile(
                    title: Text(
                      'Destance',
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text('${(distance * 1000).toStringAsFixed(2)} M',
                        textAlign: TextAlign.center),
                  )),
                  VerticalDivider(
                    thickness: 1,
                  ),
                  Expanded(
                      child: ListTile(
                    title: Text('Calories', textAlign: TextAlign.center),
                    subtitle: Text('${getCal().toStringAsFixed(2)} cal',
                        textAlign: TextAlign.center),
                  ))
                ],
              ),
            ),
            Divider(
              thickness: 1,
            ),

            /// Button
            Padding(
              padding: const EdgeInsets.all(2),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                            padding: const EdgeInsets.all(4),
                            color: Colors.lightBlue,
                            shape: const StadiumBorder(),
                            onPressed: showResult
                                ? null
                                : () async {
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.start);
                                    setState(() {
                                      isPause = false;
                                    });
                                    await location.requestPermission();

                                    location.onLocationChanged.listen((event) {
                                      if (!showResult || !isReset) {
                                        if (!isPause) {
                                          setState(() {
                                            distance = getTotalDistance();
                                          });
                                        }
                                        lineData.add(event);
                                      }
                                    });
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(_auth.currentUser.uid)
                                        .update({'status': '0'});
                                    this.startdate = DateTime.now();
                                  },
                            child: const Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: RaisedButton(
                            padding: const EdgeInsets.all(4),
                            color: Colors.lightBlue,
                            shape: const StadiumBorder(),
                            onPressed: showResult
                                ? null
                                : () async {
                                    _stopWatchTimer.onExecute
                                        .add(StopWatchExecute.stop);
                                    setState(() {
                                      isPause = true;
                                    });
                                  },
                            child: const Text(
                              'Pause',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RaisedButton(
                          padding: const EdgeInsets.all(4),
                          color: Colors.green,
                          shape: const StadiumBorder(),
                          onPressed: showResult
                              ? null
                              : () async {
                                  _stopWatchTimer.onExecute
                                      .add(StopWatchExecute.stop);
                                  setState(() {
                                    showResult = true;
                                    isPause = true;
                                    distance = getTotalDistance();
                                  });
                                  final List<GeoPoint> list = [];
                                  lineData.forEach((element) {
                                    list.add(GeoPoint(
                                        element.latitude, element.longitude));
                                  });
                                  Activity activity = Activity(
                                      time: (milleSecond / 1000)
                                          .toStringAsFixed(2),
                                      date: startdate,
                                      enddate: DateTime.now(),
                                      meters:
                                          getTotalDistance().toStringAsFixed(2),
                                      geopoints: list,
                                      calories: getCal().toStringAsFixed(2));
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_auth.currentUser.uid)
                                      .update({'status': '1'});
                                  FirestoreDatabase().addActivity(activity);
                                },
                          child: const Text(
                            'Stop',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: RaisedButton(
                          padding: const EdgeInsets.all(4),
                          color: Colors.red,
                          shape: const StadiumBorder(),
                          onPressed: () async {
                            _stopWatchTimer.onExecute
                                .add(StopWatchExecute.reset);

                            setState(() {
                              showResult = false;
                              isReset = true;
                              isPause = true;
                              lineData = [];
                              distance = 0.0;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showResult)
                    Column(
                      children: [
                        // SizedBox(
                        //   height: 16,
                        // ),
                        // Text(
                        //   'Your Distance is : ${(distance * 1000).toStringAsFixed(2)} Meter',
                        //   style: TextStyle(
                        //       color: Theme.of(context).primaryColor,
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.w700),
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),
                        // Text(
                        //   'Your Burned calories is : ${(getCal()).toStringAsFixed(2)} Cal',
                        //   style: TextStyle(
                        //       color: Theme.of(context).primaryColor,
                        //       fontSize: 22,
                        //       fontWeight: FontWeight.w700),
                        // ),
                        // SizedBox(
                        //   height: 16,
                        // ),
                        OutlineButton.icon(
                          onPressed: () {
                            List<GeoPoint> line = lineData
                                .map((e) => GeoPoint(e.latitude, e.longitude))
                                .toList();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ActivityMap(locationData: line)));
                          },
                          textColor: Theme.of(context).primaryColor,
                          shape: const StadiumBorder(),
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                          icon: Icon(Icons.location_on_outlined),
                          label: Text('Show on Map'),
                        )
                      ],
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getTotalDistance() {
    double total = 0;
    for (int i = 0; i < lineData.length - 1; i++) {
      total += _coordinateDistance(
        lineData[i].latitude,
        lineData[i].longitude,
        lineData[i + 1].latitude,
        lineData[i + 1].longitude,
      );
    }
    return total;
  }

  double getCal() {
    double hours = ((this.milleSecond / 1000) * this.distance) / 275;
    return (hours * 400);
  }
}
