import 'package:flutter/material.dart';
import 'gameScreen.dart';

class ComputerPlayer extends StatelessWidget {
  const ComputerPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChainReactionGame(
      playerCount: 2,
      playerSelectColors: [
        Colors.blue, // Human
        Colors.red, // Computer
      ],
      isComputerMode: true, // 🔥 NEW PARAM
    );
  }
}
