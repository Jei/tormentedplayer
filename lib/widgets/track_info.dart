import 'package:flutter/cupertino.dart';
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
          Container(
            alignment: Alignment.center,
            height: 48.0,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 48.0,
            child: Text(
              artist,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
