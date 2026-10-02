import 'package:flutter/material.dart';

class Btn3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final double? width;
  final double height;
  final bool disabled;

  const Btn3D({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    required this.shadowColor,
    this.width,
    this.height = 56.0,
    this.disabled = false,
  });

  @override
  State<Btn3D> createState() => _Btn3DState();
}

class _Btn3DState extends State<Btn3D> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.disabled || widget.onPressed == null;
    final Color currentColor = isDisabled ? Colors.grey.shade400 : widget.color;
    final Color currentShadow = isDisabled ? Colors.grey.shade500 : widget.shadowColor;

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled
          ? null
          : () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(
          top: _isPressed ? 4.0 : 0.0,
          bottom: _isPressed ? 0.0 : 4.0,
        ),
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: currentShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
