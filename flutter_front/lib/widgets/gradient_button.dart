import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const GradientButton({
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ).copyWith(
        backgroundColor: MaterialStateProperty.all<Color>(
          Colors.blue, // tu peux utiliser un gradient ici via décorations personnalisées
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
