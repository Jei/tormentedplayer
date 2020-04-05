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
}
