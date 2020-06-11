import 'package:flutter/material.dart';
import 'package:tormentedplayer/pages/settings_page.dart';
import 'package:tormentedplayer/widgets/background_gradient.dart';
import 'package:tormentedplayer/widgets/history_bottom_sheet.dart';
import 'package:tormentedplayer/widgets/player_layout.dart';

class HomePage extends StatelessWidget {
  static final String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Theme.of(context).iconTheme.color,
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BackgroundGradient(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
              child: PlayerLayout(
                onHistoryPressed: () => _openHistoryList(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openHistoryList(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: HistoryBottomSheet(),
    ),
  );
}
