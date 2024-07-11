
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/ui/winner_screen.dart';

void navigateToCelebrationScreen(BuildContext context, String winner) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CelebrationScreen(winner: winner),
    ),
  );
}