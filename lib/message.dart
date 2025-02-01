import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_clone/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  final String userEmail;

  MessagesScreen({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages found'));
          }

          final chatDocs = snapshot.data!.docs;
          if (chatDocs.isEmpty) {
            return Center(child: Text('No chats available'));
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatDoc = chatDocs[index];
              final rideId = chatDoc.id; // Assuming the document ID is the ride ID

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatDoc.id)
                    .collection('messages')
                    .orderBy('timestamp', descending: true) // Sort messages by timestamp descending
                    .limit(1) // Get the most recent message
                    .get(),
                builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }
                  if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text('No messages'),
                    );
                  }

                  final lastMessage = messageSnapshot.data!.docs.first;
                  final messageText = lastMessage['text'];
                  final timestamp = lastMessage['timestamp'] as Timestamp;
                  final formattedTime = _formatTimestamp(timestamp);

                  return ListTile(
                    title: Text('Ride ID: $rideId'),
                    subtitle: Text('$messageText\n$formattedTime'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userEmail: userEmail,
                            driverEmail: '', // Adjust based on your logic
                            rideId: rideId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final time = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    return '$formattedDate at $time';
  }
}
