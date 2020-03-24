import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class TrackCover extends StatelessWidget {
  final String src;

  const TrackCover(this.src, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO add placeholder image
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black45,
          ),
          child: src != null && src.isNotEmpty
              ? FadeInImage.memoryNetwork(
                  image: src,
                  placeholder: kTransparentImage,
                  fit: BoxFit.cover,
                )
              : null,
        ),
      ),
    );
  }
}
