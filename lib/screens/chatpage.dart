import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thapar_chatbot/handlers/authHandlers.dart';
import 'package:thapar_chatbot/handlers/messageHandlers.dart';
import 'package:uuid/uuid.dart';
import 'package:thapar_chatbot/handlers/chatBotHandler.dart'; // Import the handler

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final _authController = AuthHandler();
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
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');

    try {
      final messages = await MessageHandlers().getMessages(
        userId: userId ?? '',
      );

      if (messages.isNotEmpty) {
        setState(() {
          _messages = messages.expand<Map<String, String>>((message) {
            return [
              {
                'sender': 'user',
                'message': message['messageBySender'] as String,
              },
              {
                'sender': 'bot',
                'message': message['messageByBot'] as String,
              }
            ];
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  // Load user ID from local storage

  Future<void> _loadUserId() async {
    final _messageController = MessageHandlers();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    print(userId);
    _userId = userId ?? '';
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

  // Function to handle logout
  Future<void> _logout() async {
    await _authController.clearUserData(); // Clear all stored preferences

    // Navigate to the login page or any desired route
    Navigator.pop(context);
  }

  // Function to send the message to the backend and get the bot's response
  Future<void> _saveMessage(userid, messageBySender, messageByBot) async {
    await MessageHandlers().saveMessage(
      userId: userid,
      messageBySender: messageBySender,
      messageByBot: messageByBot,
    );
  }

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

      await _saveMessage(
        _userId,
        message,
        botResponse,
      );
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
        title: const Text(
          'Chat with ThaparBot',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFCA0202),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Display the messages
          Expanded(
            child: Container(
              color: const Color(0xFFF9F9F9), // Light background
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (ctx, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFCA0202)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                          fontWeight:
                              isUser ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Message input and send button
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
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
                        labelStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFFCA0202),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFFCA0202)),
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
