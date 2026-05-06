import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:growbuddy/widgets/grow_bottom_navigation_bar.dart';

void main() {
  testWidgets('Bottom navigation renders all tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GrowBottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Misi'), findsOneWidget);
    expect(find.text('Notif'), findsOneWidget);
  });
}
