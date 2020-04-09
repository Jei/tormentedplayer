import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';

class BackgroundGradient extends StatelessWidget {
  static final int _alpha = 74;
  final Color _defaultColor = Color.fromARGB(_alpha, 33, 33, 33);

  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return StreamBuilder<Color>(
      initialData: _defaultColor,
      stream: _bloc.trackStream.transform(StreamTransformer.fromHandlers(
        handleData: (Track track, EventSink<Color> sink) async {
          // Get a palette from the current track's image
          PaletteGenerator paletteGenerator =
              await PaletteGenerator.fromImageProvider(
                  CachedNetworkImageProvider(track.image));

          // TODO choose color depending on current theme
          sink.add(paletteGenerator.vibrantColor?.color ??
              paletteGenerator.darkVibrantColor?.color ??
              _defaultColor);
        },
        handleError: (obj, trace, EventSink<Color> sink) {
          sink.add(_defaultColor);
        },
      )),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                snapshot.data ?? _defaultColor,
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        );
      },
    );
  }
}