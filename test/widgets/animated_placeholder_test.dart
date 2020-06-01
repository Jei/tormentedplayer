import 'package:flutter_test/flutter_test.dart';
import 'package:tormentedplayer/widgets/animated_placeholder.dart';

import '../utils.dart';

void main() {
  group('AnimatedPlaceholder', () {
    testWidgets('should render an animated placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(TestWrap(
        child: AnimatedPlaceholder(),
        bloc: null,
      ));
      await tester.pump(Duration(milliseconds: 100));

      expect(find.byType(AnimatedPlaceholder), findsOneWidget);
    });
  });
}
