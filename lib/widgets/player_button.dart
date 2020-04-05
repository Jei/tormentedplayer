import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/services/radio.dart';

class PlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return StreamBuilder<RadioPlaybackState>(
      initialData: RadioPlaybackState.none,
      stream: _bloc.playbackStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? RadioPlaybackState.none;
        final bool isLoading = state == RadioPlaybackState.connecting;
        final bool isPlaying = state == RadioPlaybackState.playing;

        return FloatingActionButton(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ))
              : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            if (isLoading) return;

            isPlaying ? _bloc.stopRadio() : _bloc.startRadio();
          },
        );
      },
    );
  }
}
