import 'package:http/http.dart' show Client, Response;
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'package:tormentedplayer/models/history_item.dart';
import 'package:tormentedplayer/models/track.dart';

class TormentedRadio {
  final Client client;
  final String _historyUrl = 'http://stream2.mpegradio.com:8070/played.html';
  final String _statsUrl = 'http://stream2.mpegradio.com:8070/stats';

  TormentedRadio(this.client);

  static Track _parseStats(String body) {
    List<Element> tags = parse(body).getElementsByTagName('SONGTITLE');
    if (tags.length < 1) {
      throw Exception('Invalid Tormented Radio stats XML data');
    }

    Node node = tags[0].nodes.isNotEmpty ? tags[0].nodes[0] : null;

    return Track.fromFullTitle(node?.text);
  }

  static List<HistoryItem> _parseHistory(String body) {
    List<Element> tables = parse(body).getElementsByTagName('table');
    if (tables.length < 2) {
      throw Exception('Invalid Tormented Radio history data');
    }

    // Get all the table rows, minus the header row
    Element table = tables[1];
    List<Element> rows = table.getElementsByTagName('tr');
    rows.removeAt(0);

    if (rows.length == 0) {
      throw Exception('Invalid Tormented Radio history data');
    }

    // Get the tracks from each row
    return rows.map((Element element) => HistoryItem.fromElement(element));
  }

  Future<List<HistoryItem>> getHistory() async {
    Response response = await client.get(_historyUrl);

    if (response.statusCode == 200) {
      return _parseHistory(response.body);
    } else {
      throw Exception(
          'Could not get Tormented Radio history: ${response.body}');
    }
  }

  Future<Track> getCurrentTrack() async {
    // TODO solve UTF-8 encoding problem
    Response response = await client.get(_statsUrl);

    if (response.statusCode == 200) {
      return _parseStats(response.body);
    } else {
      throw Exception(
          'Could not get the current track from Tormented Radio: ${response.body}');
    }
  }
}
