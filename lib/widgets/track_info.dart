import 'package:flutter/material.dart';

class TrackInfo extends StatelessWidget {
  final String title;
  final String artist;

  const TrackInfo({Key key, this.title, this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
            maxLines: 1,
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            artist,
            style: Theme.of(context).textTheme.subtitle1,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
