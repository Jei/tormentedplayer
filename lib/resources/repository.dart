import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/lastfm.dart' as lfm;
import 'package:tormentedplayer/services/tormentedradio.dart' as tr;

class Repository {
  final lfm.LastFM _lastFM = lfm.LastFM(lfm.LastFMConfig(
    apiKey: 'XXX', // TODO get the LastFM api key from a remote source
  ));
  final tr.TormentedRadio _tormentedRadio = tr.TormentedRadio();

  Track _trackFromLastFMTrack(lfm.Track lfmTrack) {
    return Track(
      title: lfmTrack?.name,
      artist: lfmTrack?.artist?.name,
      album: lfmTrack?.album?.title,
      image: lfmTrack?.album?.image?.extraLarge,
    );
  }

  Track _trackFromTRTrack(tr.Track trTrack) {
    return Track(
      title: trTrack?.name,
      artist: trTrack?.artist,
    );
  }

  Future<Track> fetchTrack(String title, String artist) async {
    lfm.Track lfmTrack =
        await _lastFM.getTrackInfo(track: title, artist: artist);
    return _trackFromLastFMTrack(lfmTrack);
  }

  Future<List<Track>> fetchHistory() async {
    tr.History trHistory = await _tormentedRadio.getHistory();

    return [
      _trackFromTRTrack(trHistory.current),
      ...trHistory.previous.map(_trackFromTRTrack),
    ];
  }
}
