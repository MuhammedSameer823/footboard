// lib/screens/anonymous_login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AnonymousLoginScreen extends StatefulWidget {
  const AnonymousLoginScreen({super.key});

  @override
  State<AnonymousLoginScreen> createState() => _AnonymousLoginScreenState();
}

class _AnonymousLoginScreenState extends State<AnonymousLoginScreen> {
  bool _loading = false;

  void _signIn() async {
    setState(() => _loading = true);
    final user = await AuthService.signInAnonymously();
    setState(() => _loading = false);

    if (user != null) {
      Navigator.pop(context); // Return to previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anonymous Login")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _signIn,
                child: const Text("Login Anonymously"),
              ),
      ),
    );
  }
}
