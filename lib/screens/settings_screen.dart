import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../state/providers.dart';
import '../streaming/stream_engine.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final up = ref.read(settingsProvider.notifier).update;
    const policy = ReconnectPolicy();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LW.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Stream settings', style: LW.title()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Group(
            'Video',
            header: 'PRIMARY CONFIG',
            children: [
              _Row(Icons.tune, 'Default quality', value: s.quality.label),
              _Row(Icons.speed, 'Frame rate', value: '${s.fps} fps'),
              _Toggle(
                Icons.auto_graph,
                'Adaptive bitrate',
                s.adaptiveBitrate,
                (v) => up((x) => x.copyWith(adaptiveBitrate: v)),
              ),
              _Toggle(
                Icons.bolt,
                'Low-latency mode',
                s.lowLatency,
                (v) => up((x) => x.copyWith(lowLatency: v)),
                last: true,
              ),
            ],
          ),
          _Group(
            'Reliability',
            children: [
              _Toggle(
                Icons.sync,
                'Auto-reconnect',
                s.autoReconnect,
                (v) => up((x) => x.copyWith(autoReconnect: v)),
              ),
              _Row(Icons.repeat, 'Max retries', value: '${s.maxRetries}'),
              _Row(
                Icons.hourglass_bottom,
                'Backoff',
                value:
                    'Exponential ${policy.delayFor(1)!.inSeconds}s to ${policy.delayFor(policy.maxRetries)!.inSeconds}s',
                last: true,
              ),
            ],
          ),
          _Group(
            'Engine',
            children: [
              _Row(
                Icons.layers_outlined,
                'Default engine',
                value: s.engine.label,
              ),
              const _Row(Icons.public, 'Region', value: 'Auto', last: true),
            ],
          ),
          _Group(
            'Developer and QA',
            children: [
              _Toggle(
                Icons.bug_report_outlined,
                'Debug overlay',
                s.debugOverlay,
                (v) => up((x) => x.copyWith(debugOverlay: v)),
              ),
              _Toggle(
                Icons.wifi_off,
                'Simulate poor network',
                s.simulatePoorNetwork,
                (v) => up((x) => x.copyWith(simulatePoorNetwork: v)),
              ),
              const _Row(
                Icons.file_download_outlined,
                'Export session logs',
                trailingIcon: Icons.download,
                last: true,
              ),
            ],
          ),
          _Group(
            'Chat',
            children: [
              _Toggle(
                Icons.slow_motion_video,
                'Slow mode',
                s.slowMode,
                (v) => up((x) => x.copyWith(slowMode: v)),
              ),
              _Row(
                Icons.block,
                'Blocked words',
                value: '${s.blockedWords}',
                last: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, {required this.children, this.header});
  final String title;
  final String? header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: LW.caption(w: FontWeight.w700).copyWith(letterSpacing: 1),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: LW.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: LW.border),
            boxShadow: LW.cardShadow,
          ),
          child: Column(
            children: [
              if (header != null)
                Container(
                  width: double.infinity,
                  color: LW.accentTint,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    header!,
                    style: LW
                        .small(color: LW.accentFill, w: FontWeight.w700)
                        .copyWith(letterSpacing: .8),
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(
    this.icon,
    this.label, {
    this.value,
    this.trailingIcon,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final String? value;
  final IconData? trailingIcon;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      border: last ? null : const Border(bottom: BorderSide(color: LW.border)),
    ),
    child: Row(
      children: [
        Icon(icon, color: LW.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: LW.label(w: FontWeight.w500)),
        ),
        if (value != null)
          Text(value!, style: LW.label(color: LW.inkSecondary)),
        const SizedBox(width: 4),
        Icon(
          trailingIcon ?? Icons.chevron_right,
          color: trailingIcon != null ? LW.accent : LW.inkTertiary,
          size: 20,
        ),
      ],
    ),
  );
}

class _Toggle extends StatelessWidget {
  const _Toggle(
    this.icon,
    this.label,
    this.value,
    this.onChanged, {
    this.last = false,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.only(left: 16, right: 8),
    decoration: BoxDecoration(
      border: last ? null : const Border(bottom: BorderSide(color: LW.border)),
    ),
    child: Row(
      children: [
        Icon(icon, color: LW.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: LW.label(w: FontWeight.w500)),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: LW.accentFill,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
