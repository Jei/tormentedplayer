import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/metadata.dart';
import 'package:tormentedplayer/blocs/radio.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/widgets/player_button.dart';
import 'package:tormentedplayer/widgets/track_cover.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  MetadataBloc _metadataBloc = MetadataBloc();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    RadioBloc.connect();
  }

  @override
  void dispose() {
    RadioBloc.disconnect();
    _metadataBloc.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        RadioBloc.disconnect();
        break;
      case AppLifecycleState.resumed:
        RadioBloc.connect();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        RadioBloc.disconnect();
        return Future.value(true);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: StreamProvider<Track>.value(
            initialData: Track(),
            value: _metadataBloc.trackStream,
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
        ),
      ),
    );
  }

  Widget buildCover() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: TrackCover(),
      ),
    );
  }

  Widget buildPortraitLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildCover(),
        TrackInfo(),
        PlayerButton(),
      ],
    );
  }

  Widget buildLandscapeLayout() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildCover(),
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
    );
  }
}
