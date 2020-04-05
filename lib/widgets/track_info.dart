import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';

class TrackInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return StreamBuilder<Track>(
      initialData: Track(),
      stream: _bloc.trackStream,
      builder: (context, snapshot) {
        Track track = snapshot.data;

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
      },
    );
  }
}
