import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String _serverURL = 'http://stream2.mpegradio.com:8070/tormented.mp3';
  AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _player.playbackEventStream.listen((event) {
      debugPrint(event.toString());
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  'https://cataas.com/c',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          StreamBuilder<IcyMetadata>(
              stream: _player.icyMetadataStream,
              builder: (context, snapshot) {
                final String title = snapshot.data?.info?.title;
                final List<String> parsedTitle = parseTitle(title);

                return Column(
                  children: <Widget>[
                    Text(
                      parsedTitle[1],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(parsedTitle[0]),
                  ],
                );
              }),
          StreamBuilder<AudioPlaybackState>(
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
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
              }),
        ],
      ),
    );
  }

  static List<String> parseTitle(String title) {
    if (title == null) return ['-', '-'];
    final RegExp matcher = RegExp(r'^(.*) - (.*)$');
    final match = matcher.firstMatch(title);

    if (match == null) return ['-', '-'];

    final song = match.group(1) ?? '-';
    final artist = match.group(2) ?? '-';

    return [song, artist];
  }
}
