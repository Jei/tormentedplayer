import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/blocs/radio_bloc.dart';
import 'package:tormentedplayer/models/track.dart';
import 'package:tormentedplayer/widgets/animated_placeholder.dart';
import 'package:tormentedplayer/widgets/track_info.dart';

class MockRadioBloc extends Mock implements RadioBloc {}

void main() {
  group('TrackInfo', () {
    testWidgets(
        'should display animated placeholders when no data is available',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.trackStream).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(wrapWidget(TrackInfo(), bloc));
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(AnimatedPlaceholder), findsNWidgets(3));
    });

    testWidgets(
        'should display track data when available',
            (WidgetTester tester) async {
          final bloc = MockRadioBloc();
          final track = Track(
            title: 'Fuse',
            artist: 'Ed Harrison',
            album: 'TGR Fuel',
          );

          when(bloc.trackStream).thenAnswer((_) => Stream.value(track));

          await tester.pumpWidget(wrapWidget(TrackInfo(), bloc));
          await tester.pump(Duration(milliseconds: 100));

          expect(find.text(track.title), findsOneWidget);
          // The artist's name and album should be uppercase
          expect(find.text(track.artist.toUpperCase()), findsOneWidget);
          expect(find.text(track.album.toUpperCase()), findsOneWidget);
        });
  });
}

Widget wrapWidget(Widget child, RadioBloc bloc) {
  return MaterialApp(
    home: Scaffold(
      body: Provider<RadioBloc>.value(
        value: bloc,
        child: child,
      ),
    ),
  );
}
