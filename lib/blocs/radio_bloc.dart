import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';
import 'package:tormentedplayer/services/radio.dart';

class RadioBloc {
  Repository _repository = Repository();

  final BehaviorSubject<Track> _apiTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _radioTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();

  // TODO write some custom transformers, because this stuff is unreadable
  RadioBloc() {
    // Stream of the current Track from the API (when the radio is off)
    _apiTrackSubject.addStream(ConcatStream([
      Stream.value(null),
      Stream.periodic(Duration(seconds: 10)),
    ])
        .where(_isAudioInactive)
        .switchMap((_) => Stream.fromFuture(_repository.fetchCurrentTrack()))
        // Check again for Audio activity, since the API call may complete later
        .where(_isAudioInactive));

    // Stream of the current track (title and artist only) from the radio
    _radioTrackSubject.addStream(Radio.currentTrackStream
        .distinct(_compareTracks)
        .switchMap(_getFullTrackStream));

    // Merge the two streams, but emit only when the track changes
    _trackSubject.addStream(Rx.merge([
      _apiTrackSubject.stream,
      _radioTrackSubject.stream,
    ]).distinct(_compareTracks)); // Emit only when we have a different track
  }

  Stream<Track> _getFullTrackStream(Track item) async* {
    if (_isAudioInactive(null) || !_validateTrack(item)) return;

    yield item;

    try {
      Track fullTrack = await _repository.fetchTrack(item?.title, item?.artist);
      if (_isAudioInactive(null) || !_validateTrack(fullTrack)) return;
      yield fullTrack;
    } catch (err) {
      print(err);
    }
  }

  static bool _validateTrack(Track track) =>
      track != null &&
      (track?.title ?? '').trim().isNotEmpty &&
      (track?.artist ?? '').trim().isNotEmpty;

  static bool _compareTracks(Track t1, Track t2) =>
      t1?.title?.toLowerCase() == t2?.title?.toLowerCase() &&
      t1?.artist?.toLowerCase() == t2?.artist?.toLowerCase() &&
      t1?.album != null &&
      t1?.image != null;

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

  static bool _isAudioInactive(_) => !_isAudioActive(_);

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
    _radioTrackSubject.close();
    _trackSubject.close();
  }
}
