import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rextra_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our real app
    await tester.pumpWidget(const ProviderScope(child: RextraApp()));

    // Karena tidak ada counter demo, kita tes widget lain yang pasti ada.
    // Misal, splash page teks atau logo.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
