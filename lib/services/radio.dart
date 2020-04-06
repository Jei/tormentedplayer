import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
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

enum RadioPlaybackState {
  none,
  stopped,
  paused,
  playing,
  buffering,
  error,
  connecting,
}

// Foreground methods
class Radio {
  static RadioPlaybackState _audioToRadioPlaybackState(PlaybackState state) {
    BasicPlaybackState basicState = state?.basicState;

    switch (basicState) {
      case BasicPlaybackState.error:
        return RadioPlaybackState.error;
      case BasicPlaybackState.stopped:
        return RadioPlaybackState.stopped;
      case BasicPlaybackState.paused:
        return RadioPlaybackState.paused;
      case BasicPlaybackState.playing:
        return RadioPlaybackState.playing;
      case BasicPlaybackState.buffering:
        return RadioPlaybackState.buffering;
      case BasicPlaybackState.connecting:
        return RadioPlaybackState.connecting;
      case BasicPlaybackState.fastForwarding:
      case BasicPlaybackState.rewinding:
      case BasicPlaybackState.skippingToPrevious:
      case BasicPlaybackState.skippingToNext:
      case BasicPlaybackState.skippingToQueueItem:
        throw Exception('Unsupported AudioService state');
      default:
        return RadioPlaybackState.none;
    }
  }

  static Track _mediaItemToTrack(MediaItem item) => Track(
      title: item?.title,
      artist: item?.artist,
      album: (item?.album ?? '').isEmpty ? null : item.album,
      image: (item?.artUri ?? '').isEmpty ? null : item.artUri);

  static start() {
    BasicPlaybackState state =
        AudioService.playbackState?.basicState ?? BasicPlaybackState.none;

    // TODO handle BasicPlaybackState.error case differently
    switch (state) {
      case BasicPlaybackState.paused:
        AudioService.play();
        break;
      case BasicPlaybackState.none:
      case BasicPlaybackState.stopped:
      case BasicPlaybackState.error:
        AudioService.start(
          backgroundTaskEntrypoint: audioPlayerTaskEntryPoint,
          androidNotificationChannelName: 'Tormented Player',
          notificationColor: 0xFF2196f3,
          androidNotificationIcon: 'drawable/ic_notification_radio',
          enableQueue: false,
          androidStopForegroundOnPause: true,
        );
        break;
      default:
        break;
    }
  }

  static stop() => AudioService.stop();

  static connect() => AudioService.connect();

  static disconnect() => AudioService.disconnect();

  static Stream<RadioPlaybackState> get playbackStateStream =>
      AudioService.playbackStateStream.map(_audioToRadioPlaybackState);

  static RadioPlaybackState get playbackState =>
      _audioToRadioPlaybackState(AudioService.playbackState);

  static Stream<Track> get currentTrackStream =>
      AudioService.currentMediaItemStream.map(_mediaItemToTrack);

  static Track get currentTrack =>
      _mediaItemToTrack(AudioService.currentMediaItem);
}

// Background task code
void audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  AudioPlayer _audioPlayer = AudioPlayer();
  Repository _repository = Repository();
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;
  StreamSubscription<MediaItem> _mediaItemSubscription;
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
      print('fetching new data');
      Track fullTrack = await _repository.fetchTrack(title, artist);

      yield MediaItem(
        id: _url,
        album: fullTrack.album ?? '',
        title: title,
        artist: artist,
        artUri: fullTrack.image,
      );
    } catch (err) {
      print(err);
    }
  }

  @override
  Future<void> onStart() async {
    // Subscribe to AudioPlayer events
    // Playback state events
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(state);
      }
      _setState(state);
    });

    // Icy metadata events
    _mediaItemSubscription = _audioPlayer.icyMetadataStream
    .distinct((prev, next) => prev.info?.title == next.info?.title)
        .switchMap(_mediaItemStream)
        .listen(AudioServiceBackground.setMediaItem);

    await _audioPlayer.setUrl(_url);
    // Start playing immediately
    onPlay();
    await _completer.future;
  }

  @override
  void onPlay() {
    _audioPlayer.play();
  }

  @override
  void onPause() {
    _audioPlayer.pause();
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(BasicPlaybackState.stopped);
    _eventSubscription.cancel();
    _mediaItemSubscription.cancel();
    _completer.complete();
  }

  @override
  void onAudioFocusLost() {
    onPause();
  }
}
