import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_app/screens/profile_screen.dart';
import 'package:journey_app/services/firestore_database.dart';
import 'events_screen.dart';
import 'market_screen.dart';
import 'package:location/location.dart';

class MainMap extends StatefulWidget {
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Location location = Location();

  FirestoreDatabase db = FirestoreDatabase();
  Set<Marker> markers = {};
  LocationData locationData;
  BitmapDescriptor Usericon;
  BitmapDescriptor Eventicon;
  BitmapDescriptor MarketIcon;
  BitmapDescriptor you;

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(25, 25)), 'assets/images/user.png')
        .then((onValue) {
      Usericon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100, 100)), 'assets/images/YOU.png')
        .then((onValue) {
      you = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(25, 25)), 'assets/images/Event.png')
        .then((onValue) {
      Eventicon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(25, 25)), 'assets/images/Market.png')
        .then((onValue) {
      MarketIcon = onValue;
    });
    _getCurrentLocation();

    db.getAllUsers().listen((event) {
      event.forEach((element)  {
        if (firebaseAuth.currentUser.uid != element.uid) {
          final position = LatLng(element.locationLatLng.latitude,
              element.locationLatLng.longitude);
          final marker = Marker(
              markerId: MarkerId(event.indexOf(element).toString()),
              position: position,
              icon: Usericon,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  builder: (
                    ctx,
                  ) =>
                      Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(element.profilePic),
                        ),
                      ),
                      Text('${element.firstname} '+'${element.lastname}'),
                      Text(
                        '${element.gender}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      Divider(),
                      RaisedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(userModel: element)));
                          },
                          child: Text('View Profile')),
                      SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                );
              });
          setState(() {
            markers.add(marker);
          });
          // });

        }
        else{
          final position = LatLng(element.locationLatLng.latitude,
              element.locationLatLng.longitude);
          final marker = Marker(
              markerId: MarkerId(event.indexOf(element).toString()),
              position: position,
              icon: you,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  builder: (
                      ctx,
                      ) =>
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(element.profilePic),
                            ),
                          ),
                          Text('${element.firstname} '+'${element.lastname}'),
                          Text(
                            '${element.gender}',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                          Divider(),
                          RaisedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(userModel: element)));
                              },
                              child: Text('View Profile')),
                          SizedBox(
                            height: 16,
                          )
                        ],
                      ),
                );
              });
          setState(() {
            markers.add(marker);
          });
        }
      });
    });

    db.getAllEvents().listen((event) {
      event.forEach((element) {
        final position =
            LatLng(element.geoPoint.latitude, element.geoPoint.longitude);

        final marker = Marker(
            icon: Eventicon,
            markerId: MarkerId(element.id),
            position: position,
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                builder: (
                  ctx,
                ) =>
                    Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        height: 200,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              element.image,
                              fit: BoxFit.cover,
                            ))),
                    Center(
                      child: Text(
                        '${element.title}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${element.description}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),

                    ),
                    RaisedButton( onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventsScreen(
                                     )));
                    },
                        child: Text('View Event')),
                    Divider(),
                    SizedBox(
                      height: 32,
                    )
                  ],
                ),
              );
            });
        setState(() {
          markers.add(marker);
        });
      });
    });
    db.getAllProducts().listen((event) {
      event.forEach((element) {
        final position =
            LatLng(element.geoPoint.latitude, element.geoPoint.longitude);

        final marker = Marker(
            icon:
            MarketIcon,
            markerId: MarkerId(element.id),
            position: position,
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                builder: (
                  ctx,
                ) =>
                    Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        height: 200,
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              element.image,
                              fit: BoxFit.cover,
                            ))),
                    ListTile(
                      title: Text(
                        '${element.title}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Text('${element.price}\$'),
                      subtitle: Text(
                        '${element.description}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                    ),
                    RaisedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                   MarketScreen()));
                        },
                        child: Text('View Market')),
                    SizedBox(
                      height: 32,
                    )
                  ],
                ),
              );
            });
        setState(() {
          markers.add(marker);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: locationData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: CameraPosition(
                zoom: 16,
                target: LatLng(locationData.latitude, locationData.longitude),
              )),
    );
  }

  _getCurrentLocation() async {
    locationData = await location.getLocation();
    setState(() {});
  }
}
