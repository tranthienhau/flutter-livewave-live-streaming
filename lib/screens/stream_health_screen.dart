import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../state/providers.dart';
import '../streaming/stream_engine.dart';
import '../widgets/common.dart';

/// Live publisher diagnostics: bitrate chart, FPS, RTT, loss, reconnect log.
class StreamHealthScreen extends ConsumerWidget {
  const StreamHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(hostSessionProvider) ?? ref.watch(lastSessionProvider);
    final st = s?.stats;
    final target = s?.config.quality.targetMbps ?? 3.0;
    final stable = st == null || st.state == LinkState.live;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: LW.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Stream health', style: LW.title()),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: stable ? LW.successTint : LW.warningTint,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              stable ? 'Stable' : 'Reconnecting',
              style: LW.caption(
                color: stable ? LW.success : LW.warning,
                w: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          LWCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload bitrate', style: LW.caption()),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(st?.bitrateMbps ?? target).toStringAsFixed(1)} Mbps',
                      style: LW.numeral(),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: LW.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Target ${target.toStringAsFixed(1)} Mbps',
                        style: LW.small(
                          color: LW.inkSecondary,
                          w: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _BitrateChart(s?.history ?? const [], target),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final l in ['-60s', '-45s', '-30s', '-15s', 'now'])
                      Text(l, style: LW.small()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _Metric(Icons.speed, 'FPS', '${st?.fps ?? 30}'),
              _Metric(
                Icons.timer_outlined,
                'Latency',
                '${st?.latencyMs ?? 312} ms',
              ),
              _Metric(
                Icons.network_check,
                'Packet loss',
                '${st?.packetLossPct ?? 0.4}%',
              ),
              _Metric(
                Icons.aspect_ratio,
                'Resolution',
                s?.config.quality.label ?? '720p',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LWCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connection', style: LW.label(w: FontWeight.w600)),
                const SizedBox(height: 8),
                _kv('Engine', s?.config.engine.sdk ?? 'Agora RTC'),
                _kv('Region', 'Singapore'),
                _kv('Network', 'Wi-Fi 5 GHz'),
                _kv('Encoder', 'H.264 hardware', last: true),
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
                        'Reconnect log',
                        style: LW.label(w: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${(s?.log ?? const []).where((e) => e.kind == 'drop').length} drops',
                      style: LW.caption(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final e
                    in (s?.log ?? const <ReconnectEvent>[]).reversed.take(6))
                  _LogRow(e),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LWCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: s?.debugOverlay ?? false,
              activeTrackColor: LW.accentFill,
              onChanged: (_) =>
                  ref.read(hostSessionProvider.notifier).toggleDebug(),
              title: Text('Show debug overlay on video', style: LW.label()),
              subtitle: Text(
                'Live fps, RTT and loss on the host view',
                style: LW.small(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, {bool last = false}) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      border: last ? null : const Border(bottom: BorderSide(color: LW.border)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: LW.label(color: LW.inkSecondary)),
        ),
        Text(v, style: LW.label(w: FontWeight.w600)),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => LWCard(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: LW.accentTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: LW.accentFill),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: LW.numeral(size: 20, color: LW.ink)),
            Text(label, style: LW.caption()),
          ],
        ),
      ],
    ),
  );
}

class _LogRow extends StatelessWidget {
  const _LogRow(this.e);
  final ReconnectEvent e;

  @override
  Widget build(BuildContext context) {
    final (icon, fg, bg) = switch (e.kind) {
      'drop' => (Icons.warning_amber_rounded, LW.warning, LW.warningTint),
      'ok' => (Icons.check, LW.success, LW.successTint),
      _ => (Icons.refresh, LW.accentFill, LW.accentTint),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hms(e.elapsed),
                  style: LW.small().copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  e.message,
                  style: LW.label(
                    w: e.kind == 'ok' ? FontWeight.w600 : FontWeight.w500,
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

class _BitrateChart extends CustomPainter {
  _BitrateChart(this.data, this.target);
  final List<double> data;
  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final maxY = max(target * 1.4, data.isEmpty ? 1.0 : data.reduce(max) * 1.1);
    final grid = Paint()
      ..color = LW.border
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // target line (dashed)
    final ty = size.height - target / maxY * size.height;
    final dash = Paint()
      ..color = LW.supportStrong
      ..strokeWidth = 2;
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, ty), Offset(min(x + 5, size.width), ty), dash);
    }
    if (data.length < 2) return;
    final pts = <Offset>[
      for (var i = 0; i < data.length; i++)
        Offset(size.width * i / 59, size.height - data[i] / maxY * size.height),
    ];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    final fill = Path.from(path)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            LW.accent.withValues(alpha: .22),
            LW.accent.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = LW.accent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(pts.last, 5, Paint()..color = LW.accent);
    canvas.drawCircle(pts.last, 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_BitrateChart old) => old.data != data;
}
