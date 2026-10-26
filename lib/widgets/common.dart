import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../data/models.dart';

final _compact = NumberFormat.compact();
final _grouped = NumberFormat.decimalPattern();

String compact(int n) => n < 10000 ? _grouped.format(n) : _compact.format(n);
String grouped(int n) => _grouped.format(n);

String hms(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}

class LivePill extends StatelessWidget {
  const LivePill({super.key, this.trailing});
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: LW.live,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: LW.caption(color: Colors.white, w: FontWeight.w700),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Text(
              trailing!,
              style: LW.caption(color: Colors.white, w: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class OverlayPill extends StatelessWidget {
  const OverlayPill({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: LW.overlay,
      borderRadius: BorderRadius.circular(999),
    ),
    child: child,
  );
}

class ViewerPill extends StatelessWidget {
  const ViewerPill(this.count, {super.key});
  final int count;

  @override
  Widget build(BuildContext context) => OverlayPill(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 15, color: Colors.white),
        const SizedBox(width: 5),
        Text(
          compact(count),
          style: LW.caption(color: Colors.white, w: FontWeight.w600),
        ),
      ],
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image,
    required this.name,
    this.size = 40,
    this.ring,
  });
  final String? image;
  final String name;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final inner = ClipOval(
      child: image != null
          ? Image.asset(image!, width: size, height: size, fit: BoxFit.cover)
          : Container(
              width: size,
              height: size,
              color: LW.accentTint,
              alignment: Alignment.center,
              child: Text(
                name[0],
                style: LW.label(color: LW.accentFill, w: FontWeight.w700),
              ),
            ),
    );
    if (ring == null) return inner;
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring!, width: 2.5),
      ),
      child: inner,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.height = 54,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: LW.accentFill,
        disabledBackgroundColor: LW.accentFill.withValues(alpha: .4),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: LW
                .body(color: Colors.white)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.height = 54,
    this.compact = false,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: compact ? 36 : height,
    width: compact ? null : double.infinity,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: LW.accent, width: 1.5),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: LW.accentFill, size: 18),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: (compact
                ? LW.caption(color: LW.accentFill, w: FontWeight.w600)
                : LW
                      .body(color: LW.accentFill)
                      .copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );
}

class LWCard extends StatelessWidget {
  const LWCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = LW.surface,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: LW.border),
      boxShadow: LW.cardShadow,
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class LWChip extends StatelessWidget {
  const LWChip(this.label, {super.key, this.active = false, this.onTap});
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: active ? LW.accentFill : LW.accentTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: LW.caption(
          color: active ? Colors.white : LW.accentFill,
          w: FontWeight.w600,
        ),
      ),
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(title, style: LW.title())),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: LW.label(color: LW.accentFill, w: FontWeight.w600),
            ),
          ),
      ],
    ),
  );
}

/// Photo stream card used on Home and Explore.
class StreamCard extends StatelessWidget {
  const StreamCard(
    this.stream, {
    super.key,
    this.onTap,
    this.aspect = 1.1,
    this.titleBelow = true,
  });
  final LiveStream stream;
  final VoidCallback? onTap;
  final double aspect;
  final bool titleBelow;

  @override
  Widget build(BuildContext context) {
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: aspect,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(stream.thumbnail, fit: BoxFit.cover),
            if (!titleBelow)
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD9160C1F)],
                    stops: [.45, 1],
                  ),
                ),
              ),
            const Positioned(left: 10, top: 10, child: LivePill()),
            Positioned(right: 10, top: 10, child: ViewerPill(stream.viewers)),
            if (!titleBelow)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: LW.label(color: Colors.white, w: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stream.creator.name,
                      style: LW.small(color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: titleBelow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photo,
                const SizedBox(height: 8),
                Text(
                  stream.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LW.label(w: FontWeight.w600),
                ),
                Text(stream.creator.name, style: LW.caption()),
              ],
            )
          : photo,
    );
  }
}

class CommentBubble extends StatelessWidget {
  const CommentBubble(this.c, {super.key, this.onLongPress});
  final LiveComment c;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (c.kind == CommentKind.gift) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: LW.support,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 16, color: LW.ink),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${c.author} ${c.text}',
                style: LW.label(w: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: c.pinned ? const Color(0xCC3A1D55) : LW.overlay,
          borderRadius: BorderRadius.circular(14),
          border: c.pinned
              ? Border.all(color: LW.accent.withValues(alpha: .8))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (c.pinned) ...[
              const Icon(
                Icons.push_pin_outlined,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
            ] else ...[
              Avatar(image: c.avatar, name: c.author, size: 28),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${c.author}  ',
                      style: LW.label(color: Colors.white, w: FontWeight.w700),
                    ),
                    TextSpan(
                      text: c.text,
                      style: LW.label(color: Colors.white, w: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoundOverlayButton extends StatelessWidget {
  const RoundOverlayButton(
    this.icon, {
    super.key,
    this.onTap,
    this.label,
    this.size = 46,
    this.fill,
    this.iconColor = Colors.white,
    this.semantics,
  });
  final IconData icon;
  final VoidCallback? onTap;
  final String? label;
  final double size;
  final Color? fill;
  final Color iconColor;
  final String? semantics;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semantics ?? label,
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fill ?? LW.overlay,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: size * .48),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: LW.small(color: Colors.white, w: FontWeight.w600),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Flat 2D gift glyph built from Material icons (no 3D assets).
class GiftGlyph extends StatelessWidget {
  const GiftGlyph(this.id, {super.key, this.size = 36});
  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (id) {
      'rose' => (Icons.local_florist_outlined, LW.live),
      'heart' => (Icons.favorite_border, LW.accent),
      'coffee' => (Icons.coffee_outlined, LW.inkSecondary),
      'star' => (Icons.star_border_rounded, LW.supportStrong),
      'mic' => (Icons.mic_none_rounded, LW.accent),
      'rocket' => (Icons.rocket_launch_outlined, LW.accentFill),
      'crown' => (Icons.workspace_premium_outlined, LW.supportStrong),
      _ => (Icons.waves_rounded, LW.accent),
    };
    return Icon(icon, size: size, color: color);
  }
}

/// Hearts that float up the right edge; one spawns each time [trigger] changes.
class FloatingHearts extends StatefulWidget {
  const FloatingHearts({super.key, required this.trigger});
  final int trigger;

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with TickerProviderStateMixin {
  final _hearts = <(AnimationController, double, Color)>[];
  final _rand = Random(3);

  @override
  void didUpdateWidget(FloatingHearts old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _spawn();
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      _spawn(start: i * .3);
    }
  }

  void _spawn({double start = 0}) {
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    final entry = (
      c,
      _rand.nextDouble() * 30,
      _rand.nextBool() ? LW.accent : const Color(0xFFF472B6),
    );
    setState(() => _hearts.add(entry));
    c.forward(from: start).whenComplete(() {
      if (!mounted) return;
      setState(() => _hearts.remove(entry));
      c.dispose();
    });
  }

  @override
  void dispose() {
    for (final h in _hearts) {
      h.$1.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 60,
    height: 240,
    child: Stack(
      children: [
        for (final (c, dx, color) in _hearts)
          AnimatedBuilder(
            animation: c,
            builder: (_, _) => Positioned(
              bottom: c.value * 220,
              right: 10 + dx + sin(c.value * 6) * 8,
              child: Opacity(
                opacity: (1 - c.value).clamp(0, 1),
                child: Icon(
                  Icons.favorite,
                  color: color,
                  size: 22 + (1 - c.value) * 6,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
