import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/api.dart';
import 'package:tormentedplayer/services/tormentedradio.dart';

class Repository {
  final Api _api;
  final TormentedRadio _tormentedRadio;

  Repository(client)
      : _api = Api(client),
        _tormentedRadio = TormentedRadio(client);

  Future<Track> fetchTrack(String title, String artist) =>
      _api.getTrackInfo(title, artist);

  Future<Track> fetchCurrentTrack() async {
    Track currentTrack = await _tormentedRadio.getCurrentTrack();

    return _api.getTrackInfo(currentTrack?.title, currentTrack?.artist);
  }
}
