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
            child: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                if (orientation == Orientation.portrait) {
                  return buildPortraitLayout();
                } else {
                  return buildLandscapeLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TrackCover(),
          Expanded(
            child: TrackInfo(),
          ),
          PlayerButton(),
        ],
      ),
    );
  }

  Widget buildLandscapeLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 40.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TrackCover(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TrackInfo(),
                SizedBox(height: 32.0),
                PlayerButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
