import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

class CreatorScreen extends ConsumerWidget {
  const CreatorScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = [
      Mock.lena,
      Mock.aiko,
      Mock.marco,
      Mock.sam,
    ].firstWhere((x) => x.id == id, orElse: () => Mock.lena);
    final following = ref.watch(followProvider).contains(c.id);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 60,
                  child: Image.asset(
                    c.cover ?? Img.lenaCover,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 16,
                  child: RoundOverlayButton(
                    Icons.arrow_back,
                    size: 44,
                    semantics: 'Back',
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/explore'),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 0,
                  child: Column(
                    children: [
                      Avatar(
                        image: c.avatar,
                        name: c.name,
                        size: 104,
                        ring: LW.live,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -12),
                        child: const LivePill(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: LW.title()),
                Text(c.handle, style: LW.caption()),
                const SizedBox(height: 8),
                Text(
                  c.bio.isEmpty ? 'Live every week on Livewave' : c.bio,
                  style: LW.body(color: LW.inkSecondary),
                ),
                const SizedBox(height: 16),
                LWCard(
                  child: Row(
                    children: [
                      _stat(compact(c.followers), 'Followers'),
                      _divider(),
                      _stat('${c.streams}', 'Streams'),
                      _divider(),
                      _stat(c.rating == 0 ? '4.8' : '${c.rating}', 'Rating'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        'Watch live',
                        icon: Icons.play_arrow_rounded,
                        onTap: () => context.push('/watch/acoustic'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        following ? 'Following' : 'Follow',
                        icon: following ? Icons.check : Icons.add,
                        onTap: () =>
                            ref.read(followProvider.notifier).toggle(c.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader('Schedule'),
                LWCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (final s in Mock.lenaSchedule)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: LW.accentTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              color: LW.accentFill,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            s.when,
                            style: LW.label(w: FontWeight.w600),
                          ),
                          subtitle: Text(s.title, style: LW.caption()),
                          trailing: Text(
                            'Remind',
                            style: LW.caption(
                              color: LW.accentFill,
                              w: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader('Past streams'),
                Row(
                  children: [
                    for (final r in Mock.lenaReplays) ...[
                      Expanded(
                        child: ReplayTile(
                          r.thumbnail,
                          r.duration,
                          r.title,
                          r.views,
                        ),
                      ),
                      if (r != Mock.lenaReplays.last) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(v, style: LW.numeral(size: 20)),
        Text(l, style: LW.caption()),
      ],
    ),
  );

  Widget _divider() => Container(width: 1, height: 32, color: LW.border);
}

class ReplayTile extends StatelessWidget {
  const ReplayTile(
    this.img,
    this.duration,
    this.title,
    this.views, {
    super.key,
  });
  final String img;
  final String duration;
  final String title;
  final String views;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(img, fit: BoxFit.cover),
              Positioned(
                right: 8,
                bottom: 8,
                child: OverlayPill(
                  child: Text(
                    duration,
                    style: LW.small(color: Colors.white, w: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: LW.label(w: FontWeight.w600),
      ),
      Text(views, style: LW.small()),
    ],
  );
}
