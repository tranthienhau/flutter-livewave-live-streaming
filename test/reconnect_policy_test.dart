import 'package:flutter_test/flutter_test.dart';
import 'package:livewave/streaming/stream_engine.dart';

void main() {
  group('ReconnectPolicy', () {
    const policy = ReconnectPolicy();

    test('doubles the delay each attempt', () {
      expect(policy.delayFor(1), const Duration(seconds: 1));
      expect(policy.delayFor(2), const Duration(seconds: 2));
      expect(policy.delayFor(3), const Duration(seconds: 4));
      expect(policy.delayFor(4), const Duration(seconds: 8));
      expect(policy.delayFor(5), const Duration(seconds: 16));
    });

    test('caps at max and stops after maxRetries', () {
      const p = ReconnectPolicy(maxRetries: 8, max: Duration(seconds: 10));
      expect(p.delayFor(6), const Duration(seconds: 10));
      expect(p.delayFor(9), isNull);
      expect(policy.delayFor(0), isNull);
    });
  });

  group('StreamStats.healthLabel', () {
    StreamStats s({int rtt = 300, double loss = 0.2, LinkState st = LinkState.live}) =>
        StreamStats(bitrateMbps: 3, fps: 30, latencyMs: rtt, packetLossPct: loss, state: st);

    test('classifies network quality', () {
      expect(s().healthLabel, 'Excellent');
      expect(s(rtt: 500).healthLabel, 'Fair');
      expect(s(loss: 4).healthLabel, 'Poor');
      expect(s(st: LinkState.reconnecting).healthLabel, 'Reconnecting');
    });
  });

  group('SimulatedEngine', () {
    test('emits drop, retry and recovery events', () async {
      final engine = SimulatedEngine(EngineKind.agora);
      final events = <String>[];
      engine.reconnects.listen((e) => events.add(e.kind));
      await engine.start(title: 't', quality: VideoQuality.p720);
      engine.simulateNetworkDrop();
      await Future<void>.delayed(const Duration(milliseconds: 3200));
      await engine.stop();
      engine.dispose();
      expect(events.first, 'drop');
      expect(events, contains('retry'));
      expect(events.last, 'ok');
    });
  });
}
