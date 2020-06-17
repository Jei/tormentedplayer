import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tormentedplayer/widgets/background_gradient.dart';

import '../utils.dart';

void main() {
  group('BackgroundGradient', () {
    testWidgets('should render a custom linear gradient',
        (WidgetTester tester) async {
      final bloc = MockRadioBloc();

      when(bloc.trackStream).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(TestWrap(
        child: BackgroundGradient(),
        bloc: bloc,
      ));
      await tester.pump(Duration(milliseconds: 100));

      expect(
          find.byWidgetPredicate((widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).gradient is LinearGradient),
          findsOneWidget);
    });
  });
}
