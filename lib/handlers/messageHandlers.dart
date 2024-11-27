import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageHandlers {
  // Base URL of your backend server
  String baseUrl = 'https://thaparbot-backend.onrender.com';
  // Method to send a new message to the backend
  Future<void> saveMessage({
    required String userId,
    required String messageBySender,
    required String messageByBot,
  }) async {
    final url = Uri.parse('$baseUrl/api/messages/save');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'messageBySender': messageBySender,
          'messageByBot': messageByBot,
        }),
      );

      if (response.statusCode == 200) {
        print("Message saved successfully: ${response.body}");
      } else {
        print("Failed to save message: ${response.body}");
        throw Exception('Failed to save message');
      }
    } catch (e) {
      print("Error saving message: $e");
      rethrow;
    }
  }

  // Method to get all messages for a user and session
  Future<List<dynamic>> getMessages({
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/api/messages/get');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['conversation'] as List<dynamic>;
      } else if (response.statusCode == 404) {
        print("No conversation found: ${response.body}");
        return [];
      } else {
        print("Failed to fetch messages: ${response.body}");
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      print("Error fetching messages: $e");
      rethrow;
    }
  }
}
