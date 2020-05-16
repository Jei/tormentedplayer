import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/resources/radio.dart';

class PlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);
    final ThemeData theme = Theme.of(context);
    final color = theme.accentColor;
    final highlight = color.withAlpha(30);
    final splash = color.withAlpha(50);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 44.0,
        maxHeight: 72.0,
        minWidth: 44.0,
        maxWidth: 72.0,
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.0),
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: StreamBuilder<RadioPlaybackState>(
              initialData: RadioPlaybackState.none,
              stream: _bloc.playbackStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data ?? RadioPlaybackState.none;
                final bool isLoading = state == RadioPlaybackState.connecting;
                final bool isPlaying = state == RadioPlaybackState.playing;

                return InkWell(
                  splashColor: splash,
                  highlightColor: highlight,
                  borderRadius: BorderRadius.circular(100.0),
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ))
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: color,
                          size: 60,
                        ),
                  onTap: () {
                    if (isLoading) return;

                    isPlaying ? _bloc.stopRadio() : _bloc.startRadio();
                  },
                );
              }),
        ),
      ),
    );
  }
}
