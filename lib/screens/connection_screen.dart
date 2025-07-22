import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teams.dart';
import '../models/online_player.dart'; // make sure this exists

class ConnectingScreen extends StatefulWidget {
  const ConnectingScreen({super.key});

  @override
  State<ConnectingScreen> createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen> {
  String? roomId;
  String? playerId;
  bool isHost = false;
  late Team selectedTeam;
  String mode = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    selectedTeam = args['selectedTeam'];
    mode = args['mode'];
  }

  @override
  void initState() {
    super.initState();
    connectToGame();
  }

  Future<void> connectToGame() async {
    playerId = FirebaseAuth.instance.currentUser?.uid;

    // Search for open room
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('rooms')
        .where('guestId', isEqualTo: null)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Join as guest
      final doc = snapshot.docs.first;
      roomId = doc.id;

      // 🔒 Check if room still exists before updating
      final existingRoom = await doc.reference.get();
      if (!existingRoom.exists) {
        print("⚠️ Room no longer exists. Creating new room instead.");
        return await connectToGame(); // retry as host
      }

      isHost = false;
      print('DEBUG: Joined existing room as guest. Room ID: $roomId');

      try {
        await doc.reference.update({
          'guestId': playerId,
          'guestTeam': selectedTeam.toMap(),
          'gameStarted': true,
          'diceRoll': 1,
          'lastRolledBy': null,
          'extraRoll': false,
          'diceRolling': false,
        });
      } catch (e) {
        print("🔥 Firestore update error when joining room: $e");
        return await connectToGame(); // fallback to host creation
      }
    } else {
      // Create new room as host
      isHost = true;
      final docRef = await FirebaseFirestore.instance.collection('rooms').add({
        'hostId': playerId,
        'guestId': null,
        'gameStarted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'hostTeam': selectedTeam.toMap(),
        'guestTeam': null,
        'diceRoll': 0,
        'lastRolledBy': null,
        'extraRoll': false,
        'diceRolling': false,
      });

      roomId = docRef.id;
      print('✅ Created new room as host: $roomId');
    }

    // Wait for both players and game start
    FirebaseFirestore.instance
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final hostTeamData = data['hostTeam'];
      final guestTeamData = data['guestTeam'];

      if (data['gameStarted'] == true &&
          hostTeamData != null &&
          guestTeamData != null &&
          mounted) {
        final OnlinePlayer mePlayer = isHost
            ? OnlinePlayer.fromFirestore(
                id: playerId!,
                roomId: roomId!,
                teamData: hostTeamData,
                mode: mode,
              )
            : OnlinePlayer.fromFirestore(
                id: playerId!,
                roomId: roomId!,
                teamData: guestTeamData,
                mode: mode,
              );

        final OnlinePlayer opponentPlayer = isHost
            ? OnlinePlayer.fromFirestore(
                id: data['guestId'],
                roomId: roomId!,
                teamData: guestTeamData,
                mode: mode,
              )
            : OnlinePlayer.fromFirestore(
                id: data['hostId'],
                roomId: roomId!,
                teamData: hostTeamData,
                mode: mode,
              );

        Navigator.pushReplacementNamed(
          context,
          '/ongame',
          arguments: {
            'roomId': roomId,
            'playerId': playerId,
            'isHost': isHost,
            'me': mePlayer,
            'opponent': opponentPlayer,
            'diceRoll': data['diceRoll'] ?? 1,
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '🔄 Connecting to another player...\n\nRoom ID: ${roomId ?? "Creating..."}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
