import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:uber_clone/availble_rides.dart';
import 'RoutePage.dart';
import 'constants.dart';

void signUserOut() {
  FirebaseAuth.instance.signOut();
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  TextEditingController _searchController = TextEditingController();
  static const LatLng sourceLocation = LatLng(17.38, 78.49);

  Set<Marker> _markers = {};
  List<String> _places = [];
  List<dynamic> _placeDetails = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(17, 138, 178, 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    user?.email ?? 'No Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payments'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard),
              title: Text('Refer and Earn'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: signUserOut,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: sourceLocation,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          Positioned(
            top: 80,
            left: 15,
            right: 15,
            child: Container(
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
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Color.fromRGBO(17, 138, 178, 1),
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          }),
                      Expanded(
                        child: TextField(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoutePage()),
                            );
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Enter your destination...',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(17, 138, 178, 1),
                            ),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _places = [];
                                        _placeDetails = [];
                                        _markers.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            if (value.length > 2) {
                              _searchPlaces(value);
                            } else {
                              setState(() {
                                _places = [];
                                _placeDetails = [];
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search,
                            color: Color.fromRGBO(17, 138, 178, 1)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoutePage()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_places.isNotEmpty)
            Positioned(
              top: 140,
              left: 15,
              right: 15,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(196, 197, 243, 1),
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
                  itemCount: _places.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(
                        _places[index],
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        _searchController.text = _places[index];
                        _getPlaceDetails(_placeDetails[index]);

                        setState(() {
                          _places = [];
                          _placeDetails = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 15,
            child: GestureDetector(
              onTap: () async {
                try {
                  Position position = await _getCurrentLocation();
                  LatLng latLng = LatLng(position.latitude, position.longitude);
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: latLng,
                          zoom: 14,
                        ),
                      ),
                    );
                  }
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: latLng,
                        infoWindow: InfoWindow(title: 'Current Location'),
                      ),
                    );
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(196, 197, 243, 1),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location,
                  color: Color.fromRGBO(17, 138, 178, 1),
                  size: 20,
                ),
              ),
            ),
          ),
           Positioned(
            bottom: 70,
            right: 90,
            child: ElevatedButton(
              onPressed: (){Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvailableRidesPage()),
              );},
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.black)),
              child: Text(
                'Available Rides',
                style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
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

  Future<void> _searchPlaces(String query) async {
    final apiKey = google_api_key;
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _places =
            List<String>.from(data['results'].map((place) => place['name']));
        _placeDetails = data['results'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    }
  }

  Future<void> _getPlaceDetails(dynamic place) async {
    final lat = place['geometry']['location']['lat'];
    final lng = place['geometry']['location']['lng'];
    final latLng = LatLng(lat, lng);

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('searchLocation'),
          position: latLng,
          infoWindow: InfoWindow(title: place['name']),
        ),
      );
    });

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 14,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
