import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log_level.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FlutterFFmpeg _ffmpeg = new FlutterFFmpeg();
  final FlutterFFmpegConfig _ffmpegConfig = new FlutterFFmpegConfig();
  final String _serverURL = 'http://stream2.mpegradio.com:8070';
  bool _isConnected = false;
  String _currentTrack = 'Loading...';

  @override
  void initState() {
    _ffmpegConfig.enableLogCallback(this.logCallback);
    _ffmpegConfig.setLogLevel(LogLevel.AV_LOG_TRACE);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_currentTrack),
            FloatingActionButton(
                child: Icon(_isConnected ? Icons.stop : Icons.play_arrow),
                onPressed: () {
                  if (_isConnected) {
                    _ffmpeg.cancel().then((value) => setState(() {
                          _isConnected = false;
                        }));
                  } else {
                    setState(() {
                      _isConnected = true;
                    });
                    _ffmpegConfig.registerNewFFmpegPipe().then((path) {
                      print('New ffmpeg pipe at $path');

                      _ffmpeg
                          .execute(
                              '-reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 2 -i $_serverURL -c:a copy -f mp3 pipe:1')
                          .then((rc) =>
                              print('FFmpeg process exited with rc $rc'))
                          .whenComplete(() => setState(() {
                                _isConnected = false;
                              }));
                    }).catchError((err) {
                      setState(() {
                        _isConnected = false;
                      });
                    });
                  }
                })
          ],
        ),
      ),
    );
  }

  void logCallback(int level, String message) {
    RegExp _songMatcher = RegExp(r'Metadata update for StreamTitle: (.*)');
    RegExpMatch match = _songMatcher.firstMatch(message);

    if (match != null) {
      setState(() {
        _currentTrack = match.group(1);
      });
    }

  }
}
