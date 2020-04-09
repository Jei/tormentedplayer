import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/widgets/background_gradient.dart';
import 'package:tormentedplayer/widgets/player_button.dart';
import 'package:tormentedplayer/widgets/track_cover.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  RadioBloc _bloc;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _bloc = Provider.of<RadioBloc>(context);
    _bloc.connectToRadio();
  }

  @override
  void dispose() {
    _bloc.disconnectFromRadio();
    _bloc.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _bloc?.disconnectFromRadio();
        break;
      case AppLifecycleState.resumed:
        _bloc?.connectToRadio();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _bloc?.disconnectFromRadio();
        return Future.value(true);
      },
      child: Scaffold(
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
      ),
    );
  }

  Widget buildPortraitLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 60.0, 40.0, 48.0),
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
      padding: const EdgeInsets.all(40.0),
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
