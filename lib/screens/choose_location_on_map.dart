import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ChooseLocationScreen extends StatefulWidget {
  @override
  _ChooseLocationScreenState createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  Location location = Location();
  LocationData locationData;
  LatLng selectedLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Location'),
        leading: IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              Navigator.of(context).pop(selectedLocation);
            }),
      ),
      body: locationData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              onTap: (value) {
                final marker = Marker(
                  markerId: MarkerId('id'),
                  position: value,
                );
                setState(() {
                  selectedLocation = value;
                  markers.add(marker);
                });
              },
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
