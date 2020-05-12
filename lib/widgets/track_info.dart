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

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 108.0,
        maxHeight: 112.0,
      ),
      child: StreamBuilder<Track>(
        stream: _bloc.trackStream,
        builder: (context, snapshot) {
          final loading = snapshot.hasError || !snapshot.hasData;
          final track = snapshot.data;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InfoText(
                track?.artist,
                height: 32.0,
                placeholderWidth: 120.0,
                upperCase: true,
                style: theme.textTheme.subtitle1.merge(TextStyle(
                  color: theme.accentColor,
                )),
                loading: loading,
              ),
              InfoText(
                track?.title,
                height: 40.0,
                placeholderWidth: 200.0,
                style: textTheme.headline5,
                upperCase: false,
                loading: loading,
              ),
              InfoText(
                track?.album,
                height: 32.0,
                placeholderWidth: 160.0,
                style: textTheme.subtitle1.merge(TextStyle(
                  color: textTheme.subtitle1.color.withAlpha(138),
                )),
                upperCase: true,
                loading: loading,
              ),
            ],
          );
        },
      ),
    );
  }
}

class InfoText extends StatelessWidget {
  final String text;
  final double height;
  final double placeholderWidth;
  final bool upperCase;
  final bool loading;
  final TextStyle style;

  const InfoText(
    this.text, {
    Key key,
    this.height,
    this.placeholderWidth,
    this.upperCase = false,
    this.loading = false,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AnimatedPlaceholder(
        height: 32.0,
        width: placeholderWidth,
        color: style.color,
      );
    }

    return Container(
      alignment: Alignment.center,
      height: height,
      child: Marquee(
        child: Text(
          text != null ? (upperCase ? text.toUpperCase() : text) : '-',
          style: style,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
