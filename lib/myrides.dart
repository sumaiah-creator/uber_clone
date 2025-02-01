import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber_clone/chat_screen.dart';

class MyRidesPage extends StatelessWidget {
  final String userEmail;

  MyRidesPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Rides'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Offered Rides'),
              Tab(text: 'Taken Rides'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OfferedRidesTab(userEmail: userEmail),
            TakenRidesTab(userEmail: userEmail),
          ],
        ),
      ),
    );
  }
}

class OfferedRidesTab extends StatelessWidget {
  final String userEmail;

  OfferedRidesTab({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rides')
          .where('email', isEqualTo: userEmail) // Query rides offered by the user
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rides offered'));
        }
        final rides = snapshot.data!.docs;
        return ListView.builder(
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            final rideId = ride.id;
            final source = ride['source'];
            final destination = ride['destination'];

            // Query the rideRequests collection to find accepted requests for this ride
            final rideRequests = FirebaseFirestore.instance
                .collection('rideRequests')
                .where('rideId', isEqualTo: rideId)
                .where('status', isEqualTo: 'Accepted')
                .get();

            return FutureBuilder<QuerySnapshot>(
              future: rideRequests,
              builder: (context, requestSnapshot) {
                if (requestSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Loading ride requests...'),
                  );
                }
                if (!requestSnapshot.hasData || requestSnapshot.data!.docs.isEmpty) {
                  return ListTile(
                    title: Text('Not Completed'),
                    subtitle: Text(
                      'From: ${source['address']}\nTo: ${destination['address']}\nRide ID: $rideId',
                    ),
                    trailing: _buildPopupMenu(context, rideId, requestSnapshot.data!.docs),
                  );
                }
                final acceptedRequest = requestSnapshot.data!.docs.first;
                final riderEmail = acceptedRequest['requesterEmail'];
                final riderName = _extractUsername(riderEmail);

                return ListTile(
                  title: Text('Offered To: $riderName'),
                  subtitle: Text(
                    'From: ${source['address']}\nTo: ${destination['address']}\nRide ID: $rideId',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userEmail: userEmail,
                                driverEmail: riderEmail,
                                rideId: rideId,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildPopupMenu(context, rideId, requestSnapshot.data!.docs),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method to extract username from email
  String _extractUsername(String email) {
    return email.split('@').first;
  }

  // Helper method to build the PopupMenuButton for delete action
  Widget _buildPopupMenu(BuildContext context, String rideId, List<QueryDocumentSnapshot> requests) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          // Confirm before deleting
          final confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Delete Ride'),
                content: Text('Are you sure you want to delete this ride?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
          if (confirmDelete == true) {
            // Delete the ride
            await FirebaseFirestore.instance.collection('rides').doc(rideId).delete();

            // Delete the associated ride requests
            for (var request in requests) {
              await FirebaseFirestore.instance.collection('rideRequests').doc(request.id).delete();
            }
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete Ride'),
        ),
      ],
    );
  }
}

class TakenRidesTab extends StatelessWidget {
  final String userEmail;

  TakenRidesTab({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rideRequests')
          .where('requesterEmail', isEqualTo: userEmail) // Query rides taken by the user
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No rides taken'));
        }

        final rides = snapshot.data!.docs;

        // Check if any ride details are found
        return FutureBuilder<List<DocumentSnapshot>>(
          future: Future.wait(rides.map((rideRequest) {
            final rideId = rideRequest['rideId'];
            return FirebaseFirestore.instance
                .collection('rides')
                .doc(rideId)
                .get();
          }).toList()),
          builder: (context, rideSnapshots) {
            if (rideSnapshots.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // Filter out any rides where the details could not be found
            final validRides = rideSnapshots.data
                ?.where((rideSnapshot) => rideSnapshot.exists)
                .toList();

            if (validRides == null || validRides.isEmpty) {
              return Center(child: Text('No rides taken'));
            }

            return ListView.builder(
              itemCount: validRides.length,
              itemBuilder: (context, index) {
                final ride = validRides[index];
                final source = ride['source'];
                final destination = ride['destination'];
                final driverEmail = ride['email']; // Assuming the driver email is stored in the 'email' field
                final driverName = _extractUsername(driverEmail);
                final rideId = ride.id;
                final rideRequest = rides[index];
                final status = rideRequest['status'];

                return ListTile(
                  title: Text('Ride Status: $status'),
                  subtitle: Text(
                    'From: ${source['address']}\nTo: ${destination['address']}\nRide ID: $rideId',
                  ),
                  trailing: status == 'Accepted'
                      ? IconButton(
                          icon: Icon(Icons.chat),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userEmail: userEmail,
                                  driverEmail: driverEmail,
                                  rideId: rideId,
                                ),
                              ),
                            );
                          },
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method to extract username from email
  String _extractUsername(String email) {
    return email.split('@').first;
  }
}

