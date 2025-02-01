import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uber_clone/HomePage.dart';
import 'package:uber_clone/constants.dart';
import 'package:uber_clone/availble_rides.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoutePage extends StatefulWidget {
  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  GoogleMapController? _mapController;
  TextEditingController _sourceController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  LatLng? _sourceLocation;
  LatLng? _destinationLocation;
  String _sourceAddress = 'Fetching location...';
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<String> _sourcePlaces = [];
  List<dynamic> _sourcePlaceDetails = [];
  List<String> _destinationPlaces = [];
  List<dynamic> _destinationPlaceDetails = [];
  bool _sourceCleared = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      Position position = await _getCurrentPosition();
      setState(() {
        _sourceLocation = LatLng(position.latitude, position.longitude);
        _sourceAddress = 'Current Location';
        _sourceController.text = _sourceAddress;
        _markers.add(
          Marker(
            markerId: MarkerId('sourceLocation'),
            position: _sourceLocation!,
            infoWindow: InfoWindow(title: 'Source Location'),
          ),
        );
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _sourceLocation!,
                zoom: 14,
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _sourceLocation ?? LatLng(0, 0),
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _initializeLocation();
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            top: 35,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Color.fromRGBO(17, 138, 178, 1),
                size: 25,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ),
          Positioned(
            top: 80,
            left: 15,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Color.fromRGBO(17, 138, 178, 1)),
                        Expanded(
                          child: Center(
                            child: TextField(
                              controller: _sourceController,
                              decoration: InputDecoration(
                                hintText: 'Enter source location...',
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(17, 138, 178, 1),
                                ),
                                border: InputBorder.none,
                                suffixIcon: _sourceController.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _sourceController.clear();
                                            _sourceAddress =
                                                'Fetching location...';
                                            _sourceLocation = null;
                                            _markers.clear();
                                            _polylines.clear();
                                            _sourceCleared = true;
                                            _sourcePlaces = [];
                                            _sourcePlaceDetails = [];
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && _sourceCleared) {
                                  _searchSourcePlaces(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_sourcePlaces.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    height: 200,
                    child: ListView.builder(
                      itemCount: _sourcePlaces.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            _sourcePlaces[index],
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            _sourceController.text = _sourcePlaces[index];
                            _setSourceLocation(_sourcePlaceDetails[index]);
                            setState(() {
                              _sourcePlaces = [];
                              _sourcePlaceDetails = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Color.fromRGBO(17, 138, 178, 1)),
                      Expanded(
                        child: TextField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            hintText: 'Enter destination...',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(17, 138, 178, 1),
                            ),
                            border: InputBorder.none,
                            suffixIcon: _destinationController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _destinationController.clear();
                                        _destinationPlaces = [];
                                        _destinationPlaceDetails = [];
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.length > 2) {
                              _searchDestinationPlaces(value);
                            } else {
                              setState(() {
                                _destinationPlaces = [];
                                _destinationPlaceDetails = [];
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_destinationPlaces.isNotEmpty)
            Positioned(
              top: 210,
              left: 15,
              right: 15,
              child: Container(
                height: 200,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: _destinationPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        _destinationPlaces[index],
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        _destinationController.text = _destinationPlaces[index];
                        _getPlaceDetails(_destinationPlaceDetails[index]);
                        setState(() {
                          _destinationPlaces = [];
                          _destinationPlaceDetails = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 70,
            right: 120,
            child: ElevatedButton(
              onPressed: () {
                _saveRideDetails();
              },
              child: Text(
                'Post Ride',
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location Permission denied");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _searchSourcePlaces(String query) async {
    final apiKey = google_api_key;
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _sourcePlaces =
            List<String>.from(data['results'].map((place) => place['name']));
        _sourcePlaceDetails = data['results'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    }
  }

  Future<void> _searchDestinationPlaces(String query) async {
    final apiKey = google_api_key;
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _destinationPlaces =
            List<String>.from(data['results'].map((place) => place['name']));
        _destinationPlaceDetails = data['results'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    }
  }

  Future<void> _setSourceLocation(dynamic place) async {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];

    setState(() {
      _sourceLocation = LatLng(lat, lng);
      _markers.add(
        Marker(
          markerId: MarkerId('sourceLocation'),
          position: _sourceLocation!,
          infoWindow: InfoWindow(title: 'Source Location'),
        ),
      );
    });

    _showRoute();
  }

  Future<void> _getPlaceDetails(dynamic place) async {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];

    setState(() {
      _destinationLocation = LatLng(lat, lng);
      _markers.add(
        Marker(
          markerId: MarkerId('destinationLocation'),
          position: _destinationLocation!,
          infoWindow: InfoWindow(title: 'Destination Location'),
        ),
      );
    });

    _showRoute();
  }

  Future<void> _showRoute() async {
    if (_sourceLocation != null && _destinationLocation != null) {
      final apiKey = google_api_key;
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_sourceLocation!.latitude},${_sourceLocation!.longitude}&destination=${_destinationLocation!.latitude},${_destinationLocation!.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['overview_polyline']['points'];
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: _decodePolyline(route),
            color: Colors.blue,
            width: 5,
          ));
        });

        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _boundsFromLatLngList([_sourceLocation!, _destinationLocation!]),
            50,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching route')),
        );
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list[0].latitude;
    double x1 = list[0].latitude;
    double y0 = list[0].longitude;
    double y1 = list[0].longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  void _saveRideDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _sourceLocation != null && _destinationLocation != null) {
      String email = user.email!;
      await FirebaseFirestore.instance.collection('rides').add({
        'email': email,
        'source': {
          'latitude': _sourceLocation!.latitude,
          'longitude': _sourceLocation!.longitude,
          'address': _sourceController.text,
        },
        'destination': {
          'latitude': _destinationLocation!.latitude,
          'longitude': _destinationLocation!.longitude,
          'address': _destinationController.text,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride details saved successfully'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvailableRidesPage()),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in or locations not set')),
      );
    }
  }
}
