import 'package:flutter/material.dart';
import 'package:football_ludo/interface/pallate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),

          // Foreground UI
          Column(
            children: [
              const SizedBox(height: 25), // Top half: Game title and motto
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "FOOTBOARD",
                        style: GoogleFonts.bebasNeue(
                          fontSize: 84,
                          color: Pallate.lightcream,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              offset: Offset(3, 3),
                              color: Pallate.darkGreen,
                            ),
                          ],
                        ),
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Text(
                          "Roll the dice and fight for the lead",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Pallate.lightcream,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                offset: Offset(1.5, 1.5),
                                color: Pallate.darkGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Center play button
              Transform.translate(
                offset: const Offset(0, -14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Pallate.darkGreen,
                        offset: const Offset(6, 6), // Bottom-left direction
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallate.lightcream,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0, // Disable default uniform shadow
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/mode'); // Ensure this route is defined
                    },
                    child: Text(
                      "PLAY",
                      style: GoogleFonts.bebasNeue(
                        fontSize: 36,
                        color: Pallate.darkGreen,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom half: 2 rows
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row with trophy and person buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Trophy Button
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Pallate.lightcream,
                                  offset:
                                      const Offset(2, 1), // bottom-left shadow
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Pallate.darkGreen,
                                padding: EdgeInsets.zero,
                                fixedSize: const Size(72, 72), // exact square
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0, // use only boxShadow
                              ),
                              onPressed: () {
                                // TODO: Navigate to leaderboard
                              },
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                size: 32,
                                color: Pallate.lightcream,
                              ),
                            ),
                          ),
                        ),

                        // Person Button
                        Transform.translate(
                          offset: const Offset(0, -30),
                          child: Container(
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
                                padding: EdgeInsets.zero,
                                fixedSize: const Size(72, 72),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // TODO: Navigate to player profile
                              },
                              child: const Icon(
                                Icons.person_outline,
                                size: 32,
                                color: Pallate.lightcream,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Help Button (square with same shadow)
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: Container(
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
                            padding: EdgeInsets.zero,
                            fixedSize: const Size(72, 72),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // TODO: Show help or instructions
                          },
                          child: const Icon(
                            Icons.help_outline,
                            size: 32,
                            color: Pallate.lightcream,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
