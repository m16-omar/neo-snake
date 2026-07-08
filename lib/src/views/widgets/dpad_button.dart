import 'package:flutter/material.dart';

class DpadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double size;

  const DpadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.size = 52.0,
  });

  @override
  State<DpadButton> createState() => _DpadButtonState();
}

class _DpadButtonState extends State<DpadButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onTap();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF2A5238) : const Color(0xFF173324),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3F6B4D), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: const Color(0xFFA8E6B0),
            fontSize: widget.size * 0.35, // scale font size dynamically
          ),
        ),
      ),
    );
  }
}
