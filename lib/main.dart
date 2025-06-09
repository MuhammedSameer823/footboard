// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/teamselection_screen.dart';
import 'screens/gamemode_screen.dart';

void main() {
  runApp(const TestGame());
}

class TestGame extends StatelessWidget {
  const TestGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Game', // Changed app title here
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/mode': (context) => const GameModeScreen(),
        '/game': (context) => const GameScreen(),
        '/select': (context) => const TeamSelectionScreen(),
      },
    );
  }
}
