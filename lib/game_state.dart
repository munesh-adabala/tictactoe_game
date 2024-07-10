class GameState {
  List<List<String>> board;
  String currentPlayer;
  String? winner;
  List<int>? winningLine;

  GameState({
    required this.board,
    required this.currentPlayer,
    this.winner,
    this.winningLine,
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      board: (json['board'] as List)
          .map((row) => (row as List).map((cell) => cell as String).toList())
          .toList(),
      currentPlayer: json['currentPlayer'] as String,
      winner: json['winner'] as String?,
      winningLine: (json['winningLine'] as List?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board,
      'currentPlayer': currentPlayer,
      'winner': winner,
      'winningLine': winningLine,
    };
  }
}
