import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/api.dart';

class Repository {
  final Api api = Api();

  Future<Track> fetchTrack(String title, String artist) =>
      api.getTrackInfo(title, artist);

  Future<Track> fetchCurrentTrack() => api.getCurrentTrack();
}
