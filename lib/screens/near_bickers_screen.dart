import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../services/firestore_database.dart';
import '../models/user.dart';
import 'dart:math' show cos, sqrt, asin;

class NearBickerScreen extends StatelessWidget {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))) * 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Bikers'),
      ),
      body: StreamBuilder(
        stream: FirestoreDatabase().getAllUsers(),
        builder:
            (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final user = snapshot.data.firstWhere(
                (element) => element.uid == firebaseAuth.currentUser.uid);
            snapshot.data.remove(user);
            snapshot.data.sort(
              (a, b) => coordinateDistance(
                      a.locationLatLng.latitude,
                      a.locationLatLng.longitude,
                      user.locationLatLng.latitude,
                      user.locationLatLng.longitude)
                  .toInt()
                  .compareTo(
                    coordinateDistance(
                            b.locationLatLng.latitude,
                            b.locationLatLng.longitude,
                            user.locationLatLng.latitude,
                            user.locationLatLng.longitude)
                        .toInt(),
                  ),
            );

            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  if(!snapshot.data[i].isCompleted || snapshot.data[i] == null)
                    return ListTile();
                  if (snapshot.data[i].auth) {
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(snapshot.data[i].profilePic),),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(userModel: snapshot.data[i]))),
                      title: Row(
                        children: [
                          Icon(Icons.verified,color: Colors.orange,),
                          SizedBox(width: 4,),
                          Text(
                              '${snapshot.data[i].firstname} ${snapshot.data[i].lastname}'),
                        ],
                      ),
                    );
                  } else {
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(snapshot.data[i].profilePic),),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(userModel: snapshot.data[i]))),
                      title: Row(
                        children: [
                          Icon(Icons.person,color: Colors.orange,),
                          SizedBox(width: 4,),
                          Text(
                              '${snapshot.data[i].firstname} ${snapshot.data[i].lastname}'),
                        ],
                      ),
                    );
                  }
                });
          }
        },
      ),
    );
  }
}
