import 'package:flutter/material.dart';

class TicTacToeCell extends StatefulWidget {
  final String symbol;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double fontSize;

  const TicTacToeCell({
    super.key,
    required this.symbol,
    required this.onTap,
    this.backgroundColor = const Color(0xFFB3E5FC),
    this.borderColor = Colors.black,
    this.borderRadius = 8.0,
    this.fontSize = 36.0,
  });

  @override
  _TicTacToeCellState createState() => _TicTacToeCellState();
}

class _TicTacToeCellState extends State<TicTacToeCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 2.0 * 3.14159,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: Border.all(color: widget.borderColor),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: Center(
                child: Text(
                  widget.symbol,
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
