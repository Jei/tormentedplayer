import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';
import 'package:tormentedplayer/services/radio.dart';

class RadioBloc {
  Repository _repository = Repository();

  final BehaviorSubject<Track> _apiTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();

  RadioBloc() {
    // Stream of the current Track from the API (when the radio is off)
    _apiTrackSubject.addStream(ConcatStream([
      Stream.value(null),
      Stream.periodic(Duration(seconds: 10)),
    ])
        .where(_canFetch)
        .switchMap((_) => Stream.fromFuture(_repository.fetchCurrentTrack()))
        // Check again for Audio activity, since the API call may complete later
        .where(_canFetch));

    // Merge with the stream from Radio, but emit only when the track changes
    _trackSubject.addStream(Rx.merge([
      _apiTrackSubject.stream,
      Radio.currentTrackStream.where(_isAudioActive),
    ])
        .where(_validateTrack)
        .distinct(_compareTracks)); // Emit only when we have a different track
  }

  static bool _validateTrack(Track track) {
    bool res = track != null &&
        (track?.title ?? '').trim().isNotEmpty &&
        (track?.artist ?? '').trim().isNotEmpty;

    return res;
  }

  static bool _compareTracks(Track t1, Track t2) =>
      t1?.title == t2?.title &&
      t1?.artist == t2?.artist &&
      ((t1?.album ?? '').isNotEmpty ||
          (t1?.album ?? '') == (t2?.album ?? '')) &&
      ((t1?.image ?? '').isNotEmpty || (t1?.image ?? '') == (t2?.image ?? ''));

  static bool _isAudioActive(_) {
    switch (Radio.playbackState) {
      case RadioPlaybackState.playing:
      case RadioPlaybackState.connecting:
      case RadioPlaybackState.buffering:
        return true;
      default:
        return false;
    }
  }

  static bool _canFetch(_) {
    return Radio.connected && !_isAudioActive(_);
  }

  Stream<Track> get trackStream => _trackSubject.stream;

  Track get track => _trackSubject.value;

  Stream<RadioPlaybackState> get playbackStateStream =>
      Radio.playbackStateStream;

  RadioPlaybackState get playbackState => Radio.playbackState;

  startRadio() => Radio.start();

  stopRadio() => Radio.stop();

  connectToRadio() => Radio.connect();

  disconnectFromRadio() => Radio.disconnect();

  dispose() {
    _apiTrackSubject.close();
    _trackSubject.close();
  }
}
