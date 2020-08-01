import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show Client;
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';

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

// This is just a wrapper for AudioService to simplify testing
// See https://github.com/mockito/mockito/issues/1013
class AudioClient {
  Future<void> play() => AudioService.play();

  Future<bool> start() => AudioService.start(
        backgroundTaskEntrypoint: audioPlayerTaskEntryPoint,
        androidNotificationChannelName: 'Tormented Player',
        androidNotificationColor: 0xFF212121,
        androidNotificationIcon: 'drawable/ic_notification_eye',
        androidEnableQueue: false,
        androidStopForegroundOnPause: true,
      );

  Future<void> stop() => AudioService.stop();

  Future<void> pause() => AudioService.pause();

  bool get connected => AudioService.connected;

  PlaybackState get playbackState => AudioService.playbackState;

  Stream<PlaybackState> get playbackStateStream =>
      AudioService.playbackStateStream;

  Stream<MediaItem> get currentMediaItemStream =>
      AudioService.currentMediaItemStream;

  MediaItem get currentMediaItem => AudioService.currentMediaItem;
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  Repository _repository = Repository(Client());
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;
  StreamSubscription<MediaItem> _mediaItemSubscription;
  final String _url = 'http://stream2.mpegradio.com:8070/tormented.mp3';

  AudioProcessingState _stateToAudioProcessingState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return AudioProcessingState.none;
      case AudioPlaybackState.stopped:
        return AudioProcessingState.stopped;
      case AudioPlaybackState.paused:
      case AudioPlaybackState.playing:
        return AudioProcessingState.ready;
      case AudioPlaybackState.connecting:
        return AudioProcessingState.connecting;
      case AudioPlaybackState.completed:
        return AudioProcessingState.stopped;
      default:
        throw Exception('Illegal state');
    }
  }

  List<MediaControl> _getControls(bool playing) {
    if (playing) {
      return [
        pauseControl,
      ];
    } else {
      return [
        playControl,
      ];
    }
  }

  void _setState(AudioProcessingState state, bool playing) {
    // Avoid calling AudioServiceBackground.setState when the state is the same
    if (state == AudioServiceBackground.state.processingState &&
        playing == AudioServiceBackground.state.playing) {
      return;
    }
    AudioServiceBackground.setState(
      processingState: state,
      playing: playing,
      controls: _getControls(playing),
    );
  }

  // Stops player and sets the new audio processing state
  Future<void> _stopPlayer(AudioProcessingState state) async {
    // AudioPlayer.stop() cannot be called from a "none" processing state
    if (_audioPlayer.playbackState != AudioPlaybackState.none) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.dispose();
    _setState(state, false);
    _eventSubscription.cancel();
    _mediaItemSubscription.cancel();
  }

  // Handler for errors thrown by AudioPlayer.setUrl() or during playback
  void _handlePlayerError(String message, Object error, [StackTrace stack]) {
    // AudioPlayer.setUrl() throws a "Connection aborted" error every time it's called
    if (error is PlatformException &&
        error.code == "abort" &&
        error.message == "Connection aborted") return;

    // Print the error and stop the player
    print('$message: $error; $stack');
    _stopPlayer(AudioProcessingState.error);
  }

  List<String> _parseIcyTitle(String title) {
    if (title == null) return [null, null];
    final RegExp matcher = RegExp(r'^(.*) - (.*)$');
    final match = matcher.firstMatch(title);

    if (match == null) return [null, null];

    final song = match.group(1);
    final artist = match.group(2);

    return [song, artist];
  }

  Stream<MediaItem> _mediaItemStream(IcyMetadata item) async* {
    final String icyTitle = item?.info?.title;
    final List<String> parsedTitle = _parseIcyTitle(icyTitle);
    final String title = parsedTitle[1];
    final String artist = parsedTitle[0];

    // TODO advise @ryanheise of a bug with empty title and artist
    yield MediaItem(
      id: _url,
      album: '',
      title: title ?? ' ',
      artist: artist ?? ' ',
      artUri: null,
    );

    if ((title ?? '').isEmpty || (artist ?? '').isEmpty) return;

    try {
      Track fullTrack = await _repository.fetchTrack(title, artist);

      yield MediaItem(
        id: _url,
        album: fullTrack.album ?? '',
        title: title,
        artist: artist,
        artUri: fullTrack.image,
      );
    } catch (err) {
      print('Error while fetching current track\'s info: $err');
    }
  }

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // FIXME if the app is paused while onStart is running, the function never finishes and the audio service never starts completely
    // Subscribe to AudioPlayer events
    // Playback state events
    _eventSubscription = _audioPlayer.playbackEventStream.listen(
      (event) {
        final state = _stateToAudioProcessingState(event.state);
        _setState(state, event.state == AudioPlaybackState.playing);
      },
      onError: (err, stack) {
        _handlePlayerError('Error during playback', err, stack);
      },
    );

    // Icy metadata events
    _mediaItemSubscription = _audioPlayer.icyMetadataStream
        .distinct((prev, next) => prev.info?.title == next.info?.title)
        .switchMap(_mediaItemStream)
        .listen(AudioServiceBackground.setMediaItem);

    try {
      await _audioPlayer.setUrl(_url);
      // Start playing immediately
      onPlay();
    } catch (err) {
      _handlePlayerError('Error while connecting to the URL', err);
    }
  }

  @override
  void onPlay() async {
    // Seek the end of the stream instead of playing the buffered audio
    await _audioPlayer.seek(null);
    _audioPlayer.play();
  }

  @override
  void onPause() {
    _audioPlayer.pause();
  }

  @override
  Future<void> onStop() async {
    await _stopPlayer(AudioProcessingState.stopped);
    await super.onStop();
  }

  @override
  void onClick(MediaButton button) {
    if (button != MediaButton.media) return;

    switch (_audioPlayer.playbackState) {
      case AudioPlaybackState.playing:
        onPause();
        break;
      case AudioPlaybackState.paused:
        onPlay();
        break;
      default:
    }
  }

  @override
  void onAudioFocusLost(AudioInterruption interruption) {
    // TODO handle interruption depending on its type
    onPause();
  }
}
