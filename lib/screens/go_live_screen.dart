import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../data/mock_data.dart';
import '../data/models.dart';
import '../state/providers.dart';
import '../streaming/stream_engine.dart';
import '../widgets/common.dart';

class GoLiveScreen extends ConsumerWidget {
  const GoLiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(goLiveConfigProvider);
    final set = ref.read(goLiveConfigProvider.notifier).update;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text('Go live', style: LW.display()),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(Img.hostPreview, fit: BoxFit.cover),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: OverlayPill(
                      child: Text(
                        'PREVIEW',
                        style: LW.small(
                          color: Colors.white,
                          w: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 12,
                    top: 12,
                    child: Column(
                      children: [
                        RoundOverlayButton(
                          Icons.cameraswitch_outlined,
                          size: 42,
                          semantics: 'Flip camera',
                        ),
                        SizedBox(height: 10),
                        RoundOverlayButton(
                          Icons.mic_none,
                          size: 42,
                          semantics: 'Microphone',
                        ),
                        SizedBox(height: 10),
                        RoundOverlayButton(
                          Icons.auto_awesome_outlined,
                          size: 42,
                          semantics: 'Beauty filter',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Stream title', style: LW.label(color: LW.inkSecondary)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: cfg.title,
            onChanged: (v) => set((c) => c.copyWith(title: v)),
            style: LW.body(),
            decoration: InputDecoration(
              filled: true,
              fillColor: LW.surface,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in [
                StreamCategory.talk,
                StreamCategory.music,
                StreamCategory.cooking,
                StreamCategory.gaming,
              ])
                LWChip(
                  c.label,
                  active: cfg.category == c,
                  onTap: () => set((x) => x.copyWith(category: c)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          LWCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Streaming engine', style: LW.label(w: FontWeight.w600)),
                const SizedBox(height: 10),
                _Segmented<EngineKind>(
                  values: EngineKind.values,
                  selected: cfg.engine,
                  label: (e) => e.label,
                  onSelect: (e) => set((c) => c.copyWith(engine: e)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 16, color: LW.supportStrong),
                    const SizedBox(width: 4),
                    Text(cfg.engine.latencyNote, style: LW.caption()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LWCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quality', style: LW.label(w: FontWeight.w600)),
                const SizedBox(height: 10),
                _Segmented<VideoQuality>(
                  values: VideoQuality.values,
                  selected: cfg.quality,
                  label: (q) => q.label,
                  onSelect: (q) => set((c) => c.copyWith(quality: q)),
                ),
                const SizedBox(height: 4),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: cfg.adaptiveBitrate,
                  activeTrackColor: LW.accentFill,
                  onChanged: (v) => set((c) => c.copyWith(adaptiveBitrate: v)),
                  title: Text('Adaptive bitrate', style: LW.label()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LWCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pre-flight check',
                        style: LW.label(w: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: LW.successTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '3/3 ready',
                        style: LW.small(color: LW.success, w: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final t in [
                  'Network - Good, 18 Mbps up',
                  'Camera ready',
                  'Microphone ready',
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: LW.successTint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: LW.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(t, style: LW.label()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            'Go Live',
            key: const Key('go-live'),
            icon: Icons.sensors,
            onTap: cfg.title.trim().isEmpty
                ? null
                : () async {
                    await ref.read(hostSessionProvider.notifier).start(cfg);
                    if (context.mounted) context.push('/host');
                  },
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: LW.surfaceAlt,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        for (final v in values)
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == selected ? LW.accentFill : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  label(v),
                  style: LW.label(
                    color: v == selected ? Colors.white : LW.inkSecondary,
                    w: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
