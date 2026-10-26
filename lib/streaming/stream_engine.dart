import 'dart:async';
import 'dart:math';

/// Which realtime transport publishes the host camera.
/// The UI only talks to [StreamEngine]; swapping vendors is a one-line change.
enum EngineKind { agora, liveKit, webRtc }

extension EngineKindInfo on EngineKind {
  String get label => switch (this) {
    EngineKind.agora => 'Agora',
    EngineKind.liveKit => 'LiveKit',
    EngineKind.webRtc => 'WebRTC',
  };

  String get sdk => switch (this) {
    EngineKind.agora => 'Agora RTC',
    EngineKind.liveKit => 'LiveKit SFU',
    EngineKind.webRtc => 'WebRTC P2P + TURN',
  };

  String get latencyNote => switch (this) {
    EngineKind.agora => 'Ultra low latency, under 400 ms',
    EngineKind.liveKit => 'Low latency SFU, under 500 ms',
    EngineKind.webRtc => 'Peer to peer, best for small rooms',
  };
}

enum VideoQuality { p480, p720, p1080 }

extension VideoQualityInfo on VideoQuality {
  String get label => switch (this) {
    VideoQuality.p480 => '480p',
    VideoQuality.p720 => '720p',
    VideoQuality.p1080 => '1080p',
  };

  /// Target upload bitrate in Mbps.
  double get targetMbps => switch (this) {
    VideoQuality.p480 => 1.2,
    VideoQuality.p720 => 3.0,
    VideoQuality.p1080 => 5.5,
  };
}

enum LinkState { idle, connecting, live, reconnecting, ended }

/// One sample of publisher-side health, emitted once per second.
class StreamStats {
  const StreamStats({
    required this.bitrateMbps,
    required this.fps,
    required this.latencyMs,
    required this.packetLossPct,
    required this.state,
  });

  final double bitrateMbps;
  final int fps;
  final int latencyMs;
  final double packetLossPct;
  final LinkState state;

  /// Human label for the health chip in the host room.
  String get healthLabel {
    if (state == LinkState.reconnecting) return 'Reconnecting';
    if (packetLossPct > 3 || latencyMs > 800) return 'Poor';
    if (packetLossPct > 1 || latencyMs > 450) return 'Fair';
    return 'Excellent';
  }
}

class ReconnectEvent {
  const ReconnectEvent(this.elapsed, this.message, this.kind);
  final Duration elapsed;
  final String message;
  final String kind; // drop, retry, ok
}

/// Exponential backoff: 1s, 2s, 4s ... capped, with optional jitter.
class ReconnectPolicy {
  const ReconnectPolicy({
    this.base = const Duration(seconds: 1),
    this.max = const Duration(seconds: 16),
    this.maxRetries = 5,
    this.jitter = 0,
  });

  final Duration base;
  final Duration max;
  final int maxRetries;
  final double jitter;

  /// Delay before retry number [attempt] (1-based). Null when retries are exhausted.
  Duration? delayFor(int attempt, {Random? random}) {
    if (attempt < 1 || attempt > maxRetries) return null;
    final ms = base.inMilliseconds * pow(2, attempt - 1);
    final capped = min(ms.toDouble(), max.inMilliseconds.toDouble());
    final spread = jitter == 0
        ? 0
        : (random ?? Random()).nextDouble() * jitter * capped;
    return Duration(milliseconds: (capped + spread).round());
  }
}

/// Vendor-neutral publisher contract. Real adapters wrap agora_rtc_engine,
/// livekit_client or flutter_webrtc behind this same surface.
abstract class StreamEngine {
  EngineKind get kind;
  Stream<StreamStats> get stats;
  Stream<ReconnectEvent> get reconnects;
  Future<void> start({required String title, required VideoQuality quality});
  void simulateNetworkDrop();
  Future<void> stop();
}

/// Deterministic-ish simulator so the app is demoable on a simulator with no
/// camera, no SDK keys and no backend.
class SimulatedEngine implements StreamEngine {
  SimulatedEngine(
    this.kind, {
    this.policy = const ReconnectPolicy(),
    int seed = 7,
  }) : _rand = Random(seed);

  @override
  final EngineKind kind;
  final ReconnectPolicy policy;
  final Random _rand;

  final _stats = StreamController<StreamStats>.broadcast();
  final _reconnects = StreamController<ReconnectEvent>.broadcast();
  Timer? _ticker;
  final _clock = Stopwatch();
  VideoQuality _quality = VideoQuality.p720;
  LinkState _state = LinkState.idle;
  int _dropTicks = 0;
  int _attempt = 0;

  @override
  Stream<StreamStats> get stats => _stats.stream;
  @override
  Stream<ReconnectEvent> get reconnects => _reconnects.stream;

  int get _baseLatency => switch (kind) {
    EngineKind.agora => 300,
    EngineKind.liveKit => 360,
    EngineKind.webRtc => 220,
  };

  @override
  Future<void> start({
    required String title,
    required VideoQuality quality,
  }) async {
    _quality = quality;
    _state = LinkState.live;
    _clock
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void _tick() {
    if (_state == LinkState.ended) return;
    if (_dropTicks > 0) {
      _dropTicks--;
      if (_dropTicks == 0) {
        _state = LinkState.live;
        _reconnects.add(
          ReconnectEvent(
            _clock.elapsed,
            'Reconnected in ${(1 + _attempt * 1.4).toStringAsFixed(1)}s',
            'ok',
          ),
        );
        _attempt = 0;
      } else {
        _attempt++;
        final d = policy.delayFor(_attempt);
        if (d != null) {
          _reconnects.add(
            ReconnectEvent(
              _clock.elapsed,
              'Retry $_attempt after ${d.inSeconds}s backoff',
              'retry',
            ),
          );
        }
      }
    }
    final target = _quality.targetMbps;
    final live = _state == LinkState.live;
    _stats.add(
      StreamStats(
        bitrateMbps: live
            ? target * (0.95 + _rand.nextDouble() * 0.15)
            : target * 0.2,
        fps: live ? 30 - (_rand.nextInt(10) == 0 ? 1 : 0) : 12,
        latencyMs: live
            ? _baseLatency + _rand.nextInt(40)
            : 900 + _rand.nextInt(300),
        packetLossPct: live
            ? double.parse((_rand.nextDouble() * 0.6).toStringAsFixed(1))
            : 6.5,
        state: _state,
      ),
    );
  }

  @override
  void simulateNetworkDrop() {
    if (_state != LinkState.live) return;
    _state = LinkState.reconnecting;
    _dropTicks = 3;
    _attempt = 0;
    _reconnects.add(
      ReconnectEvent(_clock.elapsed, 'Network dropped, reconnecting', 'drop'),
    );
  }

  @override
  Future<void> stop() async {
    _state = LinkState.ended;
    _ticker?.cancel();
    _clock.stop();
  }

  void dispose() {
    _ticker?.cancel();
    _stats.close();
    _reconnects.close();
  }
}
