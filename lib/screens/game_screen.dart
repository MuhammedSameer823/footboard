// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:football_ludo/interface/pallate.dart';
import 'dart:math';
import '../models/player.dart';
import '../widgets/board_tile.dart';
import '../widgets/dice_widget.dart';
import '../widgets/dice_3d.dart';
import '../models/teams.dart';
import 'winner_screen.dart';
import 'package:football_ludo/widgets/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Player player1;
  late final Player player2;
  late Player currentPlayer;
  late Player lastPlayer;
  Player? extraPlayer;
  Player? nonplayer; // to track who triggered extra roll

  int diceRoll = 1;
  bool isFreekickRoll = false;
  bool isPenaltyRoll = false;
  bool isCornerRoll = false;
  bool isExtraRoll = false;
  String half = "1st -HALF";
  int extra = 7;
  int e = 0;
  // Ensure we run it only once

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Team homeTeam = args['homeTeam'];
    final Team awayTeam = args['awayTeam'];

    player1 = Player(
      name: homeTeam.name,
      color: homeTeam.color,
      logo: homeTeam.logo,
      mode: "local",
    );
    player2 = Player(
        name: awayTeam.name,
        color: awayTeam.color,
        logo: awayTeam.logo,
        mode: args['mode']);

    currentPlayer = player1;
    lastPlayer = currentPlayer;
  }

  void rollDice() {
    setState(() {
      currentPlayer.work = "PLAY ONNN";
      diceRoll = Random().nextInt(6) + 1;
      int newPos = currentPlayer.position;

      if (extraPlayer == currentPlayer) {
        String lname = nonplayer!.name;
        String cname = extraPlayer!.name;
        isExtraRoll = true;
        print("extra : $cname----non:$lname");

        // ❌ Cancel if opponent reached the same tile
        if (nonplayer?.position == purpleTiles[e]) {
          if (e < 2) e++;
          extraPlayer = null;
          nonplayer = null;
          isExtraRoll = false;
          currentPlayer = (currentPlayer == player1) ? player2 : player1;
          lastPlayer = (currentPlayer == player1) ? player2 : player1;
        }

        currentPlayer = (currentPlayer == player1) ? player2 : player1;
        lastPlayer = (currentPlayer == player1) ? player2 : player1;
        // ✅ If it's the extra roll player’s turn

        print("extra : $cname----non:$lname");
        if (isExtraRoll) {
          int diff = extra - diceRoll;
          print("extra Roll->$diff");
          if (diff == 0) {
            extraPlayer!.addPoints(1);
            extraPlayer!.work = "GOALLLLL!!!!!!";
          } else {
            extra = 7 - diceRoll;
            extraPlayer!.work = "MISSED\nNeed $extra!";
          }
          return;
        }
        // ✅ If opponent’s turn, let them move normally
      }

      if (isCornerRoll) {
        isCornerRoll = false;
        if ([6].contains(diceRoll)) {
          currentPlayer.addPoints(1);
          currentPlayer.work = "GOALLLLL!!!!!!";
        } else {
          currentPlayer.work = "MISSED";
        }
        currentPlayer = (currentPlayer == player1) ? player2 : player1;
        return;
      }

      if (isFreekickRoll == true) {
        isFreekickRoll = false;
        if ([1, 6].contains(diceRoll)) {
          currentPlayer.addPoints(1);
          currentPlayer.work = "GOALLLLL!!!!!!";
        } else {
          currentPlayer.work = "MISSED";
        }
        currentPlayer = (currentPlayer == player1) ? player2 : player1;
        return;
      }

      if (isPenaltyRoll == true) {
        isPenaltyRoll = false;
        if ([1, 3, 6].contains(diceRoll)) {
          currentPlayer.addPoints(1);
          currentPlayer.work = "GOALLLLL!!!!!!";
        } else {
          currentPlayer.work = "MISSED";
        }
        currentPlayer = (currentPlayer == player1) ? player2 : player1;
        return;
      }
      if (90 == purpleTiles[e]) {
        half = "2nd-half";
      }
      newPos = currentPlayer.position + diceRoll;
      print("pos$newPos");
      int pointe = purpleTiles[e];
      if (newPos >= pointe) {
        print("check point $pointe, pos:$newPos");
        currentPlayer.moveTo(pointe);
        newPos = pointe;
      } else {
        currentPlayer.moveTo(newPos);
      }
      if (blueTiles.contains(newPos)) {
        currentPlayer.addPoints(1);
        currentPlayer.work = "GOALLLLL!!!!!!";
      }
      if (redTiles.contains(newPos)) {
        currentPlayer.subPoints(1);
        currentPlayer.work = "RED CARD ||";
      }

      if (yellowTiles.contains(newPos)) {
        currentPlayer.addRef(.5);
        currentPlayer.work = "YELLOW CARD || ";
        if (currentPlayer.ref % 1 == 0 && currentPlayer.ref != 0.0) {
          currentPlayer.subPoints(1);
        }
      }
      if (violetTiles.contains(newPos)) {
        currentPlayer.moveTo(newPos - 2 * diceRoll);
        currentPlayer.work = "OFF SIDE //";
      }
      if (newPos == purpleTiles[e]) {
        extraPlayer ??= currentPlayer;
        nonplayer ??= lastPlayer;
        // ✅ Store who activated it
        extra = 7 - diceRoll;
        currentPlayer.work = "Extra Roll Activated! Need $extra!";
        // Player does NOT move now
      }

      final specialTiles = {
        ...{for (var tile in brownTiles) tile: "\tPENALTY\n1,3,6 to SCORE!!"},
        ...{for (var tile in orangeTiles) tile: "\tFREEKICK\n1/6 to SCORE!!"},
        ...{for (var tile in pinkTiles) tile: "\tCORNER\n6 to SCORE!!"},
      };

      if (specialTiles.containsKey(newPos)) {
        lastPlayer = currentPlayer;
        currentPlayer.work = specialTiles[newPos]!;
        if (brownTiles.contains(newPos)) {
          isPenaltyRoll = true;
        }
        if (orangeTiles.contains(newPos)) {
          isFreekickRoll = true;
        }
        if (pinkTiles.contains(newPos)) {
          isCornerRoll = true;
        }
      } else {
        currentPlayer = (currentPlayer == player1) ? player2 : player1;
        lastPlayer = (currentPlayer == player1) ? player2 : player1;
      }

      if (player1.position == 90 && player2.position == 90) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WinnerScreen(player: currentPlayer),
          ),
        );
        return;
      }
    });
  }

  Widget _buildScoreCard(Player player) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 100,
      height: 150,
      color: Colors.transparent, // Transparent background
      child: Column(
        children: [
          const SizedBox(height: 2),
          CircleAvatar(
            backgroundColor: const Color(0xFFEFFCD9),
            radius: 30,
            child: Image.asset(
              player.logo,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${player.score}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEFFCD9),
            ),
          ),
          Text(
            "${player.ref}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _middleCard() {
    return Container(
      width: 100,
      height: 150,
      padding: const EdgeInsets.all(1),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            half,
            style: GoogleFonts.bebasNeue(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "V/S", // replace with your dynamic score if needed
            style: GoogleFonts.bebasNeue(
              fontSize: 36,
              color: Pallate.lightcream,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Score:", // replace with your dynamic score if needed
            style: GoogleFonts.bebasNeue(
              fontSize: 18,
              color: Pallate.lightcream,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Warning",
            style: GoogleFonts.bebasNeue(
              fontSize: 14,
              color: Colors.red,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    bool leftToRight = true;

    for (int row = 8; row >= 0; row--) {
      List<Widget> rowTiles = [];
      for (int col = 0; col < 10; col++) {
        int number = row * 10 + col + 1;

        List<Player> playersOnTile = [];
        if (player1.position == number) playersOnTile.add(player1);
        if (player2.position == number) playersOnTile.add(player2);

        rowTiles.add(
          Padding(
            padding: const EdgeInsets.all(1), // small spacing around each tile
            child: BoardTile(
              number: number,
              playersOnTile: playersOnTile,
              borderRadius:
                  8, // add this param to round corners inside BoardTile
            ),
          ),
        );
      }

      if (!leftToRight) {
        rowTiles = rowTiles.reversed.toList();
      }

      tiles.addAll(rowTiles);
      leftToRight = !leftToRight;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("LUDO FOOTBALL GAME"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🖼 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png', // 🔁 Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Score Cards
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 54.0, vertical: 16),
                child: Container(
                  padding:
                      const EdgeInsets.all(1), // padding inside the big box
                  decoration: BoxDecoration(
                    color: Pallate.darkGreen
                        .withAlpha(128), // semi-transparent white bg
                    borderRadius: BorderRadius.circular(16), // rounded corners
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildScoreCard(player1),
                      _middleCard(),
                      _buildScoreCard(player2),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Game Board
              SizedBox(
                height: 400, // 36px * 9 rows + padding/spacing
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Pallate.darkGreen.withAlpha(128),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: SizedBox(
                      width: 400, // 36px * 10 columns
                      height: 360, // 36px * 9 rows
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            16), // Adjust the radius as needed
                        child: GridView.count(
                          crossAxisCount: 10,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: tiles,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Dice Button
              // Replace the existing dice section in your build method with this:

// Dice Section with new design
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Player Turn and Last Player Work
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Left Square Box - Current Turn
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: currentPlayer.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Pallate.lightcream, // Shadow color
                                blurRadius: 1, // Softness of the shadow
                                offset: Offset(4, 4), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "${currentPlayer.name.toUpperCase()}'S\nTURN",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Right Square Box - Last Player Work
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: lastPlayer.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Pallate.lightcream, // Shadow color
                                blurRadius: 1, // Softness of the shadow
                                offset: Offset(4, 4), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              lastPlayer.work,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Row 2: Center Dice
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          padding: const EdgeInsets.all(4),
                          child: Dice3DWidget(
                            key: ValueKey(
                                "${currentPlayer.name}_${currentPlayer.mode}_${DateTime.now()}"),
                            diceRoll: diceRoll,
                            mode: currentPlayer.mode,
                            onRollComplete: (rolledNumber) {
                              print("pass mode: ${currentPlayer.mode}");
                              print("Dice rolled: $rolledNumber");
                              String lname = lastPlayer.name;
                              String cname = currentPlayer.name;
                              print("currnet : $cname----last:$lname");
                              setState(() {
                                diceRoll = rolledNumber;
                                rollDice(); // game logic here
                              });
                            },
                          ),
                        ),
                      ],
                    ),
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
