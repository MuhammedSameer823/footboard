import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/player.dart';

class WinnerScreen extends StatefulWidget {
  final Player player;

  const WinnerScreen({super.key, required this.player});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🎉 Game Over")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("🏆 We have a winner!",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text("${widget.player.name} wins!",
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 10),
                Text("Final Score: ${widget.player.score}",
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back and restart game properly
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("Back to Game"),
                )
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ],
      ),
    );
  }
}
