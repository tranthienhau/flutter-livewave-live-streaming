import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LW.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.welcome, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33160C1F),
                  Colors.transparent,
                  Color(0xE6160C1F),
                  Color(0xFA160C1F),
                ],
                stops: [0, .3, .62, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(Img.appIcon, width: 44, height: 44),
                  ),
                  const Spacer(),
                  Text(
                    'Go live in seconds',
                    style: LW.display(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Stream, chat and earn with your community in real time.',
                    textAlign: TextAlign.center,
                    style: LW.body(color: Colors.white.withValues(alpha: .9)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      for (var i = 0; i < 2; i++)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .4),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    'Get started',
                    key: const Key('get-started'),
                    onTap: () => context.go('/home'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'I already have an account',
                      style: LW.label(color: Colors.white, w: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
