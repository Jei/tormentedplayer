import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';

class TestWrap extends StatelessWidget {
  final Widget child;
  final RadioBloc bloc;

  const TestWrap({Key key, this.bloc, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Provider<RadioBloc>.value(
          value: bloc,
          child: child,
        ),
      ),
    );
  }
}
