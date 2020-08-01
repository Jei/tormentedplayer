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
    AudioProcessingState processingState = state?.processingState;

    switch (processingState) {
      case AudioProcessingState.error:
        return RadioPlaybackState.error;
      case AudioProcessingState.stopped:
        return RadioPlaybackState.stopped;
      case AudioProcessingState.ready:
        return state?.playing == true
            ? RadioPlaybackState.playing
            : RadioPlaybackState.paused;
      case AudioProcessingState.buffering:
        return RadioPlaybackState.buffering;
      case AudioProcessingState.connecting:
        return RadioPlaybackState.connecting;
      case AudioProcessingState.fastForwarding:
      case AudioProcessingState.rewinding:
      case AudioProcessingState.skippingToPrevious:
      case AudioProcessingState.skippingToNext:
      case AudioProcessingState.skippingToQueueItem:
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

  // Starts the audio service or resumes audio playback
  void start() {
    RadioPlaybackState currentState =
        _audioToRadioPlaybackState(_audio.playbackState);

    switch (currentState) {
      case RadioPlaybackState.paused:
        _audio.play();
        break;
      case RadioPlaybackState.none:
      case RadioPlaybackState.stopped:
      case RadioPlaybackState.error:
        _audio.start();
        break;
      default:
        break;
    }
  }

  // Pauses audio playback
  void pause() => _audio.pause();

  // Stops audio playback and the audio service
  void stop() => _audio.stop();

  bool get connected => _audio.connected;

  Stream<RadioPlaybackState> get playbackStateStream =>
      _audio.playbackStateStream.map(_audioToRadioPlaybackState);

  RadioPlaybackState get playbackState =>
      _audioToRadioPlaybackState(_audio.playbackState);

  Stream<Track> get currentTrackStream =>
      _audio.currentMediaItemStream.map(_mediaItemToTrack);

  Track get currentTrack => _mediaItemToTrack(_audio.currentMediaItem);
}
