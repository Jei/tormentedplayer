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

    return get(uri, headers: {
      HttpHeaders.userAgentHeader: this.config.userAgent,
    });
  }

  Future<Track> getTrackInfo(
      {String track, String artist, String mbid}) async {
    Response response = mbid != null
        ? await _get({
            'method': 'track.getInfo',
            'mbid': mbid,
          })
        : await _get({
            'method': 'track.getInfo',
            'track': track,
            'artist': artist,
          });

    if (response.statusCode == 200) {
      Map<String, dynamic> json = await jsonDecode(response.body);
      
      if (json['track'] == null) {
        throw Exception('Could not get track info: missing track from response body');
      }

      return Track.fromJson(json['track']);
    } else {
      throw Exception('Could not get track info: ${response.body}');
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

class Album {
  String artist;
  String title;
  String mbid;
  String url;
  Image image;

  Album({this.artist, this.title, this.mbid, this.url, this.image});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      artist: json['artist'],
      title: json['title'],
      mbid: json['mbid'],
      url: json['url'],
      image: Image.fromJson(json['image']),
    );
  }
}

class Artist {
  String name;
  String mbid;
  String url;

  Artist({this.name, this.mbid, this.url});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'],
      mbid: json['mbid'],
      url: json['url'],
    );
  }
}

class Image {
  String small;
  String medium;
  String large;
  String extraLarge;

  Image({this.small, this.medium, this.large, this.extraLarge});

  factory Image.fromJson(List json) {
    Map<String, String> urls = {};

    for (Map<String, dynamic> img in json) {
      urls[img['size']] = img['#text'];
    }

    return Image(
      small: urls['small'],
      medium: urls['medium'],
      large: urls['large'],
      extraLarge: urls['extraLarge'],
    );
  }
}

class Track {
  String name;
  Artist artist;
  String url;
  int duration;
  Album album;
  String mbid;

  Track(
      {this.name, this.artist, this.url, this.duration, this.album, this.mbid});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      name: json['name'],
      artist: Artist.fromJson(json['artist']),
      url: json['url'],
      duration: int.tryParse(json['duration']),
      album: Album.fromJson(json['album']),
      mbid: json['mbid'],
    );
  }
}
