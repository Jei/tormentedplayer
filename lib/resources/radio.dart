import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/audio.dart';

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
  final AudioClient _audio;

  Radio(this._audio);

  RadioPlaybackState _audioToRadioPlaybackState(PlaybackState state) {
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

  Track _mediaItemToTrack(MediaItem item) => Track(
      title: item?.title,
      artist: item?.artist,
      album: (item?.album ?? '').isEmpty ? null : item.album,
      image: (item?.artUri ?? '').isEmpty ? null : item.artUri);

  void start() {
    BasicPlaybackState state =
        _audio.playbackState?.basicState ?? BasicPlaybackState.none;

    switch (state) {
      case BasicPlaybackState.paused:
        _audio.play();
        break;
      case BasicPlaybackState.none:
      case BasicPlaybackState.stopped:
      case BasicPlaybackState.error:
        _audio.start();
        break;
      default:
        break;
    }
  }

  void stop() => _audio.stop();

  bool get connected => _audio.connected;

  Stream<RadioPlaybackState> get playbackStateStream =>
      _audio.playbackStateStream.map(_audioToRadioPlaybackState);

  RadioPlaybackState get playbackState =>
      _audioToRadioPlaybackState(_audio.playbackState);

  Stream<Track> get currentTrackStream =>
      _audio.currentMediaItemStream.map(_mediaItemToTrack);

  Track get currentTrack =>
      _mediaItemToTrack(_audio.currentMediaItem);
}
