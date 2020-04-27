import 'dart:async';

import 'package:http/http.dart' show Client;
import 'package:rxdart/rxdart.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/resources/repository.dart';
import 'package:tormentedplayer/services/audio.dart';
import 'package:tormentedplayer/resources/radio.dart';

class RadioBloc {
  Repository _repository = Repository(Client());
  Radio _radio = Radio(AudioClient());

  final BehaviorSubject<Track> _apiTrackSubject = BehaviorSubject<Track>();
  final BehaviorSubject<Track> _trackSubject = BehaviorSubject<Track>();

  RadioBloc() {
    // Stream of the current Track from the API (when the radio is off)
    _apiTrackSubject.addStream(
      ConcatStream([
        Stream.value(null),
        Stream.periodic(Duration(seconds: 10)),
      ])
          .where(_canFetch)
          .switchMap((_) => Stream.fromFuture(_repository.fetchCurrentTrack()))
          // Check again for Audio activity, since the API call may complete later
          .where(_canFetch),
      cancelOnError: false,
    );

    // Merge with the stream from Radio, but emit only when the track changes
    _trackSubject.addStream(
      Rx.merge([
        _apiTrackSubject.stream,
        _radio.currentTrackStream.where(_isAudioActive),
      ])
          .transform(StreamTransformer<Track, Track>.fromHandlers(
            handleData: (track, sink) {
              if (_validateTrack(track)) {
                sink.add(track);
              }
            },
            handleError: (err, trace, sink) {
              print('Error while getting the current track: $err');
              sink.add(Track());
              throw(err);
            },
          ))
          .distinct(_compareTracks),
      cancelOnError: false,
    ); // Emit only when we have a different track
  }

  bool _validateTrack(Track track) =>
      track != null &&
      (track?.title ?? '').trim().isNotEmpty &&
      (track?.artist ?? '').trim().isNotEmpty;

  bool _compareTracks(Track t1, Track t2) =>
      t1?.title == t2?.title &&
      t1?.artist == t2?.artist &&
      ((t1?.album ?? '').isNotEmpty ||
          (t1?.album ?? '') == (t2?.album ?? '')) &&
      ((t1?.image ?? '').isNotEmpty || (t1?.image ?? '') == (t2?.image ?? ''));

  bool _isAudioActive(_) {
    switch (_radio.playbackState) {
      case RadioPlaybackState.playing:
      case RadioPlaybackState.connecting:
      case RadioPlaybackState.buffering:
        return true;
      default:
        return false;
    }
  }

  bool _canFetch(_) => _radio.connected && !_isAudioActive(_);

  Stream<Track> get trackStream => _trackSubject.stream;

  Track get track => _trackSubject.value;

  Stream<RadioPlaybackState> get playbackStateStream =>
      _radio.playbackStateStream;

  RadioPlaybackState get playbackState => _radio.playbackState;

  startRadio() => _radio.start();

  stopRadio() => _radio.stop();

  dispose() {
    _apiTrackSubject.close();
    _trackSubject.close();
  }
}
