import 'package:flutter/material.dart';
import 'package:uber_clone/HomePage.dart';
import 'package:uber_clone/RideReq.dart';
import 'package:uber_clone/availble_rides.dart';
import 'package:uber_clone/message.dart';
import 'package:uber_clone/myrides.dart';

class Home extends StatelessWidget {
  final String userEmail;

  const Home({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                child: Text("Post"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AvailableRidesPage(),
                    ),
                  );
                },
                child: Text("Available Rides"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverRequestsPage(driverEmail: userEmail),
                    ),
                  );
                },
                child: Text("Requests"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyRidesPage(userEmail: userEmail),
                    ),
                  );
                },
                child: Text("My Rides"),
              ),
                 ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MessagesScreen(userEmail: userEmail),
                    ),
                  );
                },
                child: Text("Messages"),
                
              ),
               ElevatedButton(
                onPressed: signUserOut,
                child: Text("Log Out"),
               )
            ],
          ),
        ),
      ),
    );
  }
}
