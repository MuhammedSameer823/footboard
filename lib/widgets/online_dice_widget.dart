// lib/widgets/online_dice_widget.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineDiceWidget extends StatefulWidget {
  final int diceRoll;
  final void Function(int)? onRollComplete;
  final String roomId;
  final String playerId;
  final bool isMyTurn;

  const OnlineDiceWidget({
    Key? key,
    required this.diceRoll,
    this.onRollComplete,
    required this.roomId,
    required this.playerId,
    required this.isMyTurn,
  }) : super(key: key);

  @override
  State<OnlineDiceWidget> createState() => _OnlineDiceWidgetState();
}

class _OnlineDiceWidgetState extends State<OnlineDiceWidget> {
  final Random random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRolling = false;
  int currentImageIndex = 0;
  int counter = 1;
  List<String> images = [
    'assets/dice1.png',
    'assets/dice2.png',
    'assets/dice3.png',
    'assets/dice4.png',
    'assets/dice5.png',
    'assets/dice6.png',
  ];

  Future<void> _playDiceSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(AssetSource('rolling-dice.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void rollDice() {
    // Only allow roll if not already rolling and it's this player's turn.
    if (isRolling || !widget.isMyTurn) return;

    setState(() {
      isRolling = true;
    });

    _playDiceSound();

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      counter++;
      setState(() {
        currentImageIndex = random.nextInt(6);
      });

      if (counter >= 13) {
        timer.cancel();
        counter = 1;
        setState(() {
          isRolling = false;
        });

        int finalRoll = currentImageIndex + 1;
        widget.onRollComplete?.call(finalRoll);
        _updateDiceRollInFirestore(finalRoll);
      }
    });
  }

  // Update the Firestore room document with the new dice roll and mark this player as the last that rolled.
  Future<void> _updateDiceRollInFirestore(int finalRoll) async {
    try {
      await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .update({
        'diceRoll': finalRoll,
        'lastRolledBy': widget.playerId,
        'diceRolling': false,
      });
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayIndex = isRolling ? currentImageIndex : widget.diceRoll - 1;

    // For online mode, we assume only the human can tap to roll (if it's their turn)
    return GestureDetector(
      onTap: rollDice,
      child: Transform.rotate(
        angle: random.nextDouble() * pi,
        child: Image.asset(
          images[displayIndex],
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}
