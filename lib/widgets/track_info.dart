import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';

class TrackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return StreamBuilder<Track>(
      initialData: Track(),
      stream: _bloc.trackStream,
      builder: (context, snapshot) {
        Track track = snapshot.data;

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                height: 32.0,
                child: Marquee(
                  child: Text(
                    (track?.artist ?? '-').toUpperCase(),
                    style: textTheme.subtitle1.merge(TextStyle(
                      color: theme.accentColor,
                    )),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 40.0,
                child: Marquee(
                  child: Text(
                    track?.title ?? '-',
                    style: textTheme.headline5,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: 32.0,
                child: Marquee(
                  child: Text(
                    track?.album ?? '-',
                    style: textTheme.subtitle1.merge(TextStyle(
                      color: textTheme.subtitle1.color.withAlpha(138),
                    )),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
