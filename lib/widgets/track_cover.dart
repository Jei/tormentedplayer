import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:transparent_image/transparent_image.dart';

class TrackCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO add placeholder image
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return StreamBuilder<Track>(
      initialData: Track(),
      stream: _bloc.trackStream,
      builder: (context, snapshot) {
        String src = snapshot.data?.image ?? '';

        return Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black45,
              ),
              child: src.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: src,
                      placeholder: (context, url) =>
                          Image.memory(kTransparentImage),
                      errorWidget: (context, url, err) =>
                          Image.memory(kTransparentImage),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
