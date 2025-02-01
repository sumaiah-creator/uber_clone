import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailableRidesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Rides'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No available rides'));
          }
          final rides = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              final source = ride['source'];
              final destination = ride['destination'];
              final driverEmail = ride['email'];
              final driverUsername = driverEmail.split('@')[0]; // Extract the driver's username

              return FutureBuilder(
                future: _checkExistingRequests(ride.id),
                builder: (context, AsyncSnapshot<bool> requestSnapshot) {
                  if (requestSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Ride from ${source['address']} to ${destination['address']}'),
                      subtitle: Text('Posted by $driverUsername'),
                      trailing: ElevatedButton(
                        onPressed: null,
                        child: Text('Loading...'),
                      ),
                    );
                  }

                  final hasAcceptedRequest = requestSnapshot.data ?? false;

                  return ListTile(
                    title: Text('Ride from ${source['address']} to ${destination['address']}'),
                    subtitle: Text('Posted by $driverUsername'),
                    trailing: hasAcceptedRequest
                        ? Text('Already Taken') // Indicate that the ride has already been taken
                        : ElevatedButton(
                            onPressed: () async {
                              // Get the current logged-in user's email
                              final currentUser = FirebaseAuth.instance.currentUser;
                              if (currentUser == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('You need to be logged in to request a ride.')),
                                );
                                return;
                              }

                              final currentUserEmail = currentUser.email!;
                              final requesterName = currentUserEmail.split('@')[0]; // Extract username from current user's email

                              print('Sending request from $requesterName');

                              await FirebaseFirestore.instance.collection('rideRequests').add({
                                'rideId': ride.id,
                                'driverEmail': driverEmail,
                                'requesterEmail': currentUserEmail,
                                'requesterName': requesterName, // Store the current user's username
                                'status': 'Pending',
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Request sent to $driverUsername')),
                              );
                            },
                            child: Text('Request Ride'),
                          ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _checkExistingRequests(String rideId) async {
    final requestSnapshot = await FirebaseFirestore.instance
        .collection('rideRequests')
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'Accepted')
        .get();

    return requestSnapshot.docs.isNotEmpty;
  }
}
