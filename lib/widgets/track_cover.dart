import 'package:flutter/material.dart';

class TrackCover extends StatelessWidget {
  final String src;

  const TrackCover(this.src, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4/5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.network(
          src,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
