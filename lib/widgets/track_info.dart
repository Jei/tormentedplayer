import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/models/track.dart';

class TrackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Track track = Provider.of<Track>(context);

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
              track?.title ?? '',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 48.0,
            child: Text(
              track?.artist ?? '',
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
