import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tic_tac_toe/ui/winner_screen.dart';
import 'dart:io';

import 'game_state.dart';

class TicTacToeViewModel extends ChangeNotifier {
  GameState _gameState = GameState(
    board: List.generate(3, (_) => List.generate(3, (_) => "")),
    currentPlayer: "X",
    gameMode: GameMode.local,
  );

  GameState get gameState => _gameState;

  Timer? _pollingTimer;

  Future<void> fetchGameState() async {
    try {
      final String response =
          await rootBundle.loadString('assets/game_state.json');
      final data = json.decode(response);
      _gameState = GameState.fromJson(data);
      notifyListeners();
    } catch (e) {
      print("Error loading game state: $e");
    }
  }

  Future<void> fetchOnlineGameState() async {
    if (_gameState.gameMode == GameMode.online) {
      try {
        final response =
            await http.get(Uri.parse('https://tictactoe/base/player2/data'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _gameState = GameState.fromJson(data);
          notifyListeners();
        } else {
          print("Error fetching online game state: ${response.body}");
        }
      } catch (e) {
        print("Error fetching online game state: $e");
      }
    }
  }

  Future<void> _writeGameStateToFile(GameState gameState) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/game_state.json');
      print(gameState.toJson().toString());
      await file.writeAsString(json.encode(gameState.toJson()));
    } catch (e) {
      print("Error writing game state: $e");
    }
  }

  Future<void> makeMove(int row, int col, BuildContext context) async {
    if (_gameState.board[row][col].isEmpty && _gameState.winner == null) {
      if (_gameState.gameMode == GameMode.local) {
        _makeLocalMove(row, col, context);
      } else {
        await _makeOnlineMove(row, col, context);
      }
    }
  }

  Future<void> _makeLocalMove(int row, int col, BuildContext context) async {
    final newBoard =
        _gameState.board.map((list) => List<String>.from(list)).toList();
    newBoard[row][col] = _gameState.currentPlayer;
    final nextPlayer = _gameState.currentPlayer == "X" ? "O" : "X";

    _gameState.board = newBoard;
    notifyListeners();

    final winnerResult = _checkWinner(newBoard);
    if (winnerResult != null) {
      _gameState.winner = _gameState.currentPlayer;
      _gameState.winningLine = winnerResult;
      notifyListeners();

      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CelebrationScreen(winner: _gameState.winner!),
          ),
        );
      });
    } else {
      _gameState.currentPlayer = nextPlayer;
    }

    await _writeGameStateToFile(_gameState);
    notifyListeners();
  }

  Future<void> _makeOnlineMove(int row, int col, BuildContext context) async {
    final newBoard =
        _gameState.board.map((list) => List<String>.from(list)).toList();
    newBoard[row][col] = _gameState.currentPlayer;

    final response = await http.post(
      Uri.parse('https://tictactoe/base/player2/data'),
      body: json
          .encode({'row': row, 'col': col, 'player': _gameState.currentPlayer}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final nextPlayer = _gameState.currentPlayer == "X" ? "O" : "X";

      _gameState.board = newBoard;
      notifyListeners();

      final winnerResult = _checkWinner(newBoard);
      if (winnerResult != null) {
        _gameState.winner = _gameState.currentPlayer;
        _gameState.winningLine = winnerResult;
        notifyListeners();

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  CelebrationScreen(winner: _gameState.winner!),
            ),
          );
        });
      } else {
        _gameState.currentPlayer = nextPlayer;
      }

      await _writeGameStateToFile(_gameState);
      notifyListeners();
    } else {
      // Handle error
      print("Error making online move: ${response.body}");
      Fluttertoast.showToast(
        msg: "Move Failed!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  void resetGame() {
    _gameState = GameState(
      board: List.generate(3, (_) => List.generate(3, (_) => "")),
      currentPlayer: "X",
      gameMode: _gameState.gameMode,
    );
    notifyListeners();
  }

  List<int>? _checkWinner(List<List<String>> board) {
    // Define the winning lines
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6] // Diagonals
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

  void setGameMode(GameMode mode) {
    _gameState.gameMode = mode;
    notifyListeners();

    if (mode == GameMode.online) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      fetchOnlineGameState();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
