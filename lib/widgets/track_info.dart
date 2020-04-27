import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/widgets/animated_placeholder.dart';

class TrackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return StreamBuilder<Track>(
      stream: _bloc.trackStream,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AnimatedPlaceholder(
                    height: 32.0,
                    width: 120.0,
                    color: theme.accentColor,
                  ),
                  SizedBox(height: 8.0),
                  AnimatedPlaceholder(
                    height: 40.0,
                    color: textTheme.headline5.color,
                  ),
                  SizedBox(height: 8.0),
                  AnimatedPlaceholder(
                    height: 32.0,
                    width: 160.0,
                    color: textTheme.subtitle1.color.withAlpha(138),
                  ),
                ]),
          );
        }

        Track track = snapshot.data;

        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InfoText(
                track.artist,
                height: 32.0,
                upperCase: true,
                style: theme.textTheme.subtitle1.merge(TextStyle(
                  color: theme.accentColor,
                )),
              ),
              SizedBox(height: 8),
              InfoText(
                track.title,
                height: 40.0,
                style: textTheme.headline5,
                upperCase: false,
              ),
              SizedBox(height: 8),
              InfoText(
                track.album,
                height: 32.0,
                style: textTheme.subtitle1.merge(TextStyle(
                  color: textTheme.subtitle1.color.withAlpha(138),
                )),
                upperCase: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;
  final double height;
  final bool upperCase;
  final TextStyle style;

  const InfoText(
    this.text, {
    Key key,
    this.height,
    this.upperCase = false,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: height,
      child: Marquee(
        child: Text(
          upperCase ? (text ?? '-').toUpperCase() : (text ?? '-'),
          style: style,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
