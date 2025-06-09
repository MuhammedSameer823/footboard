// lib/widgets/dice_widget.dart

import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';

class DiceWidget extends StatefulWidget {
  final bool isAI;
  final Function(int) onRollComplete;
  final Object currentPlayer;

  DiceWidget({
    required this.isAI,
    required this.onRollComplete,
    required this.currentPlayer,
  }) {
    print({"$isAI"});
  }

  @override
  _DiceWidgetState createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with TickerProviderStateMixin {
  int diceValue = 1;
  bool isRolling = false;
  Timer? autoRollTimer;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 4 * 3.14159, // 2 full rotations
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto roll for AI when it's their turn
    if (widget.isAI && !isRolling) {
      _startAutoRoll();
    }
  }

  void _startAutoRoll() {
    if (autoRollTimer?.isActive == true) return;

    autoRollTimer = Timer(Duration(milliseconds: 1500), () {
      _rollDice();
    });
  }

  void _rollDice() async {
    if (isRolling) return;

    setState(() {
      isRolling = true;
    });

    _animationController.reset();
    _animationController.forward();

    // Simulate rolling animation
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          diceValue = Random().nextInt(6) + 1;
        });
      }
    }

    // Final dice value
    final finalValue = Random().nextInt(6) + 1;
    setState(() {
      diceValue = finalValue;
      isRolling = false;
    });

    // Wait a bit to show the result
    await Future.delayed(Duration(milliseconds: 500));

    if (mounted) {
      widget.onRollComplete(finalValue);
    }
  }

  String _getDiceEmoji(int value) {
    switch (value) {
      case 1:
        return '⚀';
      case 2:
        return '⚁';
      case 3:
        return '⚂';
      case 4:
        return '⚃';
      case 5:
        return '⚄';
      case 6:
        return '⚅';
      default:
        return '⚀';
    }
  }

  @override
  void dispose() {
    autoRollTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dice Display
          GestureDetector(
            onTap: widget.isAI || isRolling ? null : _rollDice,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: isRolling ? _rotationAnimation.value : 0,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getDiceEmoji(diceValue),
                        style: TextStyle(
                          fontSize: 60,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Dice Value
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              'Value: $diceValue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Instructions
          if (widget.isAI)
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50]!,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, color: Colors.blue[600]!),
                  SizedBox(width: 10),
                  Text(
                    isRolling
                        ? 'AI is rolling...'
                        : 'AI will roll automatically',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[800]!,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[50]!,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.green[600]!),
                  SizedBox(width: 10),
                  Text(
                    isRolling ? 'Rolling...' : 'Tap the dice to roll',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green[800]!,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
