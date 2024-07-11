import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:tic_tac_toe/ui/winner_screen.dart';
import 'dart:io';

import 'game_state.dart';

class TicTacToeViewModel extends ChangeNotifier {
  GameState _gameState = GameState(
    board: List.generate(3, (_) => List.generate(3, (_) => "")),
    currentPlayer: "X",
  );

  GameState get gameState => _gameState;

  Future<void> fetchGameState() async {
    try {
      final String response = await rootBundle.loadString('assets/game_state.json');
      final data = json.decode(response);
      _gameState = GameState.fromJson(data);
      notifyListeners();
    } catch (e) {
      print("Error loading game state: $e");
    }
  }

  Future<void> _writeGameStateToFile(GameState gameState) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/game_state.json');
      await file.writeAsString(json.encode(gameState.toJson()));
    } catch (e) {
      print("Error writing game state: $e");
    }
  }

  Future<void> makeMove(int row, int col, BuildContext context) async {
    if (_gameState.board[row][col].isEmpty && _gameState.winner == null) {
      final newBoard = _gameState.board.map((list) => List<String>.from(list)).toList();
      newBoard[row][col] = _gameState.currentPlayer;
      final nextPlayer = _gameState.currentPlayer == "X" ? "O" : "X";

      _gameState.board = newBoard;
      notifyListeners();

      final winnerResult = _checkWinner(newBoard);
      if (winnerResult != null) {
        _gameState.winner = _gameState.currentPlayer;
        _gameState.winningLine = winnerResult;

        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CelebrationScreen(winner: "Munesh with ${_gameState.winner}"),
            ),
          );
        });
      } else {
        _gameState.currentPlayer = nextPlayer;
      }

      await _writeGameStateToFile(_gameState);
      notifyListeners();
    }
  }

  void resetGame() {
    _gameState = GameState(
      board: List.generate(3, (_) => List.generate(3, (_) => "")),
      currentPlayer: "X",
    );
    notifyListeners();
  }

  List<int>? _checkWinner(List<List<String>> board) {
    // Define the winning lines
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6]             // Diagonals
    ];

    for (var line in lines) {
      final a = line[0], b = line[1], c = line[2];
      if (board[a ~/ 3][a % 3] == board[b ~/ 3][b % 3] &&
          board[a ~/ 3][a % 3] == board[c ~/ 3][c % 3] &&
          board[a ~/ 3][a % 3] != '') {
        return line;
      }
    }
    return null;
  }
}
