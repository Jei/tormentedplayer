import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';

class MetadataBloc {
  Repository _repository = Repository();

  final BehaviorSubject<Track> _apiTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _radioTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _partialTrackSubject = BehaviorSubject<Track>();

  // TODO write some custom transformers, because this stuff is unreadable
  MetadataBloc() {
    // Stream of the current Track from the API (when the radio is off)
    _apiTrackSubject.addStream(ConcatStream([
      Stream.value(null),
      Stream.periodic(Duration(seconds: 10)),
    ])
        .where(_isAudioInactive)
        .transform(SwitchMapStreamTransformer(
            (_) => Stream.fromFuture(_repository.fetchCurrentTrack())))
        // Check again for Audio activity, since the API call may complete later
        .where(_isAudioInactive));

    // Stream of the current track (title and artist only) from the radio
    _radioTrackSubject.addStream(AudioService.currentMediaItemStream
        .where(_isAudioActive)
        .map((item) => Track(title: item?.title, artist: item?.artist))
        .where(_validateTrack)
        .distinct(_compareTracks));

    // Merge the two streams with a third, produced by another API call
    _trackSubject.addStream(Rx.merge([
      _apiTrackSubject.stream,
      _radioTrackSubject.stream,
      _radioTrackSubject.stream.transform(SwitchMapStreamTransformer((item) =>
          Stream.fromFuture(
              _repository.fetchTrack(item?.title, item?.artist)))),
    ]).distinct(_compareTracks)); // Emit only when we have a different track
  }

  Stream<Track> get trackStream => _trackSubject.stream;

  Track get track => _trackSubject.value;

  static bool _validateTrack(Track track) =>
      track != null &&
      (track?.title ?? '').trim().isNotEmpty &&
      (track?.artist ?? '').trim().isNotEmpty;

  static bool _compareTracks(Track t1, Track t2) =>
      t1?.title?.toLowerCase() == t2?.title?.toLowerCase() &&
      t1?.artist?.toLowerCase() == t2?.artist?.toLowerCase() &&
      t1?.album?.toLowerCase() == t2?.album?.toLowerCase() &&
      t1?.image?.toLowerCase() == t2?.image?.toLowerCase();

  static bool _isAudioActive(_) {
    BasicPlaybackState state = AudioService.playbackState?.basicState;

    switch (state) {
      case BasicPlaybackState.playing:
      case BasicPlaybackState.connecting:
      case BasicPlaybackState.buffering:
        return true;
      default:
        return false;
    }
  }

  static bool _isAudioInactive(_) => !_isAudioActive(_);

  dispose() {
    _partialTrackSubject.close();
    _trackSubject.close();
  }
}
