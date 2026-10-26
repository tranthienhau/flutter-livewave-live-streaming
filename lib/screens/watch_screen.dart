import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../widgets/common.dart';

/// Viewer side of a live room: full-bleed video, chat overlay, hearts, gifts.
class WatchScreen extends ConsumerStatefulWidget {
  const WatchScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends ConsumerState<WatchScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(viewerRoomProvider);
    final following = ref.watch(followProvider).contains('lena');
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: LW.ink,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.liveLena, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x80160C1F),
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xB3160C1F),
                ],
                stops: [0, .18, .5, 1],
              ),
            ),
          ),
          // top bar
          Positioned(
            top: top + 8,
            left: 12,
            right: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: OverlayPill(
                    padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Avatar(image: Img.lena, name: 'Lena', size: 32),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Lena Park',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: LW.label(
                              color: Colors.white,
                              w: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              ref.read(followProvider.notifier).toggle('lena'),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: following ? 6 : 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: following
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: LW.accentFill,
                                    semanticLabel: 'Following',
                                  )
                                : Text(
                                    'Follow',
                                    style: LW.small(
                                      color: LW.accentFill,
                                      w: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: LivePill(),
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ViewerPill(room.viewers),
                    const SizedBox(height: 6),
                    OverlayPill(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'HD',
                            style: LW.small(
                              color: Colors.white,
                              w: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                RoundOverlayButton(
                  Icons.close,
                  size: 40,
                  semantics: 'Close',
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                ),
              ],
            ),
          ),
          // right rail
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                FloatingHearts(trigger: room.hearts),
                RoundOverlayButton(
                  Icons.favorite_border,
                  label: compact(room.likes),
                  onTap: ref.read(viewerRoomProvider.notifier).like,
                ),
                const SizedBox(height: 16),
                RoundOverlayButton(
                  Icons.card_giftcard,
                  label: 'Gift',
                  onTap: () => showGiftSheet(context, ref),
                ),
                const SizedBox(height: 16),
                RoundOverlayButton(
                  Icons.ios_share,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
          // chat
          Positioned(
            left: 12,
            right: 84,
            bottom: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in room.comments)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CommentBubble(c),
                  ),
              ],
            ),
          ),
          // composer
          Positioned(
            left: 12,
            right: 12,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    style: LW.label(color: Colors.white),
                    onSubmitted: (v) {
                      ref.read(viewerRoomProvider.notifier).send(v);
                      _input.clear();
                    },
                    decoration: InputDecoration(
                      hintText: 'Say something...',
                      hintStyle: LW.label(
                        color: Colors.white.withValues(alpha: .8),
                      ),
                      filled: true,
                      fillColor: LW.overlay,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                RoundOverlayButton(
                  Icons.card_giftcard,
                  key: const Key('gift-button'),
                  fill: LW.support,
                  iconColor: LW.ink,
                  semantics: 'Send a gift',
                  onTap: () => showGiftSheet(context, ref),
                ),
                const SizedBox(width: 10),
                RoundOverlayButton(
                  Icons.favorite,
                  fill: LW.accentFill,
                  semantics: 'Like',
                  onTap: ref.read(viewerRoomProvider.notifier).like,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showGiftSheet(BuildContext context, WidgetRef ref) =>
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x8C160C1F),
      isScrollControlled: true,
      builder: (_) => const GiftSheet(),
    );

class GiftSheet extends ConsumerStatefulWidget {
  const GiftSheet({super.key});

  @override
  ConsumerState<GiftSheet> createState() => _GiftSheetState();
}

class _GiftSheetState extends ConsumerState<GiftSheet> {
  Gift _selected = Mock.gifts[5];
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final total = _selected.price * _qty;
    final canAfford = total <= wallet.coins;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: LW.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LW.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Send a gift', style: LW.title())),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: LW.accentTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.toll_outlined,
                      size: 16,
                      color: LW.accentFill,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${grouped(wallet.coins)} coins',
                      style: LW.caption(
                        color: LW.accentFill,
                        w: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/wallet');
                },
                child: Text(
                  'Top up',
                  style: LW.label(color: LW.accentFill, w: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .82,
            children: [
              for (final g in Mock.gifts)
                GestureDetector(
                  key: Key('gift-${g.id}'),
                  onTap: () => setState(() => _selected = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: g == _selected ? LW.accentTint : LW.surfaceAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: g == _selected ? LW.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GiftGlyph(g.glyph),
                        const SizedBox(height: 6),
                        Text(
                          g.name,
                          style: LW.caption(color: LW.ink, w: FontWeight.w600),
                        ),
                        Text(grouped(g.price), style: LW.small()),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: LW.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                for (final q in [1, 5, 10])
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _qty = q),
                      child: Container(
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: q == _qty ? LW.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: q == _qty ? LW.cardShadow : null,
                        ),
                        child: Text(
                          'x$q',
                          style: LW.label(
                            color: q == _qty ? LW.accentFill : LW.inkSecondary,
                            w: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            canAfford
                ? 'Send ${_selected.name} - ${grouped(total)} coins'
                : 'Not enough coins - top up',
            onTap: () {
              if (!canAfford) {
                Navigator.pop(context);
                context.go('/wallet');
                return;
              }
              ref
                  .read(walletProvider.notifier)
                  .spend(total, 'Sent ${_selected.name} to Lena Park');
              ref.read(viewerRoomProvider.notifier).giftSent(_selected, _qty);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
