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
}

final List<Team> allTeams = [
  Team(
    name: 'Manchester United',
    logo: 'assets/utd.png',
    shortName: 'MUN',
    color: Colors.red,
  ),
  Team(
    name: 'Chelsea',
    logo: 'assets/che.png',
    shortName: 'CHE',
    color: Colors.blue,
  ),
  // Add more teams...
];
