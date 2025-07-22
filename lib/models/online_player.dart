import 'package:flutter/material.dart';
import '../models/player.dart';

class OnlinePlayer extends Player {
  final String id;
  final String roomId;

  OnlinePlayer({
    required this.id,
    required this.roomId,
    required super.name,
    required super.color,
    required super.logo,
    required super.mode,
    super.position,
    super.score,
    super.ref,
    super.work,
  });

  factory OnlinePlayer.fromMap(Map<String, dynamic> map) {
    return OnlinePlayer(
      id: map['id'],
      roomId: map['roomId'],
      name: map['name'],
      position: map['position'] ?? 1,
      score: map['score'] ?? 0,
      ref: (map['ref'] ?? 0).toDouble(),
      color: Color(map['color']),
      work: map['work'] ?? "PLAY ON",
      logo: map['logo'],
      mode: map['mode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'name': name,
      'position': position,
      'score': score,
      'ref': ref,
      'color': color.value,
      'work': work,
      'logo': logo,
      'mode': mode,
    };
  }

  factory OnlinePlayer.fromFirestore({
    required String id,
    required String roomId,
    required Map teamData,
    required String mode,
  }) {
    return OnlinePlayer(
      id: id,
      roomId: roomId,
      name: teamData['name'],
      color: Color(teamData['color']),
      logo: teamData['logo'],
      mode: mode,
    );
  }
}
