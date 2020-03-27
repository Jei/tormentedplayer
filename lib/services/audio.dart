import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// TODO add "close"/"stop" button
MediaControl playControl = MediaControl(
  label: 'Play',
  action: MediaAction.play,
  androidIcon: 'drawable/ic_play_black',
);
MediaControl pauseControl = MediaControl(
  label: 'Pause',
  action: MediaAction.pause,
  androidIcon: 'drawable/ic_pause_black',
);

void audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;
  StreamSubscription<IcyMetadata> _metadataSubscription;
  final String _url = 'http://stream2.mpegradio.com:8070/tormented.mp3';
  Completer _completer = Completer();

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.connecting:
        return BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception('Illegal state');
    }
  }

  List<MediaControl> _getControls(state) {
    if (state == BasicPlaybackState.playing) {
      return [
        pauseControl,
      ];
    } else {
      return [
        playControl,
      ];
    }
  }

  void _setState(BasicPlaybackState state) {
    AudioServiceBackground.setState(
      basicState: state,
      controls: _getControls(state),
    );
  }

  static List<String> _parseIcyTitle(String title) {
    if (title == null) return ['', ''];
    final RegExp matcher = RegExp(r'^(.*) - (.*)$');
    final match = matcher.firstMatch(title);

    if (match == null) return ['', ''];

    final song = match.group(1) ?? '';
    final artist = match.group(2) ?? '';

    return [song, artist];
  }

  @override
  Future<void> onStart() async {
    print('ON START');
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(state);
      }
      _setState(state);
    });
    _metadataSubscription = _audioPlayer.icyMetadataStream.listen((event) {
      final String icyTitle = event?.info?.title;
      final List<String> parsedTitle = _parseIcyTitle(icyTitle);

      AudioServiceBackground.setMediaItem(MediaItem(
        id: _url,
        album: '', // TODO get from LastFM
        title: parsedTitle[1] ?? '',
        artist: parsedTitle[0] ?? '',
        // artUri: '', // TODO get from LastFM
      ));
    });

    await _audioPlayer.setUrl(_url);
    print('URL SET');
    await _completer.future;
    print('ON START END');
  }

  @override
  void onPlay() {
    print('ON PLAY');
    _audioPlayer.play();
  }

  @override
  void onPause() {
    print('ON PAUSE');
    _audioPlayer.pause();
  }

  @override
  void onStop() {
    print('ON STOP');
    _audioPlayer.stop();
    _setState(BasicPlaybackState.stopped);
    _eventSubscription.cancel();
    _metadataSubscription.cancel();
    _completer.complete();
  }
}
