import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final Function(bool) onToggle;

  const ToggleButton({key, required this.onToggle}) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleButton() {
    setState(() {
      isOn = !isOn;
    });

    if (isOn) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onToggle(isOn); // Notify parent widget of toggle event
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleButton,
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isOn ? Colors.green : Colors.grey[300],
          border: Border.all(
            color: isOn ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              isOn ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: EdgeInsets.all(10),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 0.5 * 2 * 3.1416, // 0.5 rotations
                    child: child,
                  );
                },
                child: Icon(
                  Icons.wifi,
                  color: isOn ? Colors.blue : Colors.grey,
                )
              ),
            ),
            Expanded(
              child: Container(
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isOn ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
