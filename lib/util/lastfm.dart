import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

class LastFM {
  LastFMConfig config = LastFMConfig();

  LastFM(this.config);

  Future<Response> _get(Map<String, String> params) async {
    Map<String, String> getParams = {
      'api_key': this.config.apiKey,
      'format': 'json',
    };
    if (params != null) {
      getParams.addAll(params);
    }

    Uri uri = Uri.https(
        '${this.config.host}', '/${this.config.apiVersion}/', getParams);

    print(uri.toString());

    return get(uri, headers: {
      HttpHeaders.userAgentHeader: this.config.userAgent,
    });
  }

  Future<Map<String, dynamic>> searchTrack(String title, String artist) async {
    Response response = await _get({
      'method': 'track.search',
      'track': title,
      'artist': artist,
      'limit': '1',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Could not search track: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTrackInfo(String mbid) async {
    Response response = await _get({
      'method': 'track.getInfo',
      'mbid': mbid,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Could not search track: ${response.body}');
    }
  }
}

class LastFMConfig {
  final String host;
  final String userAgent;
  final String apiVersion;
  final String apiKey;

  LastFMConfig({
    this.host = 'ws.audioscrobbler.com',
    this.userAgent =
        'TormentedPlayer/1.0.0+1', // TODO read version number from pubspec
    this.apiVersion = '2.0',
    this.apiKey,
  });
}
