import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_bubble.dart'; // Import the message bubble widget

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messageTextController = TextEditingController();
  User? _loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _loggedInUser = user;
        print('Logged in user: ${_loggedInUser?.email}'); // For debugging
      }
    } catch (e) {
      print(e); // Handle errors appropriately
    }
  }

  void _sendMessage() async {
    if (_messageTextController.text.trim().isEmpty || _loggedInUser == null) {
      return; // Do nothing if message is empty or user not found
    }

    FocusScope.of(context).unfocus(); // Close keyboard

    try {
      await _firestore.collection('messages').add({
        'text': _messageTextController.text.trim(),
        'senderEmail': _loggedInUser!.email, // Use logged-in user's email
        'senderId': _loggedInUser!.uid, // Store sender's unique ID
        'timestamp': FieldValue.serverTimestamp(), // Use server time
      });
      _messageTextController.clear(); // Clear input field after sending
    } catch (e) {
      print("Error sending message: $e");
      // Optionally show a snackbar or message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send message. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _auth.signOut();
              // Navigation is handled by StreamBuilder in main.dart
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // --- Message Stream Area ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listen to the 'messages' collection, ordered by timestamp
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp',
                      descending: true) // Newest messages at the top
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet!'));
                }
                if (snapshot.hasError) {
                  print("Stream Error: ${snapshot.error}"); // Log error
                  return const Center(child: Text('Something went wrong...'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // To show latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final messageText = messageData['text'] ?? '';
                    final messageSenderEmail =
                        messageData['senderEmail'] ?? 'Unknown';
                    final messageSenderId = messageData['senderId'] ?? '';

                    // Determine if the message is from the currently logged-in user
                    final isMe = _loggedInUser?.uid == messageSenderId;

                    // Use a unique key for each message
                    final messageId = messages[index].id;

                    return MessageBubble(
                      key: ValueKey(
                          messageId), // Important for efficient updates
                      message: messageText,
                      senderEmail: messageSenderEmail,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          // --- Message Input Area ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageTextController,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    decoration: const InputDecoration(
                      labelText: 'Send a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                    onSubmitted: (_) =>
                        _sendMessage(), // Send on keyboard 'done'
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageTextController.dispose(); // Clean up the controller
    super.dispose();
  }
}
