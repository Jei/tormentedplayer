import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/history_item.dart';

class HistoryList extends StatelessWidget {
  final ScrollController controller;
  final bool showHandle;
  final int _headerLength;

  const HistoryList({
    Key key,
    this.controller,
    this.showHandle = false,
  })  : _headerLength = showHandle ? 2 : 1,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final RadioBloc bloc = Provider.of<RadioBloc>(context);
    final DateFormat formatter = DateFormat.Hm();
    final ThemeData theme = Theme.of(context);

    return StreamBuilder<List<HistoryItem>>(
      stream: bloc.historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // TODO error state
          return Center();
        }

        if (snapshot.hasData) {
          final history = snapshot.data;

          return ListView.builder(
            controller: controller,
            itemCount: history.length + _headerLength,
            itemBuilder: (context, index) {
              if (showHandle && index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).iconTheme.color,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                        child: const SizedBox(width: 80.0, height: 6.0),
                      ),
                    ],
                  ),
                );
              } else if (index < _headerLength) {
                return ListTile(
                  title: Text(
                    'Recent tracks',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final item = history[index - _headerLength];
              final track = item.track;
              return ListTile(
                title: Text(
                  track.title ?? '',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  track.artist ?? '',
                  style: TextStyle(color: theme.accentColor),
                ),
                trailing: Text(
                  item.time != null ? formatter.format(item.time) : '',
                  style: TextStyle(fontSize: 16),
                ),
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
