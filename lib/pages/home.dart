import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tormentedplayer/services/lastfm.dart';
import 'package:tormentedplayer/widgets/track_cover.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String _serverURL = 'http://stream2.mpegradio.com:8070/tormented.mp3';
  AudioPlayer _player;
  LastFM _lastFM = LastFM(LastFMConfig(
    apiKey: 'XXX',
  ));

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _player.setUrl(_serverURL);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            if (orientation == Orientation.portrait) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buildCover(),
                  buildInfo(),
                  buildControls(),
                ],
              );
            } else {
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
                        buildInfo(),
                        SizedBox(height: 32.0),
                        buildControls(),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildCover() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: StreamBuilder<IcyMetadata>(
            stream: _player.icyMetadataStream,
            builder: (context, snapshot) {
              final String title = snapshot.data?.info?.title;
              final List<String> parsedTitle = parseTitle(title);
              final track = parsedTitle[1];
              final artist = parsedTitle[0];

              if (track.isNotEmpty && artist.isNotEmpty) {
                return FutureBuilder(
                  future: _lastFM.getTrackInfo(track: track, artist: artist),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                    }
                    return TrackCover(snapshot.data?.album?.image?.extraLarge);
                  },
                );
              } else {
                return TrackCover(null);
              }
            }),
      ),
    );
  }

  Widget buildInfo() {
    return StreamBuilder<IcyMetadata>(
        stream: _player.icyMetadataStream,
        builder: (context, snapshot) {
          final String title = snapshot.data?.info?.title;
          final List<String> parsedTitle = parseTitle(title);
          final track = parsedTitle[1];
          final artist = parsedTitle[0];

          return TrackInfo(
            title: track ?? '-',
            artist: artist ?? '-',
          );
        });
  }

  Widget buildControls() {
    return StreamBuilder<AudioPlaybackState>(
        stream: _player.playbackStateStream,
        builder: (context, snapshot) {
          final AudioPlaybackState state = snapshot.data;
          final bool isLoading = state == AudioPlaybackState.connecting ||
              state == AudioPlaybackState.none ||
              state == AudioPlaybackState.completed;
          final bool isConnected = state == AudioPlaybackState.playing;

          return FloatingActionButton(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                : Icon(isConnected ? Icons.stop : Icons.play_arrow),
            onPressed: () async {
              try {
                isConnected ? await _player.stop() : await _player.play();
              } catch (err) {
                print(err);
                _player.stop();
              }
            },
          );
        });
  }

  static List<String> parseTitle(String title) {
    if (title == null) return ['', ''];
    final RegExp matcher = RegExp(r'^(.*) - (.*)$');
    final match = matcher.firstMatch(title);

    if (match == null) return ['', ''];

    final song = match.group(1) ?? '';
    final artist = match.group(2) ?? '';

    return [song, artist];
  }
}
