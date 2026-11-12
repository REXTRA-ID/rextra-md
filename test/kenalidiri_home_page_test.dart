import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rextra_app/features/kenalidiri/presentation/kenalidiri_home_page.dart';

void main() {
  testWidgets('Kenali Diri home: tanpa token palsu, kartu tes buka info',
      (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = GoRouter(initialLocation: '/kenali', routes: [
      GoRoute(path: '/kenali', builder: (_, __) => const KenaliDiriHomePage()),
      GoRoute(
          path: '/kenali/info',
          builder: (_, __) => const Scaffold(body: Text('INFO PAGE'))),
    ]);
    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();

    expect(find.text('BASIC - REXTRA CLUB'), findsOneWidget);
    expect(find.text('600'), findsNothing);
    expect(find.text('-'), findsOneWidget);

    await tester.tap(find.text('Tes Profil Karier'));
    await tester.pumpAndSettle();
    expect(find.text('INFO PAGE'), findsOneWidget);
  });
}
