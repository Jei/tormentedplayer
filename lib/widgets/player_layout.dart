import 'package:flutter/material.dart';
import 'package:tormentedplayer/widgets/player_button.dart';
import 'package:tormentedplayer/widgets/track_cover.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class PlayerLayout extends StatelessWidget {
  final Function onHistoryPressed;

  const PlayerLayout({
    Key key,
    @required this.onHistoryPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isPortrait = constraints.maxWidth <= constraints.maxHeight;
        final breakpoint = isPortrait ? 244.0 : 172.0;
        final showCover = constraints.maxHeight >= breakpoint;
        final widgets = <Widget>[];

        if (isPortrait) {
          if (showCover) {
            // Add cover
            widgets.addAll([
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: TrackCover(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ]);
          }

          widgets.addAll([
            TrackInfo(),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(width: 48), // Placeholder for another button
                PlayerButton(),
                IconButton(
                  icon: Icon(Icons.playlist_play),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: onHistoryPressed,
                ),
              ],
            ),
          ]);

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets,
          );
        } else {
          if (showCover) {
            widgets.addAll([
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: TrackCover(),
                ),
              ),
              const SizedBox(width: 16.0),
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TrackInfo(),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(width: 48), // Placeholder for another button
                        PlayerButton(),
                        IconButton(
                          icon: Icon(Icons.playlist_play),
                          color: Theme.of(context).iconTheme.color,
                          onPressed: onHistoryPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]);
          } else {
            widgets.addAll([
              Flexible(
                flex: 2,
                child: TrackInfo(),
              ),
              const SizedBox(height: 16.0),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    PlayerButton(),
                    IconButton(
                      icon: Icon(Icons.playlist_play),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: onHistoryPressed,
                    ),
                  ],
                ),
              ),
            ]);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widgets,
          );
        }
      },
    );
  }
}
