import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotHandler {
  // Function to send user message and get bot's response
  Future<String> getBotResponse({
    required String userId,
    required String message,
    required String chatSessionId,
  }) async {
    try {
      print(userId);
      print(message);
      print(chatSessionId);
      final response = await http.post(
        Uri.parse(
            'https://thaparbot-backend.onrender.com/api/chatbot/getresponse'), // Replace with your backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'messageBySender': message,
          // Temporary response until the backend returns
          'chat_session_id': chatSessionId,
        }),
      );

      if (response.statusCode == 200) {
        // Assuming the backend returns the bot's response as a message
        final responseData = json.decode(response.body);
        return responseData['botResponse'] ?? 'No response from bot';
      } else {
        throw Exception(response);
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
