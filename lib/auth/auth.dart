import 'package:flutter/material.dart';
import 'package:thapar_chatbot/constants.dart';
import 'package:thapar_chatbot/handlers/authHandlers.dart';
import 'package:thapar_chatbot/screens/chatpage.dart';
import 'package:thapar_chatbot/screens/homepage.dart'; // Import the AuthHandler

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authHandler = AuthHandler(); // Create an instance of AuthHandler
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userIdController = TextEditingController(); // For unique user ID input
  final _nameController = TextEditingController(); // For user name input

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSignup =
      false; // Flag to determine whether the user is signing up or logging in

  // Function to handle login/signup request
  Future<void> _authenticate() async {
    // Validate inputs
    if (_isSignup) {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _userIdController.text.isEmpty ||
          _nameController.text.isEmpty) {
        setState(() {
          _errorMessage =
              'Please fill in all fields (email, password, user ID and name).';
        });
        return;
      }
    } else {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _userIdController.text.isEmpty) {
        setState(() {
          _errorMessage =
              'Please fill in all fields (email, password, user ID).';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = ''; // Clear any previous error
    });

    try {
      // Prepare the user data
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final String userId = _userIdController.text;
      final String name = _nameController.text;

      print(email);
      print(password);
      print(userId);
      print(name);

      if (_isSignup) {
        // Handle signup
        await _authHandler.signup(
          name: name, // Pass name during signup
          email: email,
          password: password,
          userId: userId,
        );
      } else {
        // Handle login
        await _authHandler.login(
          email: email,
          password: password,
          userId: userId,
        );
      }
      // Navigate to another screen (e.g., Home Screen) upon successful login/signup
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chatpage())); // Adjust the route as needed
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            _isSignup ? 'Sign Up' : 'Login'), // Title changes based on the mode
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Name input for signup
                if (_isSignup) ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your full name',
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID  (Please remember this)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your unique user ID',
                  ),
                ),
                SizedBox(height: 16),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: Text(
                      _isSignup ? 'Sign Up' : 'Login',
                      style: TextStyle(color: Constants.KThaparColor),
                    ), // Button text changes based on the mode
                  ),
                SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignup = !_isSignup; // Toggle between signup and login
                    });
                  },
                  child: Text(
                    _isSignup
                        ? 'Already have an account? Login'
                        : 'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Constants.KThaparColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
