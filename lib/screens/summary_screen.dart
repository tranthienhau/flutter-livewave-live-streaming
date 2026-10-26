import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(lastSessionProvider);
    final mins = (s?.elapsed.inMinutes ?? 52);
    final peak = s?.peakViewers ?? 2940;
    final avgLatency = s?.stats?.latencyMs ?? 318;
    final stats = [
      (Icons.visibility_outlined, 'Total views', grouped(peak * 3 - 408)),
      (Icons.person_add_alt, 'New followers', '+186'),
      (Icons.chat_bubble_outline, 'Comments', '1,203'),
      (
        Icons.toll_outlined,
        'Gifts earned',
        '${grouped(s?.giftCoins ?? 6450)} coins',
      ),
      (Icons.schedule, 'Avg watch time', '7m 40s'),
      (Icons.bolt, 'Avg latency', '$avgLatency ms'),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LW.heroGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Stream ended', style: LW.title(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${s?.config.title ?? 'Morning coffee and Q&A'} - $mins min',
                    style: LW.label(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LWCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(grouped(peak), style: LW.numeral()),
                      Text(
                        'Peak viewers',
                        style: LW.caption(color: LW.inkSecondary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: LW.successTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+18% vs last',
                      style: LW.caption(color: LW.success, w: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
              children: [
                for (final (icon, label, value) in stats)
                  LWCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(icon, color: LW.accentFill, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FittedBox(
                                child: Text(
                                  value,
                                  style: LW.label(w: FontWeight.w700),
                                ),
                              ),
                              Text(label, style: LW.small()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LWCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top supporters', style: LW.label(w: FontWeight.w600)),
                  const SizedBox(height: 8),
                  for (final (i, sp) in Mock.supporters.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '#${i + 1}',
                              style: LW.caption(
                                color: LW.accentFill,
                                w: FontWeight.w700,
                              ),
                            ),
                          ),
                          Avatar(image: sp.avatar, name: sp.name, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              sp.name,
                              style: LW.label(w: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${grouped(sp.coins)} coins',
                            style: LW.caption(
                              color: LW.inkSecondary,
                              w: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              'Save replay',
              icon: Icons.download_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Replay saved to your profile')),
                );
              },
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              'Share highlights',
              icon: Icons.ios_share,
              onTap: () {},
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Back to home',
                  style: LW.label(color: LW.accentFill, w: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
