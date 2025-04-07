import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String senderEmail;
  final bool isMe; // To style messages differently based on sender

  const MessageBubble({
    required Key key, // Need key for ListView efficiency
    required this.message,
    required this.senderEmail,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding around each bubble, slightly more vertical padding
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        // Align bubbles left/right based on isMe
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            // Allows bubble to wrap text and not overflow row
            child: Container(
              decoration: BoxDecoration(
                  color: isMe
                      ? Colors.grey[300]
                      : Theme.of(context).colorScheme.secondary.withAlpha(200),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: isMe
                        ? const Radius.circular(14)
                        : const Radius.circular(0),
                    bottomRight: isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 1), // changes position of shadow
                    ),
                  ]),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(
                  vertical: 4), // Minimal vertical margin between bubbles
              child: Column(
                // Align text inside the bubble
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Column takes minimum vertical space
                children: <Widget>[
                  // Display sender's email (optional, can be styled)
                  Text(
                    senderEmail,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isMe ? Colors.black54 : Colors.white70,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                  const SizedBox(height: 4), // Space between email and message
                  // Display the message text
                  Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.black87 : Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
