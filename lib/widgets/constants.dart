import 'package:flutter/material.dart';
import '../interface/pallate.dart';

const List<int> blueTiles = [8, 43, 72, 89];
const List<int> yellowTiles = [14, 33, 76, 62, 88];
const List<int> redTiles = [27, 54, 81];
const List<int> orangeTiles = [16, 32, 48, 64, 80];
const List<int> pinkTiles = [5, 20, 35, 50, 65, 85];
const List<int> brownTiles = [6, 36, 66];
const List<int> violetTiles = [29, 55, 83, 63, 34, 78];
const List<int> purpleTiles = [10, 45, 90, 91];

Widget buildIconButton(IconData icon, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Pallate.lightcream,
          offset: const Offset(2, 1),
          blurRadius: 1,
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallate.darkGreen,
        fixedSize: const Size(72, 72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.zero,
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Center(
        child: Icon(
          icon,
          size: 36,
          color: Pallate.lightcream,
        ),
      ),
    ),
  );
}
