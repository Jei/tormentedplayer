import 'package:flutter/material.dart';
import 'package:tormentedplayer/pages/settings_page.dart';
import 'package:tormentedplayer/widgets/background_gradient.dart';
import 'package:tormentedplayer/widgets/player_button.dart';
import 'package:tormentedplayer/widgets/track_cover.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class HomePage extends StatelessWidget {
  static final String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Theme.of(context).iconTheme.color,
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
              child: OrientationBuilder(
                builder: (BuildContext context, Orientation orientation) {
                  if (orientation == Orientation.portrait) {
                    return PortraitLayout();
                  } else {
                    return LandscapeLayout();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainSection extends StatelessWidget {
  final direction;

  const MainSection({
    Key key,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TrackInfo(),
        const SizedBox(height: 16.0, width: 16.0),
        PlayerButton(),
      ],
    );
  }
}

class PortraitLayout extends StatelessWidget {
  static const _breakpoint = 244.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final showCover = constraints.maxHeight >= _breakpoint;

      if (showCover) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
            SizedBox(height: 16.0),
            TrackInfo(),
            const SizedBox(height: 16.0),
            PlayerButton(),
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TrackInfo(),
            const SizedBox(height: 16.0),
            PlayerButton(),
          ],
        );
      }
    });
  }
}

class LandscapeLayout extends StatelessWidget {
  static const _breakpoint = 172.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final showCover = constraints.maxHeight >= _breakpoint;

        if (showCover) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: TrackCover(),
                ),
              ),
              SizedBox(width: 16.0),
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TrackInfo(),
                    const SizedBox(height: 16.0),
                    PlayerButton(),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 2,
                child: TrackInfo(),
              ),
              const SizedBox(height: 16.0),
              Flexible(
                flex: 1,
                child: PlayerButton(),
              ),
            ],
          );
        }
      },
    );
  }
}
