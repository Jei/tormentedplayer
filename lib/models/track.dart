class Track {
  String title;
  String artist;
  String album;
  String image;

  Track({this.title, this.artist, this.album, this.image});

  String toString() =>
      '${this.title} - ${this.artist} - [${this.album}] - {${this.image}}';

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      image: json['image'],
    );
  }

  factory Track.fromFullTitle(String fullTitle) {
    if (fullTitle?.isEmpty ?? true) {
      return Track();
    }
    // Some tracks have no title/artist (they're probably jingles)
    final emptyMatch = RegExp(r'^Empty Title$').firstMatch(fullTitle);

    if (emptyMatch == null) {
      final match = RegExp(r'^(.*) - (.*)$').firstMatch(fullTitle);

      if (match != null) {
        return Track(
          title: match.group(2),
          artist: match.group(1),
        );
      }
    } else {
      return Track();
    }

    // If it's not empty and it's not a valid track, throw parse error
    throw Exception('Could not parse track from full title: $fullTitle');
  }
}
