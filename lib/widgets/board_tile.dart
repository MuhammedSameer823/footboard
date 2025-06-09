// lib/widgets/board_tile.dart
import 'constants.dart';
import 'package:flutter/material.dart';
import 'pawn_widget.dart';
import '../interface/pallate.dart';
import '../models/player.dart'; // adjust path as needed

class BoardTile extends StatelessWidget {
  final int number;
  final List<Player> playersOnTile;
  final double borderRadius;
  const BoardTile({
    super.key,
    required this.number,
    required this.playersOnTile,
    this.borderRadius = 0,
  });
  @override
  Widget build(BuildContext context) {
    Color tileColor;

    // List of special blue tiles
    if (blueTiles.contains(number)) {
      tileColor = Colors.blue[300]!;
    } else if (orangeTiles.contains(number)) {
      tileColor = Colors.orange[300]!;
    } else if (pinkTiles.contains(number)) {
      tileColor = Colors.pink[300]!;
    } else if (yellowTiles.contains(number)) {
      tileColor = Colors.yellow[300]!;
    } else if (brownTiles.contains(number)) {
      tileColor = Colors.brown[300]!;
    } else if (redTiles.contains(number)) {
      tileColor = Colors.red[300]!;
    } else if (purpleTiles.contains(number)) {
      tileColor = Colors.purple[300]!;
    } else if (violetTiles.contains(number)) {
      tileColor = Colors.indigo[300]!;
    } else {
      tileColor = Pallate.lightcream;
    }

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              number.toString(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          ...playersOnTile.asMap().entries.map((entry) {
            int index = entry.key;
            Player player = entry.value;

            return Positioned(
              bottom: 4,
              left: 4.0 + index * 18,
              child: PawnWidget(color: player.color),
            );
          }).toList(),
        ],
      ),
    );
  }
}
