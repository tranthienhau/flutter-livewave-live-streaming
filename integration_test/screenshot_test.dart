import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:livewave/app/router.dart';
import 'package:livewave/main.dart' as app;

/// Walks every key screen and captures a real PNG of each one.
/// Fixed pumps (not pumpAndSettle) because the live rooms animate forever.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> wait(WidgetTester t, [int ms = 1500]) =>
      t.pump(Duration(milliseconds: ms));

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 600);
    await binding.takeScreenshot(name);
  }

  Future<void> go(WidgetTester t, String path, [int ms = 1500]) async {
    appRouter.go(path);
    await wait(t, ms);
    await wait(t, 300);
  }

  testWidgets('capture Livewave screens', (t) async {
    app.main();
    await wait(t, 4000); // fonts + images
    await binding.convertFlutterSurfaceToImage();
    await wait(t, 1000);
    await shot(t, '01-welcome');

    await t.tap(find.byKey(const Key('get-started')));
    await wait(t, 2500);
    await shot(t, '02-home');

    await t.tap(find.byKey(const Key('toggle-empty')));
    await wait(t);
    await shot(t, '03-home-empty');
    await t.tap(find.byKey(const Key('toggle-empty')));
    await wait(t, 500);

    await go(t, '/explore', 2500);
    await shot(t, '04-explore');

    await go(t, '/explore/creator/lena', 2000);
    await shot(t, '05-creator-profile');

    await go(t, '/watch/acoustic', 4000);
    await shot(t, '06-watch-live');

    await t.tap(find.byKey(const Key('gift-button')));
    await wait(t, 1200);
    await shot(t, '07-gift-sheet');
    await t.tap(find.byKey(const Key('gift-mic')));
    await wait(t, 400);
    await t.tap(find.textContaining('Send Mic'));
    await wait(t, 1500);

    await go(t, '/golive', 2000);
    await shot(t, '08-go-live-setup');

    await t.scrollUntilVisible(
      find.byKey(const Key('go-live')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await wait(t, 500);
    await t.tap(find.byKey(const Key('go-live')));
    await wait(t, 3500);
    await shot(t, '09-host-live');

    await t.tap(find.byKey(const Key('simulate-drop')));
    await wait(t, 4500);
    await t.tap(find.byKey(const Key('open-health')));
    await wait(t, 2000);
    await shot(t, '10-stream-health');
    await t.tap(find.byTooltip('Back'));
    await wait(t, 1200);

    await t.tap(find.byKey(const Key('end-stream')));
    await wait(t, 2000);
    await shot(t, '11-live-summary');

    await go(t, '/wallet', 2000);
    await shot(t, '12-wallet');

    await go(t, '/profile', 2000);
    await shot(t, '13-profile');

    await t.tap(find.byKey(const Key('open-settings')));
    await wait(t, 1500);
    await shot(t, '14-stream-settings');
  });
}
