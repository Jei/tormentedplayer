import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

class TormentedRadio {
  final String _historyUrl = 'http://stream2.mpegradio.com:8070/played.html';

  Future<History> getHistory() async {
    Response response = await get(_historyUrl);

    if (response.statusCode == 200) {
      return History.fromDocument(parse(response.body));
    } else {
      throw Exception('Could not get Tormented Radio history: ${response.body}');
    }
  }
}

class Track {
  String name;
  String artist;
  DateTime time;

  Track({this.name, this.artist, this.time});

  String toString() {
    return '${this.name} - ${this.artist}';
  }

  factory Track.fromElement(Element element) {
    final String time = element.nodes[0]?.text; // TODO parse time
    final String fullTitle = element.nodes[1]?.text;

    final emptyMatch = RegExp(r'^Empty Title$').firstMatch(fullTitle);

    if (emptyMatch == null) {
      final match = RegExp(r'^(.*) - (.*)$').firstMatch(fullTitle);

      if (match != null) {
        return Track(
          name: match.group(1) ?? '',
          artist: match.group(2) ?? '',
        );
      }
    }

    return Track(
      name: '',
      artist: '',
    );
  }
}

class History {
  Track current;
  List<Track> previous;

  History({this.current, this.previous});

  String toString() {
    return 'current: ${this.current}, previous: ${this.previous}';
  }

  factory History.fromDocument(Document document) {
    // Get all the table rows, minus the header row
    List<Element> tables = document.getElementsByTagName('table');
    if (tables.length < 2) return History();

    Element table = tables[1];
    List<Element> rows = table.getElementsByTagName('tr');
    rows.removeAt(0);

    if (rows.length == 0) {
      return History();
    }

    // Get the current track from the first row and the previous from the others
    return History(
      current: Track.fromElement(rows[0]),
      previous: rows
          .getRange(1, rows.length)
          .map((Element element) => Track.fromElement(element))
          .toList(),
    );
  }
}
