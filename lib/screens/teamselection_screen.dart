import 'package:flutter/material.dart';
import 'package:football_ludo/interface/pallate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/teams.dart';
import '../widgets/constants.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen>
    with SingleTickerProviderStateMixin {
  // Assets and team names
  final List<Team> allTeams = [
    Team(
      name: 'Chelsea',
      logo: 'assets/che.png',
      shortName: 'CHE',
      color: Colors.blue,
    ),
    Team(
      name: 'Manchester United',
      logo: 'assets/utd.png',
      shortName: 'MUN',
      color: Colors.red,
    ),
    Team(
      name: 'arsnal',
      logo: 'assets/ars.png',
      shortName: 'ARS',
      color: Colors.red,
    ),
    Team(
      name: 'manchester city',
      logo: 'assets/cty.png',
      shortName: 'CTY',
      color: Colors.blue,
    ),
    Team(
      name: 'real Madrid',
      logo: 'assets/rma.png',
      shortName: 'RMA',
      color: Colors.white,
    ),
    Team(
      name: 'Barcelona',
      logo: 'assets/bar.png',
      shortName: 'BAR',
      color: Colors.red,
    ),
    // Add more teams...
  ];

  // Track selected team index for home and away teams separately
  int homeTeamIndex = 0;
  int awayTeamIndex = 0;
  late String mode;
  // Track whether we are selecting HOME or AWAY team
  bool selectingHomeTeam = true;

  // Animation controller and slide animation for transition between home/away

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    mode = args['mode'];
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // total duration
    );

    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0), // move left
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // jump to right
          end: Offset.zero, // slide in
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onArrowPressed(bool left) {
    setState(() {
      if (selectingHomeTeam) {
        if (left) {
          homeTeamIndex = (homeTeamIndex - 1) % allTeams.length;
          if (homeTeamIndex < 0) homeTeamIndex += allTeams.length;
        } else {
          homeTeamIndex = (homeTeamIndex + 1) % allTeams.length;
        }
      } else {
        if (left && selectingHomeTeam) {
          awayTeamIndex = (awayTeamIndex - 1) % allTeams.length;
          if (awayTeamIndex < 0) awayTeamIndex += allTeams.length;
        } else {
          awayTeamIndex = (awayTeamIndex + 1) % allTeams.length;
        }
      }
    });
  }

  void _onChoosePressed() async {
    if (selectingHomeTeam) {
      await _controller.forward(); // Slide out + in
      setState(() {
        selectingHomeTeam = false;
      });
      _controller.reset(); // Reset so it can animate again if needed
    } else {
      // Navigate to game screen with selected teams
      Navigator.pushNamed(
        context,
        '/game',
        arguments: {
          'homeTeam': allTeams[homeTeamIndex],
          'awayTeam': allTeams[awayTeamIndex],
          'mode': mode
        },
      );
    }
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Pallate.darkGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Pallate.lightcream,
            offset: Offset(2, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 28, color: Pallate.lightcream),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Stack(
            children: [
              // Background layout with top and bottom sections
              Column(
                children: [
                  // Top half
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 40),
                      child: Column(
                        children: [
                          // Row with Home and Help buttons
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
                          const SizedBox(height: 65),

                          // Centered HOME TEAM / AWAY TEAM text
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Pallate.darkGreen,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              selectingHomeTeam ? 'HOME TEAM' : 'AWAY TEAM',
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Pallate.lightcream,
                                shadows: [
                                  const Shadow(
                                    color: Colors.black54,
                                    blurRadius: 3,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 150),

                  // Bottom half
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _onChoosePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallate.lightcream,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 60, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 7,
                            ),
                            child: Text(
                              'CHOOSE',
                              style: GoogleFonts.bebasNeue(
                                fontSize: 32,
                                color: Pallate.darkGreen,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (index) {
                              bool isSelected =
                                  (selectingHomeTeam && index == 0) ||
                                      (!selectingHomeTeam && index == 1);

                              return GestureDetector(
                                onTap: () {
                                  bool shouldSwitch =
                                      (index == 0 && !selectingHomeTeam) ||
                                          (index == 1 && selectingHomeTeam);
                                  if (shouldSwitch) {
                                    _controller.forward().then((_) {
                                      setState(() {
                                        selectingHomeTeam = !selectingHomeTeam;
                                      });
                                      _controller.forward();
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 6),
                                  width: isSelected ? 24 : 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Pallate.lightcream
                                        : Pallate.lightcream.withAlpha(64),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Trophy & Person Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildIconButton(Icons.emoji_events_outlined, () {
                                Navigator.pop(context);
                              }),
                              buildIconButton(Icons.person_3_outlined, () {
                                Navigator.pop(context);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Center team logo card with arrows
              SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 48),
                          Container(
                            width: 250,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Pallate.lightcream,
                              borderRadius: BorderRadius.circular(48),
                              boxShadow: [
                                BoxShadow(
                                  color: Pallate.darkGreen,
                                  blurRadius: 1,
                                  offset: const Offset(6, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 24,
                                  left: 24,
                                  right: 24,
                                  bottom: 72,
                                  child: Image.asset(
                                    selectingHomeTeam
                                        ? allTeams[homeTeamIndex].logo
                                        : allTeams[awayTeamIndex].logo,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  bottom: 6,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    selectingHomeTeam
                                        ? allTeams[homeTeamIndex]
                                            .name
                                            .toUpperCase()
                                        : allTeams[awayTeamIndex]
                                            .name
                                            .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 36,
                                      color: Pallate.darkGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),

                      // Left Arrow
                      Positioned(
                        left: MediaQuery.of(context).size.width / 2 -
                            250 / 2 -
                            48 -
                            24,
                        child: _buildArrowButton(
                            Icons.chevron_left, () => _onArrowPressed(true)),
                      ),

                      // Right Arrow
                      Positioned(
                        right: MediaQuery.of(context).size.width / 2 -
                            250 / 2 -
                            48 -
                            24,
                        child: _buildArrowButton(
                            Icons.chevron_right, () => _onArrowPressed(false)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Slide animation overlay (for switching between HOME and AWAY team)
          // Using SlideTransition on the entire screen content could be done,
          // but here we are simulating with AnimationController and state changes
        ],
      ),
    );
  }
}
