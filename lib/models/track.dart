class Track {
  String title;
  String artist;
  String album;
  String image;

  Track({this.title, this.artist, this.album, this.image});

  String toString() =>
      '${this.title} - ${this.artist} - [${this.album}] - {${this.image}}';
}
