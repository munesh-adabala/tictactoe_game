import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/ui/game_ui.dart';
import 'package:tic_tac_toe/viewmodel.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TicTacToeViewModel()..fetchGameState(),
      child: MaterialApp(
        title: 'Tic Tac Toe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TicTacToeGame(),
      ),
    );
  }
}