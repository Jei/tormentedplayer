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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<FullAudioPlaybackState>(
                stream: _player.fullPlaybackStateStream,
                builder: (context, snapshot) {
                  final fullState = snapshot.data;
                  final state = fullState?.state;

                  if (state == AudioPlaybackState.connecting ||
                      state == AudioPlaybackState.none ||
                      state == AudioPlaybackState.completed) {
                    return CircularProgressIndicator();
                  } else {
                    bool isConnected = state == AudioPlaybackState.playing;
                    return FloatingActionButton(
                        child:
                            Icon(isConnected ? Icons.stop : Icons.play_arrow),
                        onPressed: () async {
                          try {
                            if (isConnected) {
                              await _player.stop();
                            } else {
                              await _player.play();
                            }
                          } catch (err) {
                            print(err);
                            _player.stop();
                          }
                        });
                  }
                }),
          ],
        ),
      ),
    );
  }
}
