import 'package:html/dom.dart';
import 'package:tormentedplayer/models/track.dart';

class HistoryItem {
  DateTime time;
  Track track;

  HistoryItem({this.time, this.track});

  String toString() {
    return '${this.time.toLocal()} : ${this.track}';
  }

  factory HistoryItem.fromElement(Element element) {
    final DateTime now = DateTime.now();
    final String time = element.nodes[0]?.text;
    final String fullTitle = element.nodes[1]?.text ?? '';

    // Parse the track's time using the current DateTime as reference
    // Note: all the times from the history are UTC
    DateTime trackTime;
    if (time != null) {
      List<String> timeParts = time.split(':');
      trackTime = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
          0,
          0);
      trackTime = trackTime.add(trackTime.timeZoneOffset);

      if (trackTime.isAfter(now)) {
        trackTime = trackTime.subtract(Duration(days: 1));
      }
    } else {
      trackTime = now.subtract(Duration());
    }

    return HistoryItem(time: trackTime, track: Track.fromFullTitle(fullTitle));
  }
}
