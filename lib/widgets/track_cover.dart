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

        return AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black45,
              ),
              child: src.isNotEmpty
                  ? FadeInImage.memoryNetwork(
                      image: src,
                      placeholder: kTransparentImage,
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
