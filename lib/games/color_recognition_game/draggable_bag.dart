import 'package:flutter/material.dart';

class DraggableGoodyBag extends StatelessWidget {
  final Color color; // Now passing color as the data
  final Widget child;

  DraggableGoodyBag({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Draggable<Color>(
      data: color, // Dragging color as the data
      feedback: Material(
        child: child, // Display the provided child widget as feedback
        color: Colors.transparent,
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: child, // Display semi-transparent child when dragging
      ),
      child: child, // Display child when not dragging
    );
  }
}
