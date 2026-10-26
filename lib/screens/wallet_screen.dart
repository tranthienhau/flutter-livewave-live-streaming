import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = ref.watch(walletProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Wallet', style: LW.display()),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LW.heroGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: LW.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coin balance', style: LW.caption(color: Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.toll_outlined,
                      color: LW.support,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      grouped(w.coins),
                      style: LW.numeral(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: .25),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Earnings this month  ',
                              style: LW.caption(color: Colors.white),
                            ),
                            TextSpan(
                              text: r'$214.60',
                              style: LW.label(
                                color: Colors.white,
                                w: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    OverlayPill(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        'Withdraw',
                        style: LW.caption(
                          color: Colors.white,
                          w: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Top up'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .8,
            children: [
              for (final p in Mock.coinPacks)
                GestureDetector(
                  onTap: () {
                    ref.read(walletProvider.notifier).topUp(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added ${grouped(p.coins)} coins (sandbox purchase)',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: LW.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: p.popular ? LW.accent : LW.border,
                        width: p.popular ? 1.5 : 1,
                      ),
                      boxShadow: LW.cardShadow,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.toll_outlined,
                                color: LW.accent,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                grouped(p.coins),
                                style: LW.label(w: FontWeight.w700),
                              ),
                              Text('coins', style: LW.small()),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: LW.accentTint,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  p.price,
                                  style: LW.caption(
                                    color: LW.accentFill,
                                    w: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (p.popular)
                          Positioned(
                            top: 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: LW.support,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Popular',
                                  style: LW.small(
                                    color: LW.ink,
                                    w: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader('Recent activity'),
          LWCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (final t in w.txns.take(5))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.amount > 0
                                ? LW.successTint
                                : LW.accentTint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            switch (t.kind) {
                              'gift_out' => Icons.rocket_launch_outlined,
                              'gift_in' => Icons.workspace_premium_outlined,
                              _ => Icons.add_card_outlined,
                            },
                            size: 20,
                            color: t.amount > 0 ? LW.success : LW.accentFill,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.title,
                                style: LW.label(w: FontWeight.w600),
                              ),
                              Text(t.when, style: LW.small()),
                            ],
                          ),
                        ),
                        Text(
                          '${t.amount > 0 ? '+' : ''}${grouped(t.amount)}',
                          style: LW.label(
                            color: t.amount > 0 ? LW.success : LW.inkSecondary,
                            w: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
