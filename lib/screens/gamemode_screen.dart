import 'package:flutter/material.dart';
import 'package:football_ludo/interface/pallate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/constants.dart';

class GameModeScreen extends StatefulWidget {
  const GameModeScreen({super.key});
  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          Positioned(
            top: 40,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildIconButton(Icons.chevron_left, () {
                      Navigator.pop(context);
                    }),
                    buildIconButton(Icons.question_mark_outlined, () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 84, vertical: 12),
                  decoration: BoxDecoration(
                    color: Pallate.darkGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    "SELECT",
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: Pallate.lightcream,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildModeButton(
                  "AI",
                  "select",
                  Icons.computer_outlined,
                ),
                const SizedBox(
                  height: 25,
                ),
                buildModeButton("local", "select", Icons.people),
                const SizedBox(
                  height: 25,
                ),
                buildModeButton(" online", "", Icons.wifi),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildModeButton(
    String title,
    String move,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        print("Selected mode: $title");
        Navigator.pushNamed(context, '/$move', arguments: {
          'mode': title
        }); // Navigate or set state based on selected mode
      },
      child: Container(
        width: 280,
        height: 80,
        decoration: BoxDecoration(
          color: Pallate.lightcream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Pallate.darkGreen,
              offset: Offset(4, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Pallate.darkGreen,
              size: 32,
            ),
            const SizedBox(width: 24),
            Text(
              title,
              style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Pallate.darkGreen),
            )
          ],
        ),
      ),
    );
  }
}
