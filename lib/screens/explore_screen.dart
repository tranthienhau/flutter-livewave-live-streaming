import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  StreamCategory? _cat;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final follows = ref.watch(followProvider);
    final all = [...Mock.trending, ...Mock.liveNow];
    final trending = all.where((s) {
      final catOk = _cat == null || s.category == _cat;
      final q = _query.toLowerCase();
      final qOk =
          q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.creator.name.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Explore', style: LW.display()),
          const SizedBox(height: 16),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: LW.body(),
            decoration: InputDecoration(
              hintText: 'Search creators, streams, tags',
              hintStyle: LW.body(color: LW.inkTertiary),
              prefixIcon: const Icon(Icons.search, color: LW.inkSecondary),
              filled: true,
              fillColor: LW.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LW.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: LW.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                LWChip(
                  'All',
                  active: _cat == null,
                  onTap: () => setState(() => _cat = null),
                ),
                for (final c in StreamCategory.values) ...[
                  const SizedBox(width: 8),
                  LWChip(
                    c.label,
                    active: _cat == c,
                    onTap: () => setState(() => _cat = c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Trending'),
          SizedBox(
            height: 250,
            child: trending.isEmpty
                ? Center(
                    child: Text(
                      'No live streams match',
                      style: LW.body(color: LW.inkSecondary),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: trending.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 180,
                      child: StreamCard(
                        trending[i],
                        aspect: 3 / 4,
                        titleBelow: false,
                        onTap: () => context.push('/watch/${trending[i].id}'),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          const SectionHeader('Top categories'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              for (final (cat, img, live) in Mock.topCategories)
                GestureDetector(
                  onTap: () => setState(() => _cat = cat),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(img, fit: BoxFit.cover),
                        const ColoredBox(color: Color(0x8C160C1F)),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                cat.label,
                                style: LW.label(
                                  color: Colors.white,
                                  w: FontWeight.w700,
                                ),
                              ),
                              Text(live, style: LW.small(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader('Rising creators'),
          for (final c in [Mock.lena, Mock.aiko, Mock.marco])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LWCard(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () => context.go('/explore/creator/${c.id}'),
                  child: Row(
                    children: [
                      Avatar(image: c.avatar, name: c.name, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: LW.label(w: FontWeight.w600)),
                            Text(
                              '${c.category.label} - ${compact(c.followers)} followers',
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
              ),
            ),
        ],
      ),
    );
  }
}
