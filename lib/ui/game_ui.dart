import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tic_tac_toe/ui/tictactoe_cell.dart';
import 'package:tic_tac_toe/ui/toggle_button_widget.dart';

import '../game_state.dart';
import '../viewmodel.dart';

class TicTacToeGame extends StatelessWidget {
  const TicTacToeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe',
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      ),
      body: Consumer<TicTacToeViewModel>(
        builder: (context, viewModel, child) {
          final gameState = viewModel.gameState;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Online: ",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  ToggleButton(
                    onToggle: (isOn) {
                      if (isOn) {
                        viewModel.setGameMode(GameMode.online);
                      } else {
                        viewModel.setGameMode(GameMode.local);
                      }
                    },
                  ),
                ],
              ),
              Align(
                child: Container(
                  alignment: FractionalOffset.center,
                  width: 300,
                  height: 300,
                  child: Stack(
                    children: [
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 4.0,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          final row = index ~/ 3;
                          final col = index % 3;
                          return TicTacToeCell(
                            symbol: gameState.board[row][col],
                            onTap: () => viewModel.makeMove(row, col, context),
                          );
                        },
                      ),
                      if (gameState.winner != null)
                        WinnerLine(winningLine: gameState.winningLine!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (gameState.winner != null) ...[
                Text(
                  'Winner: ${gameState.winner}',
                  style: TextStyle(fontSize: 24),
                ),
              ] else if (gameState.currentPlayer == "X") ...[
                Text(
                  'Current Player: X',
                  style: TextStyle(fontSize: 24),
                ),
              ] else if (gameState.currentPlayer == "O") ...[
                Text(
                  'Current Player: O',
                  style: TextStyle(fontSize: 24),
                ),
              ],
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.resetGame(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  elevation: 10,
                  shadowColor: Colors.deepPurpleAccent,
                ),
                child: Text('Reset Game'),
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class WinnerLine extends StatefulWidget {
  final List<int> winningLine;

  const WinnerLine({super.key, required this.winningLine});

  @override
  _WinnerLineState createState() => _WinnerLineState();
}

class _WinnerLineState extends State<WinnerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate start and end positions
    final start = widget.winningLine.first;
    final end = widget.winningLine.last;
    final startX = (start % 3) * 100 + 50;
    final startY = (start ~/ 3) * 100 + 50;
    final endX = (end % 3) * 100 + 50;
    final endY = (end ~/ 3) * 100 + 50;

    return Positioned(
      left: 0,
      top: 0,
      child: CustomPaint(
        size: const Size(300, 300),
        painter: LinePainter(
          startX: startX.toDouble(),
          startY: startY.toDouble(),
          endX: endX.toDouble() * _animation.value,
          endY: endY.toDouble() * _animation.value,
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  LinePainter(
      {required this.startX,
      required this.startY,
      required this.endX,
      required this.endY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
