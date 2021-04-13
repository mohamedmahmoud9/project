import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityMap extends StatefulWidget {
  final List<GeoPoint> locationData;

  const ActivityMap({Key key, @required this.locationData}) : super(key: key);

  @override
  _ActivityMapState createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  Polyline polyline;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    // Initializing PolylinePoints
    List<LatLng> polyCoords = [];
    if(widget.locationData.isNotEmpty){
    widget.locationData.forEach((element) {
      polyCoords.add(LatLng(element.latitude, element.longitude));
    });

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polyCoords,
      width: 4,
    );
    setState(() {
      polylines[id] = polyline;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        polylines: widget.locationData.isNotEmpty
            ? Set<Polyline>.of(polylines.values)
            : {},
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
            zoom: 16,
            target: LatLng(widget.locationData[0].latitude,
                widget.locationData[0].longitude)),
      ),
    );
  }
}
