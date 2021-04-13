import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_screen.dart';
import '../services/firestore_database.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData _currentLocation;
  BitmapDescriptor myicon;
  BitmapDescriptor Usericon;
  double distance = 0;
  Set<Marker> markers = {};
  GoogleMapController mapController;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Location location = new Location();
  _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    final value = await location.getLocation();

    _currentLocation = value;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 10.0,
        ),
      ),
    );


  }

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100, 100)), 'assets/images/YOU.png')
        .then((onValue) {
      myicon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(100, 100)), 'assets/images/user.png')
        .then((onValue) {
      Usericon = onValue;
    });
    _getLocation();
    FirestoreDatabase().getAllUsers().listen((event) {
      event.forEach((element) {

          final position = LatLng(element.locationLatLng.latitude,
              element.locationLatLng.longitude);
if(element.uid == firebaseAuth.currentUser.uid){
  final marker = Marker(
      markerId: MarkerId(element.uid),
      position: position,
      icon: myicon,
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
                  Text(
                    '${element.firstname} ${element.lastname}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
}else{
  final marker = Marker(
icon: Usericon,
      markerId: MarkerId(element.uid),
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
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(element.profilePic),
                    ),
                  ),
                  Text(
                    '${element.firstname} ${element.lastname}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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


          // });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        markers: markers != null ? Set<Marker>.from(markers) : null,
        onTap: (LatLng position) {
        },
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: _currentLocation == null
            ? CameraPosition(target: LatLng(0, 0))
            : CameraPosition(
                target: LatLng(
                    _currentLocation.latitude, _currentLocation.longitude)),
      ),
    );
  }
}

// class SheetContent extends StatefulWidget {
//   final LocationData locationData;

//   const SheetContent({Key key, this.locationData}) : super(key: key);
//   @override
//   _SheetContentState createState() => _SheetContentState();
// }

// class _SheetContentState extends State<SheetContent> {
//   int _index = 0;

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           child: Stack(
//             children: [
//               Icon(Icons.favorite_border),
//               Positioned(
//                   bottom: 3,
//                   left: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Theme.of(context).accentColor,
//                     ),
//                     child: Icon(
//                       Icons.add_outlined,
//                       size: 10,
//                     ),
//                   ))
//             ],
//           ),
//           onPressed: () {
//             showModalBottomSheet(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15)),
//               context: context,
//               builder: (ctx) => AddFavorite(),
//             );
//           },
//         ),
//         // backgroundColor: Colors.pink,
//         body: Column(
//           children: [
//             TabBar(
//                 labelColor: Theme.of(context).primaryColor,
//                 onTap: (index) {
//                   setState(() {
//                     _index = index;
//                   });
//                 },
//                 tabs: [
//                   Tab(
//                     child: Text(AppLocalizations.of(context).translate('near')),
//                   ),
//                   Tab(
//                     child: Text(
//                         AppLocalizations.of(context).translate('favorites')),
//                   ),
//                 ]),
//             if (_index == 0)
//               Expanded(
//                   child: StreamBuilder(
//                       stream: FirestoreDatabase().linesStream(),
//                       builder:
//                           (context, AsyncSnapshot<List<Line>> lineSnapshot) {
//                         if (lineSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         } else {
//                           return LinesGrid(lines: lineSnapshot.data);
//                         }
//                       })),
//             if (_index != 0)
//               Expanded(
//                   child: StreamBuilder(
//                       stream: FirestoreDatabase().favoritesStream(),
//                       builder: (context,
//                           AsyncSnapshot<List<Trip>> favoriteTripsSnapshot) {
//                         if (favoriteTripsSnapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         } else {
//                           print(favoriteTripsSnapshot.data);
//                           return FavoriteGrid(
//                               trips: favoriteTripsSnapshot.data);
//                         }
//                       })),
//           ],
//         ),
//       ),
//     );
//   }
// }
