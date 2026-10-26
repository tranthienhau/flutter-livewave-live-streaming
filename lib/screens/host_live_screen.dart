import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../streaming/stream_engine.dart';
import '../widgets/common.dart';

/// Broadcaster room: timer, viewers, health chip, gift alerts, moderation.
class HostLiveScreen extends ConsumerStatefulWidget {
  const HostLiveScreen({super.key});

  @override
  ConsumerState<HostLiveScreen> createState() => _HostLiveScreenState();
}

class _HostLiveScreenState extends ConsumerState<HostLiveScreen> {
  LiveComment? _moderating;

  Future<void> _end() async {
    final s = await ref.read(hostSessionProvider.notifier).end();
    ref.read(lastSessionProvider.notifier).set(s);
    if (mounted) context.pushReplacement('/summary');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(hostSessionProvider);
    if (s == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go('/golive'),
            child: const Text('No active stream - set one up'),
          ),
        ),
      );
    }
    final st = s.stats;
    final reconnecting = st?.state == LinkState.reconnecting;
    final top = MediaQuery.paddingOf(context).top;
    final n = ref.read(hostSessionProvider.notifier);

    return Scaffold(
      backgroundColor: LW.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(Img.liveHost, fit: BoxFit.cover),
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
                stops: [0, .2, .45, 1],
              ),
            ),
          ),
          Positioned(
            top: top + 8,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LivePill(trailing: hms(s.elapsed)),
                    const SizedBox(width: 8),
                    ViewerPill(s.viewers),
                    const Spacer(),
                    GestureDetector(
                      key: const Key('end-stream'),
                      onTap: _end,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: LW.live,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'End',
                          style: LW.label(
                            color: Colors.white,
                            w: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.push('/health'),
                  child: OverlayPill(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: reconnecting
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          st == null
                              ? 'Connecting...'
                              : '${st.healthLabel} - ${st.bitrateMbps.toStringAsFixed(1)} Mbps - ${s.config.engine.label}',
                          style: LW.small(
                            color: Colors.white,
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (s.debugOverlay && st != null) ...[
                  const SizedBox(height: 8),
                  OverlayPill(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      'fps ${st.fps}  rtt ${st.latencyMs}ms  loss ${st.packetLossPct}%  ${s.config.quality.label}',
                      style: LW
                          .small(color: Colors.white)
                          .copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (s.giftAlert != null)
            Positioned(
              left: 12,
              top: top + 150,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(s.giftAlert),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: LW.support,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_outlined,
                        color: LW.ink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(s.giftAlert!, style: LW.label(w: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          if (reconnecting)
            Center(
              child: OverlayPill(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Reconnecting with backoff...',
                      style: LW.label(color: Colors.white, w: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 60,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in s.comments) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CommentBubble(
                      c,
                      onLongPress: () => setState(() => _moderating = c),
                    ),
                  ),
                  if (_moderating == c)
                    _ModerationBar(
                      onPin: () {
                        n.pin(c);
                        setState(() => _moderating = null);
                      },
                      onMute: () => setState(() => _moderating = null),
                      onRemove: () {
                        n.remove(c);
                        setState(() => _moderating = null);
                      },
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundOverlayButton(
                  s.micOn ? Icons.mic_none : Icons.mic_off_outlined,
                  semantics: 'Microphone',
                  onTap: n.toggleMic,
                ),
                const RoundOverlayButton(
                  Icons.cameraswitch_outlined,
                  semantics: 'Flip camera',
                ),
                RoundOverlayButton(
                  Icons.wifi_off_rounded,
                  key: const Key('simulate-drop'),
                  semantics: 'Simulate network drop',
                  onTap: n.simulateDrop,
                ),
                RoundOverlayButton(
                  Icons.monitor_heart_outlined,
                  key: const Key('open-health'),
                  semantics: 'Stream health',
                  onTap: () => context.push('/health'),
                ),
                RoundOverlayButton(
                  Icons.bug_report_outlined,
                  fill: s.debugOverlay ? LW.accentFill : null,
                  semantics: 'Debug overlay',
                  onTap: n.toggleDebug,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModerationBar extends StatelessWidget {
  const _ModerationBar({
    required this.onPin,
    required this.onMute,
    required this.onRemove,
  });
  final VoidCallback onPin;
  final VoidCallback onMute;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 6),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: LW.surface,
      borderRadius: BorderRadius.circular(999),
      boxShadow: LW.cardShadow,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _a(Icons.push_pin_outlined, 'Pin', LW.ink, onPin),
        _a(Icons.mic_off_outlined, 'Mute', LW.ink, onMute),
        _a(Icons.delete_outline, 'Remove', LW.danger, onRemove),
      ],
    ),
  );

  Widget _a(IconData i, String l, Color c, VoidCallback f) => TextButton.icon(
    onPressed: f,
    icon: Icon(i, size: 16, color: c),
    label: Text(
      l,
      style: LW.caption(color: c, w: FontWeight.w600),
    ),
  );
}
