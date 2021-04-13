import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserOnMapScreen extends StatefulWidget {
  final GeoPoint geoPoint;
  final String appBarTitle;
  const UserOnMapScreen(
      {Key key, @required this.geoPoint, @required this.appBarTitle})
      : super(key: key);
  @override
  _UserOnMapScreenState createState() => _UserOnMapScreenState();
}

class _UserOnMapScreenState extends State<UserOnMapScreen> {
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
    final marker = Marker(
      markerId: MarkerId('0'),
      position: LatLng(widget.geoPoint.latitude, widget.geoPoint.longitude),
    );
    setState(() {
      markers.add(marker);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
      ),
      body: GoogleMap(
        markers: markers != null ? Set<Marker>.from(markers) : null,
        initialCameraPosition: CameraPosition(
          zoom: 16,
            target:
                LatLng(widget.geoPoint.latitude, widget.geoPoint.longitude)),
      ),
    );
  }
}
