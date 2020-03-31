import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';

class MetadataBloc {
  Repository _repository = Repository();

  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _partialTrackSubject = BehaviorSubject<Track>();

  MetadataBloc() {
    // Stream 1: partial Track data from AudioService
    // Stream 2: partial Track data from Tormented Radio every 10 seconds (only when AudioService is not playing)
    _partialTrackSubject.addStream(Rx.merge<Track>([
      AudioService.currentMediaItemStream
          .where(_isAudioActive)
          .map((item) => Track(title: item?.title, artist: item?.artist)),
      ConcatStream([
        Stream.value(null),
        Stream.periodic(Duration(seconds: 10)),
      ])
          .where(_isAudioInactive)
          .transform(SwitchMapStreamTransformer(
              (_) => Stream.fromFuture(_fetchPartialTrack())))
          .where(_isAudioInactive),
      // Check again for Audio activity, since the API call may complete later
    ]).where(_validateTrack).distinct(_compareTracks));

    // Stream 1: partial Track data from the current source (AudioService or Tormented Radio Shout website)
    // Stream 2: complete Track data from the last LastFM API call
    _trackSubject.addStream(Rx.merge([
      _partialTrackSubject.stream,
      _partialTrackSubject.stream.transform(SwitchMapStreamTransformer(
          (item) => Stream.fromFuture(_fetchFullTrack(item)))),
    ]).distinct(_compareTracks)); // Emit only when we have a different track
  }

  Stream<Track> get trackStream => _trackSubject.stream;

  Track get track => _trackSubject.value;

  static bool _validateTrack(Track track) =>
      track != null &&
      (track?.title ?? '').isNotEmpty &&
      (track?.artist ?? '').isNotEmpty;

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

  // Fetch full track data from the repository and combine with the partial data.
  // We don't use title and artist from the repository because they could be different from the originals.
  Future<Track> _fetchFullTrack(Track track) => _repository
          .fetchTrack(track?.title, track?.artist)
          .then((Track full) => Track(
                title: track.title,
                artist: track.artist,
                album: full.album,
                image: full.image,
              ))
          .catchError((err) {
        print(err);
        return null;
      });

  Future<Track> _fetchPartialTrack() =>
      _repository.fetchHistory().catchError((err) {
        print(err);
        return [Track()];
      }).then((list) => list.length > 0 ? list[0] : Track());

  dispose() {
    _partialTrackSubject.close();
    _trackSubject.close();
  }
}
