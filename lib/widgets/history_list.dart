import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/history_item.dart';

class HistoryList extends StatelessWidget {
  final ScrollController controller;
  final bool showHandle;

  const HistoryList({Key key, this.controller, this.showHandle = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RadioBloc _bloc = Provider.of<RadioBloc>(context);

    return StreamBuilder<List<HistoryItem>>(
      stream: _bloc.historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // TODO error state
          return Center();
        }

        if (snapshot.hasData) {
          final history = snapshot.data;

          return ListView.builder(
            controller: controller,
            itemCount: history.length + (showHandle ? 1 : 0),
            itemBuilder: (context, index) {
              if (showHandle && index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                  child: Column(
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).iconTheme.color,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const SizedBox(width: 72.0, height: 8.0),
                      ),
                    ],
                  ),
                );
              }

              final item = history[index - (showHandle ? 1 : 0)];
              final track = item.track;
              return ListTile(
                title: Text(track.title),
                subtitle: Text(track.artist),
                trailing: Text(item.time.toString()),
              );
            },
          );
        } else {
          return const Center(
            child: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
