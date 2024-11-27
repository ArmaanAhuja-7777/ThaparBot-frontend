import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthHandler {
  // Unique user ID for registration/login

  // Constructor to initialize the email, password, and user_id

  // Method to handle user login
  Future<void> login({
    required String userId,
    required String email,
    required String password,
  }) async {
    // API URL for login (replace with your backend login endpoint)
    final String apiUrl =
        'https://thaparbot-backend.onrender.com/api/auth/login';

    // Prepare data to send in the request body
    final Map<String, String> loginData = {
      'email': email,
      'password': password,
      // Include user_id for login
    };

    try {
      // Make the POST request to the backend API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // If login is successful, process the response (e.g., storing token)
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Login successful: ${responseData['message']}');

        // Extract the auth token from the response (adjust according to your API)
        final String authToken = responseData['token'];

        // Store user_id and auth token in SharedPreferences for persistence
        await _storeUserId(userId);
        await _storeAuthToken(authToken);
      } else {
        // If login failed, handle the error
        print('Login failed: ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error during login: $e');
    }
  }

  // Method to handle user signup
  Future<void> signup(
      {required String name,
      required String email,
      required String password,
      required String userId}) async {
    // API URL for signup (replace with your backend signup endpoint)
    final String apiUrl =
        'https://thaparbot-backend.onrender.com/api/auth/register';

    // Prepare data to send in the request body
    final Map<String, String> signupData = {
      'user_id': userId, // Include user_id for signup
      'name': name,
      'email': email,
      'password': password,
    };

    try {
      // Make the POST request to the backend API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(signupData),
      );

      // Check if the response is successful
      if (response.statusCode == 201) {
        // If signup is successful, process the response
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Signup successful: ${responseData['message']}');

        // Extract the auth token from the response (adjust according to your API)
        final String authToken = responseData['token'];

        // Store user_id and auth token in SharedPreferences for persistence
        await _storeUserId(userId);
        await _storeAuthToken(authToken);
      } else {
        // If signup failed, handle the error
        print('Signup failed: ${response.body}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error during signup: $e');
    }
  }

  // Helper method to store user ID in SharedPreferences
  Future<void> _storeUserId(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId); // Store user ID in local storage
    print('User ID stored: $userId');
  }

  // Helper method to store authentication token in SharedPreferences
  Future<void> _storeAuthToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token); // Store token for future use
    print('Auth token stored');
  }

  // Helper method to retrieve the stored user ID
  Future<String?> getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Method to check if a user is logged in by checking if the user ID is stored
  Future<bool> isUserLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_id');
  }

  // Method to clear user data (e.g., logout)
  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('auth_token'); // Also clear the auth token if applicable
    print('User data cleared');
  }
}
