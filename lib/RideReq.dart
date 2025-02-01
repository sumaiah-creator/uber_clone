import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRequestsPage extends StatefulWidget {
  final String driverEmail;

  DriverRequestsPage({required this.driverEmail});

  @override
  _DriverRequestsPageState createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  late Future<List<Map<String, dynamic>>> _requestsFuture;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _requestsFuture = _fetchRequests();
  }

  Future<List<Map<String, dynamic>>> _fetchRequests() async {
    final requestSnapshots = await FirebaseFirestore.instance
        .collection('rideRequests')
        .where('driverEmail', isEqualTo: widget.driverEmail)
        .where('status', isEqualTo: 'Pending')
        .get();

    List<Map<String, dynamic>> requestsWithRides = [];
    for (var request in requestSnapshots.docs) {
      final rideId = request['rideId'];
      final rideSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideId)
          .get();

      if (rideSnapshot.exists) {
        requestsWithRides.add({
          'requestId': request.id,
          'requesterName': request['requesterName'],
          'rideId': rideId,
          'source': rideSnapshot['source'],
          'destination': rideSnapshot['destination'],
        });
      }
    }

    setState(() {
      _requests = requestsWithRides;
    });

    return requestsWithRides;
  }

  void _removeRequest(String requestId) {
    setState(() {
      _requests.removeWhere((request) => request['requestId'] == requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Requests'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (_requests.isEmpty) {
            return Center(child: Text('No ride requests'));
          }

          return ListView.builder(
            itemCount: _requests.length,
            itemBuilder: (context, index) {
              final request = _requests[index];
              final requesterName = request['requesterName'];
              final source = request['source'];
              final destination = request['destination'];

              return ListTile(
                title: Text('Request from $requesterName'),
                subtitle: Text(
                  'From: ${source['address']}\nTo: ${destination['address']}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        // Update the request status to 'Accepted'
                        await FirebaseFirestore.instance
                            .collection('rideRequests')
                            .doc(request['requestId'])
                            .update({'status': 'Accepted'});

                        // Add to 'acceptedRides' collection
                        await FirebaseFirestore.instance
                            .collection('acceptedRides')
                            .add({
                          'rideId': request['rideId'],
                          'driverEmail': widget.driverEmail,
                          'requesterName': requesterName,
                          'source': source,
                          'destination': destination,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        _removeRequest(request['requestId']);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ride request accepted')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('rideRequests')
                            .doc(request['requestId'])
                            .update({'status': 'Rejected'});

                        _removeRequest(request['requestId']);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ride request rejected')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}