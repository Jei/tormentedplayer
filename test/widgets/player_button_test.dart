import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tormentedplayer/resources/radio.dart';
import 'package:tormentedplayer/widgets/player_button.dart';

import '../utils.dart';

void main() {
  group('PlayerButton', () {
    testWidgets(
        'should display a progress indicator while the radio is loading',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.connecting));

      await tester.pumpWidget(TestWrap(
        child: PlayerButton(),
        bloc: bloc,
      ));
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display a play icon while the radio is stopped',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.stopped));

      await tester.pumpWidget(TestWrap(child: PlayerButton(), bloc: bloc));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should display a pause icon while the radio is playing',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.playing));

      await tester.pumpWidget(TestWrap(
        child: PlayerButton(),
        bloc: bloc,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('should call play when tapped while the radio is stopped',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.stopped));

      await tester.pumpWidget(TestWrap(
        child: PlayerButton(),
        bloc: bloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PlayerButton));
      verify(bloc.startRadio());
    });

    testWidgets('should call stop when tapped while the radio is playing',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.playing));

      await tester.pumpWidget(TestWrap(
        child: PlayerButton(),
        bloc: bloc,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PlayerButton));
      verify(bloc.stopRadio());
    });

    testWidgets('should ignore interactions while the radio is connecting',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.playbackStateStream)
          .thenAnswer((_) => Stream.value(RadioPlaybackState.connecting));

      await tester.pumpWidget(TestWrap(
        child: PlayerButton(),
        bloc: bloc,
      ));
      await tester.pump(Duration(milliseconds: 100));

      await tester.tap(find.byType(PlayerButton));
      verifyNever(bloc.stopRadio());
      verifyNever(bloc.startRadio());
    });
  });
}
