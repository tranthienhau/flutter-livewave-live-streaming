import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';

void main() => runApp(const ProviderScope(child: LivewaveApp()));

class LivewaveApp extends StatelessWidget {
  const LivewaveApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Livewave',
    debugShowCheckedModeBanner: false,
    theme: LW.theme(),
    routerConfig: appRouter,
  );
}
