import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/lastfm.dart' as lfm;

class Repository {
  final lfm.LastFM _lastFM = lfm.LastFM(lfm.LastFMConfig(
    apiKey: 'XXX', // TODO get the LastFM api key from a remote source
  ));

  Track _trackFromLastFMTrack(lfm.Track lfmTrack) {
    return Track(
      title: lfmTrack?.name,
      artist: lfmTrack?.artist?.name,
      album: lfmTrack?.album?.title,
      image: lfmTrack?.album?.image?.extraLarge,
    );
  }

  Future<Track> fetchTrack(String title, String artist) async {
    lfm.Track lfmTrack =
        await _lastFM.getTrackInfo(track: title, artist: artist);
    return _trackFromLastFMTrack(lfmTrack);
  }
}
