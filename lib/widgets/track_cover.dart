import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';

class TrackCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4.0),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.black45,
          ),
          child: StreamBuilder<Track>(
              stream: _bloc.trackStream,
              builder: (context, snapshot) {
                String src = snapshot.data?.image ?? '';

                if (src.isEmpty) {
                  return const CoverPlaceholder();
                }

                // TODO add placeholder image
                return CachedNetworkImage(
                  imageUrl: src,
                  placeholder: (context, url) => const CoverPlaceholder(),
                  errorWidget: (context, url, err) => const CoverPlaceholder(),
                  fit: BoxFit.cover,
                );
              }),
        ),
      ),
    );
  }
}

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Icon(
          Icons.album,
          size: constraints.biggest.shortestSide - 48,
          color: Colors.white12,
        );
      },
    );
  }
}
