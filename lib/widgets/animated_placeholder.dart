import 'package:flutter/material.dart';

class AnimatedPlaceholder extends StatefulWidget {
  final double height;
  final double width;
  final Color color;

  const AnimatedPlaceholder({
    Key key,
    this.height,
    this.width,
    this.color = Colors.black45,
  }) : super(key: key);

  @override
  _AnimatedPlaceholderState createState() => _AnimatedPlaceholderState();
}

class _AnimatedPlaceholderState extends State<AnimatedPlaceholder>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _gradientPosition;
  Color _lightColor;
  Color _darkColor;

  @override
  void initState() {
    super.initState();

    HSVColor hsv = HSVColor.fromColor(widget.color);
    hsv = hsv.withValue(hsv.value.clamp(0.0, 0.9));
    _darkColor = hsv.toColor();
    _lightColor = hsv
        .withValue((hsv.value + 0.1).clamp(0.0, 1.0))
        .toColor();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _gradientPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCirc,
      ),
    )..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _darkColor,
              _lightColor,
              _darkColor,
            ],
            begin: Alignment(_gradientPosition.value - 1, 0),
            end: Alignment(_gradientPosition.value, 0),
            stops: [0, 0.5, 1],
            transform: GradientRotation(0.3),
          ),
        ),
      ),
    );
  }
}
