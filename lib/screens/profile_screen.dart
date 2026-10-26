import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../widgets/common.dart';
import 'creator_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 0;
  static const _week = [0.9, 1.1, 0.4, 1.3, 1.8, 0.6, 0.4];

  @override
  Widget build(BuildContext context) {
    final me = Mock.me;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              key: const Key('open-settings'),
              tooltip: 'Stream settings',
              icon: const Icon(Icons.settings_outlined, color: LW.ink),
              onPressed: () => context.go('/profile/settings'),
            ),
          ),
          Center(
            child: Avatar(
              image: me.avatar,
              name: me.name,
              size: 96,
              ring: LW.accent,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(me.name, style: LW.title())),
          Center(
            child: Text(me.handle, style: LW.label(color: LW.inkTertiary)),
          ),
          const SizedBox(height: 12),
          Center(
            child: SecondaryButton('Edit profile', compact: true, onTap: () {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(grouped(me.followers), 'Followers'),
              _stat('184', 'Following'),
              _stat('${me.streams}', 'Streams'),
            ],
          ),
          const SizedBox(height: 16),
          LWCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THIS WEEK', style: LW.small(w: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '6.5 h ',
                              style: LW.numeral(size: 26, color: LW.ink),
                            ),
                            TextSpan(
                              text: 'streamed',
                              style: LW.label(color: LW.inkTertiary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 16,
                            color: LW.supportStrong,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Peak 2,940 viewers',
                            style: LW.caption(color: LW.inkSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final (i, v) in _week.indexed)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 12,
                                height: 50 * v / 1.8,
                                decoration: BoxDecoration(
                                  color: v == 1.8
                                      ? LW.supportStrong
                                      : LW.support,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('MTWTFSS'[i], style: LW.small()),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final (i, t) in ['Replays', 'Clips', 'Scheduled'].indexed)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: i == _tab ? LW.accent : LW.border,
                            width: i == _tab ? 2.5 : 1,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t,
                        style: LW.label(
                          color: i == _tab ? LW.accent : LW.inkTertiary,
                          w: i == _tab ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_tab == 0)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: .78,
              children: [
                for (final r in Mock.myReplays)
                  ReplayTile(
                    r.thumbnail,
                    r.duration,
                    r.title,
                    '${r.views} - ${r.ago}',
                  ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  _tab == 1
                      ? 'No clips yet - clip a moment from any replay'
                      : 'Next: Fri 9:00 AM - Coffee Q&A',
                  style: LW.body(color: LW.inkSecondary),
                  textAlign: TextAlign.center,
                ),
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
}
