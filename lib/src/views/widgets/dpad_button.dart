import 'package:flutter/material.dart';

class DpadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const DpadButton({super.key, required this.label, required this.onTap});

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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFF2A5238) : const Color(0xFF173324),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3F6B4D), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: const TextStyle(color: Color(0xFFA8E6B0), fontSize: 18),
        ),
      ),
    );
  }
}
