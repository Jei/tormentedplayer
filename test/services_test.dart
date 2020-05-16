import 'package:http/http.dart' show Client, Response;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/services/api.dart';
import 'package:tormentedplayer/services/tormentedradio.dart';

class MockClient extends Mock implements Client {}

main() {
  // services/tormentedradio.dart
  group('TormentedRadio service', () {
    group('getCurrentTrack tests', () {
      test('Returns a Track with title and artist on success', () async {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('''<SHOUTCASTSERVER>
<CURRENTLISTENERS>30</CURRENTLISTENERS>
<PEAKLISTENERS>100</PEAKLISTENERS>
<MAXLISTENERS>100</MAXLISTENERS>
<UNIQUELISTENERS>28</UNIQUELISTENERS>
<AVERAGETIME>56160</AVERAGETIME>
<SERVERGENRE>Industrial</SERVERGENRE>
<SERVERGENRE2/>
<SERVERGENRE3/>
<SERVERGENRE4/>
<SERVERGENRE5/>
<SERVERURL>http://www.tormentedradio.com</SERVERURL>
<SERVERTITLE>-=- tormented radio -=- streaming since 1998</SERVERTITLE>
<SONGTITLE>Syrian - Destiny Sunrise</SONGTITLE>
<STREAMHITS>11491903</STREAMHITS>
<STREAMSTATUS>1</STREAMSTATUS>
<BACKUPSTATUS>0</BACKUPSTATUS>
<STREAMLISTED>1</STREAMLISTED>
<STREAMPATH>/tormented.mp3</STREAMPATH>
<STREAMUPTIME>1118</STREAMUPTIME>
<BITRATE>128</BITRATE>
<SAMPLERATE>44100</SAMPLERATE>
<CONTENT>audio/mpeg</CONTENT>
<VERSION>2.5.5.733 (posix(linux x64))</VERSION>
</SHOUTCASTSERVER>''', 200));

        var response = await tr.getCurrentTrack();
        expect(response, TypeMatcher<Track>());
        expect(response.title, 'Destiny Sunrise');
        expect(response.artist, 'Syrian');
        expect(response.image, null);
        expect(response.album, null);
      });

      test('Throws exception on invalid response data', () {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('Some stuff', 200));

        expect(tr.getCurrentTrack(), throwsException);
      });

      test('Throws exception on incomplete response data', () {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('''<SHOUTCASTSERVER>
<SERVERURL>http://www.tormentedradio.com</SERVERURL>
<SERVERTITLE>-=- tormented radio -=- streaming since 1998</SERVERTITLE>
<VERSION>2.5.5.733 (posix(linux x64))</VERSION>
</SHOUTCASTSERVER>''', 200));

        expect(tr.getCurrentTrack(), throwsException);
      });

      test('Returns empty Track when the title is empty', () async {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('''<SHOUTCASTSERVER>
<SONGTITLE></SONGTITLE>
</SHOUTCASTSERVER>''', 200));

        var response = await tr.getCurrentTrack();
        expect(response, TypeMatcher<Track>());
        expect(response.title, null);
        expect(response.artist, null);
        expect(response.image, null);
        expect(response.album, null);
      });

      test('Throws exception on error response', () {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('Internal server error', 500));

        expect(tr.getCurrentTrack(), throwsException);
      });

      test('Handles UTF-8 characters', () async {
        final client = MockClient();
        final tr = TormentedRadio(client);

        when(client.get('http://stream2.mpegradio.com:8070/stats'))
            .thenAnswer((_) async => Response('''<SHOUTCASTSERVER>
<SERVERURL>http://www.tormentedradio.com</SERVERURL>
<SERVERTITLE>-=- tormented radio -=- streaming since 1998</SERVERTITLE>
<SONGTITLE>HeimatÃ¦rde - Du Fehlst Mir</SONGTITLE>
<VERSION>2.5.5.733 (posix(linux x64))</VERSION>
</SHOUTCASTSERVER>''', 200));

        var response = await tr.getCurrentTrack();
        expect(response, TypeMatcher<Track>());
        expect(response.title, 'Du Fehlst Mir');
        expect(response.artist, 'Heimatærde');
        expect(response.image, null);
        expect(response.album, null);
      });
    });
  });

  // services/api.dart
  group('Api service', () {
    group('getTrackInfo tests', () {
      test('Should return a Track on success', () async {
        final client = MockClient();
        final api = Api(client);

        when(client.get(Uri.https('tormented-player.web.app', '/api/v1/track', {
          'title': 'Destiny Sunrise',
          'artist': 'Syrian'
        }))).thenAnswer((_) async => Response(
            '{"title":"Destiny Sunrise","artist":"Syrian","album":"Alien Nation","image":"https://lastfm.freetls.fastly.net/i/u/300x300/8bee9373caa042dcabc57723e09b26ee.png"}',
            200));

        var response = await api.getTrackInfo('Destiny Sunrise', 'Syrian');
        expect(response, TypeMatcher<Track>());
        expect(response.title, 'Destiny Sunrise');
        expect(response.artist, 'Syrian');
        expect(response.album, 'Alien Nation');
        expect(response.image,
            'https://lastfm.freetls.fastly.net/i/u/300x300/8bee9373caa042dcabc57723e09b26ee.png');
      });

      test('Returns a Track when album and image are missing from the response',
          () async {
        final client = MockClient();
        final api = Api(client);

        when(client.get(Uri.https('tormented-player.web.app', '/api/v1/track', {
          'title': 'Destiny Sunrise',
          'artist': 'Syrian'
        }))).thenAnswer((_) async => Response(
            '{"title":"Destiny Sunrise","artist":"Syrian","album":null,"image":null}',
            200));

        var response = await api.getTrackInfo('Destiny Sunrise', 'Syrian');
        expect(response, TypeMatcher<Track>());
        expect(response.title, 'Destiny Sunrise');
        expect(response.artist, 'Syrian');
        expect(response.album, null);
        expect(response.image, null);
      });

      test('Throws exception on invalid data', () {
        final client = MockClient();
        final api = Api(client);

        when(client.get(Uri.https('tormented-player.web.app', '/api/v1/track', {
          'title': 'Destiny Sunrise',
          'artist': 'Syrian'
        }))).thenAnswer(
            (_) async => Response('Not what you were expecting', 200));

        expect(api.getTrackInfo('Destiny Sunrise', 'Syrian'), throwsException);
      });

      test('Throws exception on error response', () {
        final client = MockClient();
        final api = Api(client);

        when(client.get(Uri.https('tormented-player.web.app', '/api/v1/track', {
          'title': 'Destiny Sunrise',
          'artist': 'Syrian',
        }))).thenAnswer((_) async =>
            Response('{"status":404,"message":"Track not found"}', 404));

        expect(api.getTrackInfo('Destiny Sunrise', 'Syrian'), throwsException);
      });

      test('Handles UTF-8 characters', () async {
        final client = MockClient();
        final api = Api(client);

        when(client.get(Uri.https('tormented-player.web.app', '/api/v1/track', {
          'title': 'Dédale',
          'artist': 'Aïboforcen',
        }))).thenAnswer((_) async => Response(
            '{"title":"Dédale","artist":"Aïboforcen","album":null,"image":null}',
            200));

        var response = await api.getTrackInfo('Dédale', 'Aïboforcen');
        expect(response, TypeMatcher<Track>());
        expect(response.title, 'Dédale');
        expect(response.artist, 'Aïboforcen');
        expect(response.album, null);
        expect(response.image, null);
      });
    });
  });
}
