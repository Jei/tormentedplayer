import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/pages/home_page.dart';
import 'package:tormentedplayer/pages/settings_page.dart';
import 'package:tormentedplayer/theme/style.dart';

import 'models/app_theme_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  // Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  await PrefService.init(prefix: 'pref_');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  RadioBloc _radioBloc = RadioBloc();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  void initState() {
    analytics.logAppOpen();
    _radioBloc.connectToRadio();

    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void dispose() {
    _radioBloc.disconnectFromRadio();
    _radioBloc.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _radioBloc?.disconnectFromRadio();
        break;
      case AppLifecycleState.resumed:
        _radioBloc?.connectToRadio();
        break;
      default:
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeMode>(
          create: (context) => AppThemeMode(
            initialValue: ThemeMode.values[PrefService.getInt('theme') ?? 0],
          ),
        ),
        Provider<RadioBloc>.value(
          value: _radioBloc,
        ),
      ],
      child: Consumer2<AppThemeMode, RadioBloc>(
        builder: (context, appMode, radioBloc, child) {
          return MaterialApp(
            title: 'Tormented Player',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appMode?.currentMode ?? ThemeMode.system,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            initialRoute: HomePage.routeName,
            routes: {
              HomePage.routeName: (context) => WillPopScope(
                    onWillPop: () {
                      radioBloc?.disconnectFromRadio();
                      return Future.value(true);
                    },
                    child: HomePage(),
                  ),
              SettingsPage.routeName: (context) => SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
