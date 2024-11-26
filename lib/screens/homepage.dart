import 'package:flutter/material.dart';
import 'package:thapar_chatbot/auth/auth.dart';
import 'package:thapar_chatbot/handlers/authHandlers.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _authHandler = AuthHandler();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
          onPressed: () async {
            await _authHandler.clearUserData();
            Navigator.push(context,
                (MaterialPageRoute(builder: (context) => AuthScreen())));
          },
          child: Text('Logout')),
    );
  }
}
