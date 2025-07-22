import 'package:flutter/material.dart';

class Team {
  final String name;
  final String logo;
  final String shortName;
  final Color color;

  Team({
    required this.name,
    required this.logo,
    required this.shortName,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo': logo,
      'color': color.value, // ✅ Store as int
      'shortName': shortName,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
      color: Color(map['color'] ?? 0xFFFFFFFF), // ✅ Restore from int
      shortName: map['shortName'] ?? '',
    );
  }
}
