import 'package:flutter/material.dart';

class AnimatedKey extends StatefulWidget {
  final String letter;
  final Color color;
  final Function(String) onTap;
  final double width;

  const AnimatedKey({
    required this.letter,
    required this.color,
    required this.onTap,
    required this.width,
    super.key,
  });

  @override
  State<AnimatedKey> createState() => _AnimatedKeyState();
}

class _AnimatedKeyState extends State<AnimatedKey> {
  Color _currentColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
  }

  @override
  void didUpdateWidget(covariant AnimatedKey oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      setState(() {
        _currentColor = widget.color;
      });
    }
  }

  _getKeyHeight() {
    // For width 40, height is 50
    return 50 * widget.width / 40;
  }

  // This method will be called to provide visual feedback on tap
  void _handleTap() {
    setState(() {
      _currentColor = Colors.black; // Temporary color to indicate button press
    });

    // Trigger a delayed reset after the tap animation
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _currentColor = widget.color; // Revert to the original color
      });
    });

    // Call the callback passed from the parent to handle letter tap
    widget.onTap(widget.letter);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () {
          _handleTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.width,
          height: _getKeyHeight(),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Text(
              widget.letter,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
