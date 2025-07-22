import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/online_player.dart';
import '../widgets/board_tile.dart';
import '../widgets/online_dice_widget.dart';
import '../interface/pallate.dart';
import 'winner_screen.dart';
import 'package:footboard/widgets/constants.dart';

class OnlineGameScreen extends StatefulWidget {
  const OnlineGameScreen({super.key});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  String roomId = '';
  String playerId = '';
  bool isHost = false;
  final bool check = true;
  late OnlinePlayer player1;
  late OnlinePlayer player2;
  late OnlinePlayer currentPlayer;
  late OnlinePlayer lastPlayer;
  OnlinePlayer? extraPlayer;
  OnlinePlayer? nonplayer; // to track who triggered extra roll
  int diceRoll = 1;
  bool isFreekickRoll = false;
  bool isPenaltyRoll = false;
  bool isCornerRoll = false;
  bool isExtraRoll = false;
  bool doubleRoll = false;
  String half = "1st -HALF";
  int extra = 7;
  int e = 0;
  Map<String, dynamic>? hostTeam;
  Map<String, dynamic>? guestTeam;

  // Track last processed dice roll to prevent duplicates
  int _lastProcessedDiceRoll = 0;
  String _lastProcessedRollerId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;

    roomId = args['roomId'];
    playerId = args['playerId'];
    isHost = args['isHost'];
    if (isHost) {
      player1 = args['me'];
      player2 = args['opponent'];
    } else {
      player2 = args['me'];
      player1 = args['opponent'];
    }
    currentPlayer = player1;
    lastPlayer = currentPlayer;

    // Start listening to dice changes after we have roomId
    _startListeningToDiceChanges();
  }

  Future<void> _deleteRoomIfExists() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();
      if (doc.exists) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .delete();
        print('✅ Room $roomId deleted.');
      }
    } catch (e) {
      print('❌ Failed to delete room: $e');
    }
  }

  void _startListeningToDiceChanges() {
    if (roomId.isEmpty) return; // Safety check

    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _processDiceRollChange(data);
      }
    });
  }

  void _processDiceRollChange(Map<String, dynamic> data) {
    final String lastRolledBy = data['lastRolledBy'] ?? '';
    final int newDiceRoll = data['diceRoll'] ?? 1;
    final bool diceRolling = data['diceRolling'] ?? false;

    // Only process if it's a new roll and dice has finished rolling
    bool isNewRoll = (newDiceRoll != _lastProcessedDiceRoll ||
        lastRolledBy != _lastProcessedRollerId);

    if (isNewRoll && !diceRolling && lastRolledBy.isNotEmpty) {
      print("🎯 Processing dice roll: $newDiceRoll by $lastRolledBy");

      // BOTH devices process the same game logic from Firebase data
      _processGameLogicFromFirebase(data, newDiceRoll, lastRolledBy);

      // Update tracking
      _lastProcessedDiceRoll = newDiceRoll;
      _lastProcessedRollerId = lastRolledBy;
    }
  }

  Future<void> _processGameLogicFromFirebase(
      Map<String, dynamic> data, int diceValue, String lastRolledBy) async {
    // Get current game state from Firebase
    final hostTeamData = data['hostTeam'] as Map<String, dynamic>?;
    final guestTeamData = data['guestTeam'] as Map<String, dynamic>?;

    // Determine which player rolled the dice
    OnlinePlayer rollingPlayer;
    if (lastRolledBy == player1.id) {
      rollingPlayer = player1;
      // Update player1 with current Firebase data
      if (hostTeamData != null) {
        player1.position = hostTeamData['position'] ?? 0;
        player1.score = hostTeamData['score'] ?? 0;
        player1.ref = hostTeamData['ref']?.toDouble() ?? 0.0;
        player1.work = hostTeamData['work'] ?? '';
      }
    } else {
      rollingPlayer = player2;
      // Update player2 with current Firebase data
      if (guestTeamData != null) {
        player2.position = guestTeamData['position'] ?? 0;
        player2.score = guestTeamData['score'] ?? 0;
        player2.ref = guestTeamData['ref']?.toDouble() ?? 0.0;
        player2.work = guestTeamData['work'] ?? '';
      }
    }

    // Process the game logic (SAME on both devices) - CALCULATE ONLY, DON'T UPDATE FIREBASE YET
    setState(() {
      print(
          '🎲 Both devices calculating dice: $diceValue for ${rollingPlayer.name}');

      // Get extraRoll status from Firebase
      final bool currentExtraRoll = data['extraRoll'] ?? false;
      final int evalue = data['purpleTileIndex'] ?? 0;
      if (evalue != e) {
        if (e < 2) e++;
        print("🔍^^^^^^^^ DEBUG - Extra time attempt: ${purpleTiles[e]}");
      }
      currentPlayer.work = "PLAY ONNN";
      // Calculate new position
      int newPos;
      if (currentExtraRoll) {
        if (isCornerRoll) {
          isCornerRoll = false;
          doubleRoll = false;
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
          doubleRoll = false;
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
          doubleRoll = false;
          if ([1, 3, 6].contains(diceRoll)) {
            currentPlayer.addPoints(1);
            currentPlayer.work = "GOALLLLL!!!!!!";
          } else {
            currentPlayer.work = "MISSED";
          }
          currentPlayer = (currentPlayer == player1) ? player2 : player1;
          return;
        }
      } else {
        newPos = rollingPlayer.position + diceValue;

        if (90 == purpleTiles[e]) {
          half = "2nd-half";
        }
        int pointe = purpleTiles[e];
        print("🔍####### DEBUG - Reset doubleRoll to: ${purpleTiles[e]}");
        if (newPos >= pointe) {
          rollingPlayer.moveTo(pointe);
          newPos = pointe;
        } else {
          rollingPlayer.moveTo(newPos);
        }

        // Reset doubleRoll before checking special tiles
        doubleRoll = false;
        print("🔍 DEBUG - Reset doubleRoll to: $doubleRoll");

        // Tile effects
        if (blueTiles.contains(newPos)) {
          rollingPlayer.addPoints(1);
          rollingPlayer.work = "GOALLLLL!!!!!!";
          print("🔍 DEBUG - Blue tile (GOAL): doubleRoll = $doubleRoll");
        } else if (redTiles.contains(newPos)) {
          rollingPlayer.subPoints(1);
          rollingPlayer.work = "RED CARD ||";
        } else if (yellowTiles.contains(newPos)) {
          rollingPlayer.addRef(.5);
          rollingPlayer.work = "YELLOW CARD || ";
          if (rollingPlayer.ref % 1 == 0 && rollingPlayer.ref != 0.0) {
            rollingPlayer.subPoints(1);
          }
        } else if (violetTiles.contains(newPos)) {
          rollingPlayer.moveTo(newPos - 2 * diceValue);
          rollingPlayer.work = "OFF SIDE //";
        }

        if (newPos == purpleTiles[e]) {
          // Check if we need to update extraPlayer tracking
          print("🔍+++++++ DEBUG - Extra time attempt: ${purpleTiles[e]}");
          final String currentExtraPlayerId = data['extraPlayerId'] ?? '';
          final String currentNonPlayerId = data['nonPlayerId'] ?? '';

          if (currentExtraPlayerId.isEmpty) {
            // First time hitting purple tile - set up extra roll
            extraPlayer = rollingPlayer;
            nonplayer = (rollingPlayer == player1) ? player2 : player1;
            extra = 7 - diceValue;
            rollingPlayer.work = "Extra Roll Activated! Need $extra!";

            print(
                "🔍 DEBUG - Purple tile hit! Setting up new extra roll for ${rollingPlayer.name}");
          } else {
            // There's already an active extra roll
            if (rollingPlayer.id == currentExtraPlayerId) {
              // Same player hit purple tile again - this is their extra roll attempt
              int diff = extra - diceValue;
              print(
                  "🔍 DEBUG - Extra roll attempt: need $extra, rolled $diceValue, diff: $diff");

              if (diff == 0) {
                rollingPlayer.addPoints(1);
                rollingPlayer.work = "GOALLLLL!!!!!!";
                // Clear extra roll - goal scored

                print(
                    "🔍 DEBUG - Extra roll SUCCESS! Goal scored, clearing extra roll");
              } else {
                extra = 7 - diceValue;
                rollingPlayer.work = "MISSED\\nNeed $extra!";
                // Continue extra roll
                print("🔍 DEBUG - Extra roll MISSED! Need $extra more");
              }
            } else if (rollingPlayer.id == currentNonPlayerId) {
              // Opponent reached the same purple tile - cancel extra roll
              extraPlayer = null;
              nonplayer = null;

              if (e < 2) e++;
              print("🔍@@@@@@ DEBUG - Extra time attempt: ${purpleTiles[e]}");
              rollingPlayer.work = "Extra Roll Cancelled!";
              print(
                  "🔍 DEBUG - Opponent reached purple tile! Extra roll cancelled");

              // Set doubleRoll to false since extra roll is cancelled
              doubleRoll = false;
            } else {
              // Different player hit purple tile - new extra roll setup
              extraPlayer = rollingPlayer;
              nonplayer = (rollingPlayer == player1) ? player2 : player1;
              extra = 7 - diceValue;
              rollingPlayer.work = "Extra Roll Activated! Need $extra!";

              print(
                  "🔍 DEBUG - New player hit purple tile! Setting up extra roll for ${rollingPlayer.name}");
            }
          }
          print(
              "🔍 DEBUG - Purple tile processing complete. doubleRoll = $doubleRoll");
        }

        final specialTiles = {
          ...{for (var tile in brownTiles) tile: "\tPENALTY\n1,3,6 to SCORE!!"},
          ...{for (var tile in orangeTiles) tile: "\tFREEKICK\n1/6 to SCORE!!"},
          ...{for (var tile in pinkTiles) tile: "\tCORNER\n6 to SCORE!!"},
        };

        if (specialTiles.containsKey(newPos)) {
          if (!currentExtraRoll) {
            doubleRoll = true;
          }
          rollingPlayer.work = specialTiles[newPos]!;
          print(
              "🔍 DEBUG - Special tile hit! Setting doubleRoll = $doubleRoll");
          if (brownTiles.contains(newPos)) {
            isPenaltyRoll = true;
            print("🔍 DEBUG - Penalty tile");
          }
          if (orangeTiles.contains(newPos)) {
            isFreekickRoll = true;
            print("🔍 DEBUG - Freekick tile");
          }
          if (pinkTiles.contains(newPos)) {
            isCornerRoll = true;
            print("🔍 DEBUG - Corner tile");
          }
        }

        print(
            "🔍 DEBUG - Final doubleRoll value before Firebase update: $doubleRoll");
      }
    });

    // ONLY the device that rolled the dice updates Firebase with calculated results
    if (lastRolledBy == playerId) {
      print("🔍 DEBUG - This device rolled the dice, updating Firebase...");
      print("🔍 DEBUG - Updating extraRoll to Firebase: $doubleRoll");
      try {
        final teamField =
            (lastRolledBy == player1.id) ? 'hostTeam' : 'guestTeam';

        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(roomId)
            .update({
          'extraRoll': doubleRoll,
          'extraPlayerId': extraPlayer?.id ?? '',
          'nonPlayerId': nonplayer?.id ?? '',
          'extraNeeded': extra,
          'purpleTileIndex': e,
          teamField: {
            'position': rollingPlayer.position,
            'score': rollingPlayer.score,
            'ref': rollingPlayer.ref,
            'work': rollingPlayer.work,
          },
          'gameStateUpdated': DateTime.now().millisecondsSinceEpoch,
        });

        print("✅ Game state updated to Firebase by rolling player");
        print("🔍 DEBUG - Firebase updated with extraRoll: $doubleRoll");
      } catch (e) {
        print("❌ Error updating game state: $e");
      }
    } else {
      print("📱 Other device calculated but didn't update Firebase");
      print("🔍 DEBUG - Other device calculated doubleRoll: $doubleRoll");
    }

    // Win check
    if (player1.position == 90 && player2.position == 90) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WinnerScreen(player: rollingPlayer)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // _startListeningToDiceChanges() is called in didChangeDependencies after roomId is set
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _deleteRoomIfExists();
        return true; // Allow back navigation
      },
      child: Scaffold(
        body: roomId.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(roomId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final int diceRoll = data['diceRoll'] ?? 1;
                  final String lastRolledBy = data['lastRolledBy'] ?? '';
                  final bool extraRoll = data['extraRoll'] ?? false;

                  // Determine who can roll next based on extraRoll
                  bool isMyTurn;
                  if (extraRoll && lastRolledBy.isNotEmpty) {
                    // If there's an extra roll, same player rolls again
                    isMyTurn = (lastRolledBy == playerId);
                    print(
                        "🔍 DEBUG - Extra roll active, same player rolls: isMyTurn = $isMyTurn");
                  } else {
                    // Normal turn switching
                    isMyTurn = (lastRolledBy != playerId);
                    print(
                        "🔍 DEBUG - Normal turn switching: isMyTurn = $isMyTurn");
                  }

                  // Get real-time data from Firebase
                  final hostTeamData =
                      data['hostTeam'] as Map<String, dynamic>?;
                  final guestTeamData =
                      data['guestTeam'] as Map<String, dynamic>?;

                  // Update local player objects with Firebase data
                  if (hostTeamData != null) {
                    player1.position = hostTeamData['position'] ?? 0;
                    player1.score = hostTeamData['score'] ?? 0;
                    player1.ref = hostTeamData['ref']?.toDouble() ?? 0.0;
                    player1.work = hostTeamData['work'] ?? '';
                  }

                  if (guestTeamData != null) {
                    player2.position = guestTeamData['position'] ?? 0;
                    player2.score = guestTeamData['score'] ?? 0;
                    player2.ref = guestTeamData['ref']?.toDouble() ?? 0.0;
                    player2.work = guestTeamData['work'] ?? '';
                  }

                  // Update current player based on extraRoll from Firebase
                  final String extraPlayerId = data['extraPlayerId'] ?? '';
                  final String nonPlayerId = data['nonPlayerId'] ?? '';
                  final int extraNeeded = data['extraNeeded'] ?? 7;
                  final int purpleTileIndex = data['purpleTileIndex'] ?? 0;

                  // Sync extra roll state with Firebase
                  if (extraPlayerId.isNotEmpty && nonPlayerId.isNotEmpty) {
                    extraPlayer =
                        (extraPlayerId == player1.id) ? player1 : player2;
                    nonplayer = (nonPlayerId == player1.id) ? player1 : player2;
                    extra = extraNeeded;
                    e = purpleTileIndex;
                  } else {
                    extraPlayer = null;
                    nonplayer = null;
                  }

                  print("🔍 DEBUG - extraRoll from Firebase: $extraRoll");
                  print("🔍 DEBUG - extraPlayerId: $extraPlayerId");
                  print("🔍 DEBUG - nonPlayerId: $nonPlayerId");
                  print("🔍 DEBUG - lastRolledBy: $lastRolledBy");
                  print("🔍 DEBUG - Full Firebase data: ${data.keys}");

                  if (lastRolledBy.isNotEmpty) {
                    if (extraRoll) {
                      // If extraRoll is true, keep the same current player (who just rolled)
                      currentPlayer =
                          (lastRolledBy == player1.id) ? player1 : player2;
                      print(
                          "🔍 DEBUG - Extra roll TRUE, keeping same player: ${currentPlayer.name}");
                    } else {
                      // If no extra roll, switch to the other player
                      currentPlayer =
                          (lastRolledBy == player1.id) ? player2 : player1;
                      print(
                          "🔍 DEBUG - Extra roll FALSE, switching to: ${currentPlayer.name}");
                    }
                    lastPlayer =
                        (lastRolledBy == player1.id) ? player1 : player2;
                    print("🔍 DEBUG - lastPlayer set to: ${lastPlayer.name}");
                  }

                  // The new system handles game updates through _processDiceRollChange
                  // No need to call rollDice here anymore
                  // Build board tiles
                  List<Widget> tiles = [];
                  bool leftToRight = true;
                  for (int row = 8; row >= 0; row--) {
                    List<Widget> rowTiles = [];
                    for (int col = 0; col < 10; col++) {
                      int number = row * 10 + col + 1;
                      List<OnlinePlayer> playersOnTile = [];
                      if (player1.position == number)
                        playersOnTile.add(player1);
                      if (player2.position == number)
                        playersOnTile.add(player2);

                      rowTiles.add(
                        Padding(
                          padding: const EdgeInsets.all(1),
                          child: BoardTile(
                            number: number,
                            playersOnTile: playersOnTile,
                            borderRadius: 8,
                          ),
                        ),
                      );
                    }
                    if (!leftToRight) rowTiles = rowTiles.reversed.toList();
                    tiles.addAll(rowTiles);
                    leftToRight = !leftToRight;
                  }

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset('assets/bg.png', fit: BoxFit.cover),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 54.0, vertical: 16),
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Pallate.darkGreen.withAlpha(128),
                                borderRadius: BorderRadius.circular(16),
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
                          SizedBox(
                            height: 400,
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
                                  width: 400,
                                  height: 360,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: GridView.count(
                                      crossAxisCount: 10,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: tiles,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                            color: Pallate
                                                .lightcream, // Shadow color
                                            blurRadius:
                                                1, // Softness of the shadow
                                            offset: Offset(
                                                4, 4), // Position of the shadow
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
                                            color: Pallate
                                                .lightcream, // Shadow color
                                            blurRadius:
                                                1, // Softness of the shadow
                                            offset: Offset(
                                                4, 4), // Position of the shadow
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 75,
                                      height: 75,
                                      padding: const EdgeInsets.all(4),
                                      child: OnlineDiceWidget(
                                        roomId: roomId,
                                        playerId: playerId,
                                        diceRoll: diceRoll,
                                        isMyTurn: isMyTurn,
                                        onRollComplete: (rolledValue) {
                                          print(
                                              "🎲 Dice roll completed: $rolledValue");
                                          // The dice widget will update Firebase with basic roll data ONLY
                                          // Game screen will handle extraRoll updates separately
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
                  );
                },
              ),
      ),
    );
  }

  Widget _buildScoreCard(OnlinePlayer player) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 100,
      height: 150,
      color: Colors.transparent,
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
                color: Color(0xFFEFFCD9)),
          ),
          Text(
            "${player.ref}",
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _deleteRoomIfExists();

    super.dispose();
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
          Text("1ST HALF",
              style: GoogleFonts.bebasNeue(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text("V/S",
              style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  color: Pallate.lightcream,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Score:",
              style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  color: Pallate.lightcream,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Warning",
              style: GoogleFonts.bebasNeue(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
