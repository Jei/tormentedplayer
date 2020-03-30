import 'package:flutter/material.dart';
import 'package:tormentedplayer/blocs/radio.dart';

class PlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: StreamBuilder(
          stream: RadioBloc.playbackStateStream,
          builder: (context, snapshot) {
            final RadioPlaybackState state = snapshot.data;
            final bool isLoading = state == RadioPlaybackState.connecting;
            final bool isPlaying = state == RadioPlaybackState.playing;

            return isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                : Icon(isPlaying ? Icons.pause : Icons.play_arrow);
          }),
      onPressed: () {
        final RadioPlaybackState state = RadioBloc.playbackState;
        final bool isLoading = state == RadioPlaybackState.connecting;
        final bool isPlaying = state == RadioPlaybackState.playing;

        if (isLoading) return;

        isPlaying ? RadioBloc.stop() : RadioBloc.start();
      },
    );
  }
}
