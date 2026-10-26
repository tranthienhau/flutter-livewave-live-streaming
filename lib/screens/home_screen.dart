import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empty = ref.watch(homeEmptyProvider);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const Avatar(image: Img.maya, name: 'Maya', size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text('Hi, Maya', style: LW.title())),
              IconButton(
                tooltip: 'Search',
                onPressed: () => context.go('/explore'),
                icon: const Icon(Icons.search, color: LW.ink),
              ),
              IconButton(
                key: const Key('toggle-empty'),
                tooltip: 'Notifications',
                onPressed: () =>
                    ref.read(homeEmptyProvider.notifier).set(!empty),
                icon: const Icon(Icons.notifications_none, color: LW.ink),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (empty) const _EmptyState() else ..._feed(context),
        ],
      ),
    );
  }

  List<Widget> _feed(BuildContext context) => [
    StreamCard(
      Mock.featured,
      aspect: 1.6,
      titleBelow: false,
      onTap: () => context.push('/watch/${Mock.featured.id}'),
    ),
    const SizedBox(height: 24),
    const SectionHeader('Following - live now'),
    SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Mock.following.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final c = Mock.following[i];
          return GestureDetector(
            onTap: () => context.push('/watch/acoustic'),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Avatar(
                        image: c.avatar,
                        name: c.name,
                        size: 58,
                        ring: LW.accent,
                      ),
                      Positioned(
                        bottom: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: LW.live,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'LIVE',
                            style: LW.small(
                              color: Colors.white,
                              w: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c.name.split(' ').first,
                    maxLines: 1,
                    style: LW.caption(color: LW.ink),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    const SizedBox(height: 16),
    SectionHeader(
      'Live now',
      action: 'See all',
      onAction: () => context.go('/explore'),
    ),
    GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Mock.liveNow.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: .78,
      ),
      itemBuilder: (_, i) => StreamCard(
        Mock.liveNow[i],
        onTap: () => context.push('/watch/${Mock.liveNow[i].id}'),
      ),
    ),
  ];
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final follows = ref.watch(followProvider);
    final suggested = [Mock.lena, Mock.aiko, Mock.sam];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LWCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(Img.emptyDesk, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Nobody you follow is live',
                textAlign: TextAlign.center,
                style: LW.title(),
              ),
              const SizedBox(height: 8),
              Text(
                'Follow creators to get notified when they go live.',
                textAlign: TextAlign.center,
                style: LW.body(color: LW.inkSecondary),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                'Explore live streams',
                onTap: () => context.go('/explore'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Suggested creators'),
        LWCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final c in suggested)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Avatar(image: c.avatar, name: c.name, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: LW.label(w: FontWeight.w600)),
                            Text(
                              '${c.category.name[0].toUpperCase()}${c.category.name.substring(1)} - ${compact(c.followers)} followers',
                              style: LW.caption(),
                            ),
                          ],
                        ),
                      ),
                      SecondaryButton(
                        follows.contains(c.id) ? 'Following' : 'Follow',
                        compact: true,
                        onTap: () =>
                            ref.read(followProvider.notifier).toggle(c.id),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
