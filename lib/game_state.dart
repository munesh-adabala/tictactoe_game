enum GameMode { local, online }

class GameState {
  List<List<String>> board;
  String currentPlayer;
  String? winner;
  List<int>? winningLine;
  GameMode gameMode;

  GameState({
    required this.board,
    required this.currentPlayer,
    this.winner,
    this.winningLine,
    required this.gameMode,
  });

  Map<String, dynamic> toJson() => {
    'board': board,
    'currentPlayer': currentPlayer,
    'winner': winner,
    'winningLine': winningLine,
    'gameMode': gameMode.toString().split('.').last,
  };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
    board: List<List<String>>.from(json['board'].map((row) => List<String>.from(row))),
    currentPlayer: json['currentPlayer'],
    winner: json['winner'],
    winningLine: json['winningLine'] != null ? List<int>.from(json['winningLine']) : null,
    gameMode: GameMode.values.firstWhere((e) => e.toString().split('.').last == json['gameMode']),
  );
}
