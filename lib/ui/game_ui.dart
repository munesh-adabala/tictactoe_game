import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel.dart';

class TicTacToeGame extends StatelessWidget {
  const TicTacToeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
      ),
      body: Consumer<TicTacToeViewModel>(
        builder: (context, viewModel, child) {
          final gameState = viewModel.gameState;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                child: Container(
                  alignment: FractionalOffset.center,
                  width: 300,
                  height: 300,
                  child: Stack(
                    children: [
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            onTap: () => viewModel.makeMove(row, col),
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
              if (gameState.winner != null)
                Text(
                  'Winner: ${gameState.winner}',
                  style: const TextStyle(fontSize: 24),
                )
              else
                Text(
                  'Current Player: ${gameState.currentPlayer}',
                  style: const TextStyle(fontSize: 24),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.resetGame(),
                child: Text('Reset Game'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TicTacToeCell extends StatelessWidget {
  final String symbol;
  final VoidCallback onTap;

  const TicTacToeCell({super.key, required this.symbol, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }
}

class WinnerLine extends StatefulWidget {
  final List<int> winningLine;

  const WinnerLine({required this.winningLine});

  @override
  _WinnerLineState createState() => _WinnerLineState();
}

class _WinnerLineState extends State<WinnerLine> with SingleTickerProviderStateMixin {
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
        size: Size(300, 300),
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

  LinePainter({required this.startX, required this.startY, required this.endX, required this.endY});

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
