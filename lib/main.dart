import 'package:flutter/material.dart';
import 'package:tormentedplayer/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.redAccent,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme,
      darkTheme: theme,
      home: HomePage(),
    );
  }
}
