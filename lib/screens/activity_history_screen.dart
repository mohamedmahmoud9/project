import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journey_app/models/activity.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'package:toast/toast.dart';

import 'activity_map.dart';

class ActivityHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History')),
      body: StreamBuilder(
        stream: FirestoreDatabase().getUserActivities(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Activity>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) => Column(
                    children: [
                      ListTile(
                        onTap: () {
                          if (snapshot.data[i].geopoints.isNotEmpty) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ActivityMap(
                                    locationData: snapshot.data[i].geopoints)));
                          } else {
                            Toast.show('No Line to Show', context);
                          }
                        },
                        contentPadding: EdgeInsets.all(8),
                        leading: Icon(Icons.linear_scale),
                        title: Text(
                          '${DateFormat.yMMMEd().format(snapshot.data[i].date)}',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                            '${(double.parse(snapshot.data[i].time) / 60).toStringAsFixed(2)} MIN\n${double.parse(snapshot.data[i].calories).toStringAsFixed(2)} Cal'),
                      ),
                      Divider()
                    ],
                  ));
        },
      ),
    );
  }
}
