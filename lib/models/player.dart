import 'package:flutter/material.dart';

class Player {
  final String name;
  int position;
  int score;
  double ref;
  final Color color;
  String work;
  final String logo;
  final String mode;
  Player({
    required this.name,
    this.position = 1,
    this.score = 0,
    this.ref = 0.0,
    required this.color,
    this.work = "PLAY ON",
    required this.logo,
    required this.mode,
  });

  void moveTo(int newPosition) {
    position = newPosition;
  }

  void addPoints(int points) {
    score += points;
  }

  void subPoints(int points) {
    if (score != 0) {
      score -= points;
    }
  }

  void addRef(double refer) {
    ref += refer;
  }
}
