import 'dart:convert';

import 'package:http/http.dart' show Client, Response;
import 'package:tormentedplayer/models/track.dart';

class Api {
  final Client client;
  final String _url = 'tormented-player.web.app';
  final String _version = 'v1';

  Api(this.client);

  Future<Response> _get(String route, [Map<String, String> params]) async {
    Uri uri = Uri.https(_url, '/api/$_version$route', params ?? {});

    return client.get(uri);
  }

  Future<Track> getTrackInfo(String title, String artist) async {
    Response response = await _get('/track', {
      'title': title,
      'artist': artist,
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = await jsonDecode(response.body);

      return Track.fromJson(json);
    } else {
      throw Exception('Could not get track info: ${response.body}');
    }
  }
}
