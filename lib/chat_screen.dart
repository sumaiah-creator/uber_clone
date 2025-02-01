import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String driverEmail;
  final String rideId;

  ChatScreen({
    required this.userEmail,
    required this.driverEmail,
    required this.rideId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() async {
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(widget.rideId);

    final chatSnapshot = await chatDoc.get();
    if (!chatSnapshot.exists) {
      // If the chat does not exist, create it and add participants
      await chatDoc.set({
        'participants': [widget.userEmail, widget.driverEmail],
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.rideId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'senderEmail': widget.userEmail,
        'timestamp': Timestamp.now(),
      });
      _messageController.clear(); // Clear the input field after sending
    }
  }

  String _extractUsername(String email) {
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.rideId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Display latest messages first
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages'));
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true, // Reverse the order of ListView
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message['senderEmail'] == widget.userEmail;
                    final senderUsername = _extractUsername(message['senderEmail']);
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderUsername,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: isUser ? TextAlign.end : TextAlign.start,
                            ),
                            SizedBox(height: 4.0),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue[100] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                message['text'],
                                textAlign: isUser ? TextAlign.end : TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                    onSubmitted: (text) {
                      _sendMessage();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
