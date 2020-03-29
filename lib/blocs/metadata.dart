import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';

class MetadataBloc {
  Repository _repository = Repository();

  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();

  // TODO get data from Tormented Radio when AudioService is not connected or stopped
  // Stream 1: title/artist from AudioService
  // Stream 2: complete Track object from the last API call
  MetadataBloc() {
    _trackSubject.addStream(Rx.merge([
      AudioService.currentMediaItemStream
          .map((item) => Track(title: item?.title, artist: item?.artist)),
      AudioService.currentMediaItemStream
          .where(_validateMediaItem)
          .transform(SwitchMapStreamTransformer(
              (item) => Stream.fromFuture(_fetchTrack(item))))
          .where(_validateTrack),
    ]));
  }

  Stream<Track> get trackStream => _trackSubject.stream;

  static bool _validateMediaItem(MediaItem item) =>
      (item?.title ?? '').isNotEmpty && (item?.artist ?? '').isNotEmpty;

  static bool _validateTrack(Track track) =>
      (track?.title ?? '').isNotEmpty && (track?.artist ?? '').isNotEmpty;

  Future<Track> _fetchTrack(MediaItem item) =>
      _repository.fetchTrack(item?.title, item?.artist).catchError((err) {
        print(err);
        return Track();
      });

  dispose() {
    _trackSubject.close();
  }
}
