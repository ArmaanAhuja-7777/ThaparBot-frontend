import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:thapar_chatbot/handlers/chatBotHandler.dart'; // Import the handler

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _userId = '';
  String _chatSessionId = '';
  final ChatBotHandler _chatBotHandler =
      ChatBotHandler(); // Instance of handler

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _generateChatSessionId();
  }

  // Load user ID from local storage
  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
    }
  }

  // Generate a random chat session ID
  void _generateChatSessionId() {
    var uuid = Uuid();
    setState(() {
      _chatSessionId = uuid.v4(); // Generates a random UUID as chat session ID
    });
  }

  // Function to send the message to the backend and get the bot's response
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final String message = _messageController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get bot's response from the handler
      final String botResponse = await _chatBotHandler.getBotResponse(
        userId: _userId,
        message: message,
        chatSessionId: _chatSessionId,
      );

      // Update the messages list with the sent message and bot response
      setState(() {
        _messages.add({
          'sender': 'user',
          'message': message,
        });
        _messages.add({
          'sender': 'bot',
          'message': botResponse,
        });
        _messageController.clear(); // Clear the message input field
        _isLoading =
            false; // Set loading to false once the response is received
      });
    } catch (e) {
      setState(() {
        _isLoading =
            false; // Ensure loading is set to false even when an error occurs
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Bot'),
      ),
      body: Column(
        children: [
          // Display the messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(
                    message['message']!,
                    style: TextStyle(
                      fontWeight: message['sender'] == 'user'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(message['sender'] == 'user' ? 'You' : 'Bot'),
                );
              },
            ),
          ),
          // Message input and send button
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Enter your message...',
                        border: OutlineInputBorder(),
                      ),
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
