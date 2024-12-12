import 'package:flutter/material.dart';

class Kid extends StatefulWidget {
  final Color color;
  final Widget child;
  final void Function(Color, Color) onMatched;
  final bool hasMatchedBag;
  final String? matchedBagImage; // Matched bag image path

  Kid({
    required this.color,
    required this.child,
    required this.onMatched,
    this.hasMatchedBag = false,
    this.matchedBagImage,
  });

  @override
  _KidState createState() => _KidState();
}

class _KidState extends State<Kid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set up the AnimationController to make the kid "dance" on match
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Repeat the animation

    // Create a bounce animation or wiggle effect
    _animation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Color>(
      onWillAccept: (data) => true,
      onAccept: (bagColor) {
        widget.onMatched(bagColor, widget.color);
        if (bagColor == widget.color) {
          _controller.forward(); // Start dancing on correct match
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value), // Wiggle up and down
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      widget.child, // Display the kid image
                      if (widget.hasMatchedBag && widget.matchedBagImage != null)
                        Positioned(
                          bottom: 0,
                          child: Image.asset(
                            widget.matchedBagImage!, // Display the matched bag
                            width: 40,
                            height: 40,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
