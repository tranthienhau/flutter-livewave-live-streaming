import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../streaming/stream_engine.dart';

// ---------------------------------------------------------------- wallet

class WalletState {
  const WalletState({required this.coins, required this.txns});
  final int coins;
  final List<WalletTxn> txns;
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() =>
      const WalletState(coins: 1250, txns: Mock.transactions);

  /// Returns false when the balance is too low (UI routes to top up).
  bool spend(int coins, String title) {
    if (coins > state.coins) return false;
    state = WalletState(
      coins: state.coins - coins,
      txns: [WalletTxn(title, 'Just now', -coins, 'gift_out'), ...state.txns],
    );
    return true;
  }

  void topUp(CoinPack pack) {
    state = WalletState(
      coins: state.coins + pack.coins,
      txns: [
        WalletTxn('Top up', 'Just now', pack.coins, 'topup'),
        ...state.txns,
      ],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);

// ---------------------------------------------------------------- follows

class FollowNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'lena', 'marco', 'aiko', 'sam'};

  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final followProvider = NotifierProvider<FollowNotifier, Set<String>>(
  FollowNotifier.new,
);

/// Demo switch for the Home empty state ("nobody you follow is live").
class HomeEmptyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final homeEmptyProvider = NotifierProvider<HomeEmptyNotifier, bool>(
  HomeEmptyNotifier.new,
);

// ---------------------------------------------------------------- viewer room

class ViewerRoomState {
  const ViewerRoomState({
    required this.comments,
    required this.viewers,
    required this.likes,
    required this.hearts,
  });

  final List<LiveComment> comments;
  final int viewers;
  final int likes;

  /// Monotonic counter; each bump spawns one floating heart.
  final int hearts;

  ViewerRoomState copyWith({
    List<LiveComment>? comments,
    int? viewers,
    int? likes,
    int? hearts,
  }) => ViewerRoomState(
    comments: comments ?? this.comments,
    viewers: viewers ?? this.viewers,
    likes: likes ?? this.likes,
    hearts: hearts ?? this.hearts,
  );
}

/// Simulates the realtime chat + presence channel of a live room.
class ViewerRoomNotifier extends Notifier<ViewerRoomState> {
  Timer? _timer;
  int _cursor = 6;

  @override
  ViewerRoomState build() {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) => _tick());
    return ViewerRoomState(
      comments: Mock.viewerChat.take(6).toList(),
      viewers: 2481,
      likes: 18300,
      hearts: 0,
    );
  }

  void _tick() {
    final next = Mock.viewerChat[_cursor % Mock.viewerChat.length];
    _cursor++;
    state = state.copyWith(
      comments: _cap([...state.comments, next]),
      viewers: state.viewers + (_cursor.isEven ? 3 : -1),
      hearts: state.hearts + 1,
    );
  }

  List<LiveComment> _cap(List<LiveComment> list) =>
      list.length > 7 ? list.sublist(list.length - 7) : list;

  void send(String text) {
    if (text.trim().isEmpty) return;
    state = state.copyWith(
      comments: _cap([
        ...state.comments,
        LiveComment(author: 'Maya', text: text.trim(), avatar: Img.maya),
      ]),
    );
  }

  void like() =>
      state = state.copyWith(likes: state.likes + 1, hearts: state.hearts + 1);

  void giftSent(Gift gift, int qty) {
    state = state.copyWith(
      comments: _cap([
        ...state.comments,
        LiveComment(
          author: 'Maya',
          text: 'sent a ${gift.name} x$qty',
          avatar: Img.maya,
          kind: CommentKind.gift,
        ),
      ]),
      hearts: state.hearts + 3,
    );
  }
}

final viewerRoomProvider =
    NotifierProvider.autoDispose<ViewerRoomNotifier, ViewerRoomState>(
      ViewerRoomNotifier.new,
    );

// ---------------------------------------------------------------- go live setup

class GoLiveConfig {
  const GoLiveConfig({
    this.title = 'Morning coffee and Q&A',
    this.category = StreamCategory.talk,
    this.engine = EngineKind.agora,
    this.quality = VideoQuality.p720,
    this.adaptiveBitrate = true,
  });

  final String title;
  final StreamCategory category;
  final EngineKind engine;
  final VideoQuality quality;
  final bool adaptiveBitrate;

  GoLiveConfig copyWith({
    String? title,
    StreamCategory? category,
    EngineKind? engine,
    VideoQuality? quality,
    bool? adaptiveBitrate,
  }) => GoLiveConfig(
    title: title ?? this.title,
    category: category ?? this.category,
    engine: engine ?? this.engine,
    quality: quality ?? this.quality,
    adaptiveBitrate: adaptiveBitrate ?? this.adaptiveBitrate,
  );
}

class GoLiveConfigNotifier extends Notifier<GoLiveConfig> {
  @override
  GoLiveConfig build() => const GoLiveConfig();
  void update(GoLiveConfig Function(GoLiveConfig) f) => state = f(state);
}

final goLiveConfigProvider =
    NotifierProvider<GoLiveConfigNotifier, GoLiveConfig>(
      GoLiveConfigNotifier.new,
    );

// ---------------------------------------------------------------- host session

class HostSession {
  const HostSession({
    required this.config,
    required this.elapsed,
    required this.viewers,
    required this.peakViewers,
    required this.stats,
    required this.history,
    required this.log,
    required this.comments,
    required this.giftCoins,
    required this.micOn,
    required this.debugOverlay,
    this.giftAlert,
  });

  final GoLiveConfig config;
  final Duration elapsed;
  final int viewers;
  final int peakViewers;
  final StreamStats? stats;
  final List<double> history; // last 60 bitrate samples
  final List<ReconnectEvent> log;
  final List<LiveComment> comments;
  final int giftCoins;
  final bool micOn;
  final bool debugOverlay;
  final String? giftAlert;

  HostSession copyWith({
    Duration? elapsed,
    int? viewers,
    int? peakViewers,
    StreamStats? stats,
    List<double>? history,
    List<ReconnectEvent>? log,
    List<LiveComment>? comments,
    int? giftCoins,
    bool? micOn,
    bool? debugOverlay,
    String? giftAlert,
    bool clearGift = false,
  }) => HostSession(
    config: config,
    elapsed: elapsed ?? this.elapsed,
    viewers: viewers ?? this.viewers,
    peakViewers: peakViewers ?? this.peakViewers,
    stats: stats ?? this.stats,
    history: history ?? this.history,
    log: log ?? this.log,
    comments: comments ?? this.comments,
    giftCoins: giftCoins ?? this.giftCoins,
    micOn: micOn ?? this.micOn,
    debugOverlay: debugOverlay ?? this.debugOverlay,
    giftAlert: clearGift ? null : (giftAlert ?? this.giftAlert),
  );
}

/// Owns the publisher engine for the duration of a broadcast.
class HostSessionNotifier extends Notifier<HostSession?> {
  SimulatedEngine? _engine;
  final _subs = <StreamSubscription>[];
  Timer? _clock;
  int _chatCursor = 4;

  @override
  HostSession? build() {
    ref.onDispose(_teardown);
    return null;
  }

  Future<void> start(GoLiveConfig config) async {
    _teardown();
    final settings = ref.read(settingsProvider);
    final engine = SimulatedEngine(
      config.engine,
      policy: ReconnectPolicy(maxRetries: settings.maxRetries),
    );
    _engine = engine;
    // Seeded so the demo opens mid-stream with a realistic recent history.
    state = HostSession(
      config: config,
      elapsed: const Duration(minutes: 24, seconds: 17),
      viewers: 1034,
      peakViewers: 1034,
      stats: null,
      history: List.generate(
        40,
        (i) => config.quality.targetMbps * (0.97 + (i % 7) * 0.02),
      ),
      log: const [
        ReconnectEvent(
          Duration(minutes: 18, seconds: 2),
          'Network dropped, reconnecting',
          'drop',
        ),
        ReconnectEvent(
          Duration(minutes: 18, seconds: 4),
          'Retry 1 after 1s backoff',
          'retry',
        ),
        ReconnectEvent(
          Duration(minutes: 18, seconds: 6),
          'Reconnected in 3.8s',
          'ok',
        ),
      ],
      comments: Mock.hostChat.take(4).toList(),
      giftCoins: 5950,
      micOn: true,
      debugOverlay: settings.debugOverlay,
      giftAlert: 'Sofia sent a Crown x1  +500',
    );
    _subs.add(engine.stats.listen(_onStats));
    _subs.add(
      engine.reconnects.listen((e) {
        final s = state;
        if (s == null) return;
        state = s.copyWith(
          log: [...s.log, ReconnectEvent(s.elapsed, e.message, e.kind)],
        );
      }),
    );
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => _onSecond());
    await engine.start(title: config.title, quality: config.quality);
  }

  void _onStats(StreamStats st) {
    final s = state;
    if (s == null) return;
    final h = [...s.history, st.bitrateMbps];
    state = s.copyWith(
      stats: st,
      history: h.length > 60 ? h.sublist(h.length - 60) : h,
    );
  }

  void _onSecond() {
    final s = state;
    if (s == null) return;
    final v = s.viewers + (s.elapsed.inSeconds.isEven ? 7 : -2);
    var comments = s.comments;
    if (s.elapsed.inSeconds % 3 == 0) {
      final next = Mock.hostChat[_chatCursor % Mock.hostChat.length].copyWith(
        pinned: false,
      );
      _chatCursor++;
      comments = [...comments, next];
      if (comments.length > 6) {
        comments = [comments.first, ...comments.sublist(comments.length - 5)];
      }
    }
    state = s.copyWith(
      elapsed: s.elapsed + const Duration(seconds: 1),
      viewers: v,
      peakViewers: v > s.peakViewers ? v : s.peakViewers,
      comments: comments,
      clearGift: s.elapsed.inSeconds % 6 == 5,
    );
  }

  void toggleMic() => state = state?.copyWith(micOn: !state!.micOn);
  void toggleDebug() =>
      state = state?.copyWith(debugOverlay: !state!.debugOverlay);
  void simulateDrop() => _engine?.simulateNetworkDrop();

  void pin(LiveComment c) {
    final s = state;
    if (s == null) return;
    final rest = s.comments
        .where((x) => x != c)
        .map((x) => x.copyWith(pinned: false));
    state = s.copyWith(comments: [c.copyWith(pinned: true), ...rest]);
  }

  void remove(LiveComment c) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(comments: s.comments.where((x) => x != c).toList());
  }

  /// Ends the broadcast and returns the final snapshot for the summary screen.
  Future<HostSession?> end() async {
    final s = state;
    await _engine?.stop();
    _teardown();
    return s;
  }

  void _teardown() {
    _clock?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _engine?.dispose();
    _engine = null;
  }
}

final hostSessionProvider = NotifierProvider<HostSessionNotifier, HostSession?>(
  HostSessionNotifier.new,
);

/// Snapshot of the last ended broadcast, read by the summary screen.
class LastSessionNotifier extends Notifier<HostSession?> {
  @override
  HostSession? build() => null;
  void set(HostSession? s) => state = s;
}

final lastSessionProvider = NotifierProvider<LastSessionNotifier, HostSession?>(
  LastSessionNotifier.new,
);

// ---------------------------------------------------------------- settings

class StreamSettings {
  const StreamSettings({
    this.quality = VideoQuality.p720,
    this.fps = 30,
    this.adaptiveBitrate = true,
    this.lowLatency = true,
    this.autoReconnect = true,
    this.maxRetries = 5,
    this.engine = EngineKind.agora,
    this.debugOverlay = false,
    this.simulatePoorNetwork = false,
    this.slowMode = false,
    this.blockedWords = 12,
  });

  final VideoQuality quality;
  final int fps;
  final bool adaptiveBitrate;
  final bool lowLatency;
  final bool autoReconnect;
  final int maxRetries;
  final EngineKind engine;
  final bool debugOverlay;
  final bool simulatePoorNetwork;
  final bool slowMode;
  final int blockedWords;

  StreamSettings copyWith({
    bool? adaptiveBitrate,
    bool? lowLatency,
    bool? autoReconnect,
    bool? debugOverlay,
    bool? simulatePoorNetwork,
    bool? slowMode,
  }) => StreamSettings(
    quality: quality,
    fps: fps,
    adaptiveBitrate: adaptiveBitrate ?? this.adaptiveBitrate,
    lowLatency: lowLatency ?? this.lowLatency,
    autoReconnect: autoReconnect ?? this.autoReconnect,
    maxRetries: maxRetries,
    engine: engine,
    debugOverlay: debugOverlay ?? this.debugOverlay,
    simulatePoorNetwork: simulatePoorNetwork ?? this.simulatePoorNetwork,
    slowMode: slowMode ?? this.slowMode,
    blockedWords: blockedWords,
  );
}

class SettingsNotifier extends Notifier<StreamSettings> {
  @override
  StreamSettings build() => const StreamSettings();
  void update(StreamSettings Function(StreamSettings) f) => state = f(state);
}

final settingsProvider = NotifierProvider<SettingsNotifier, StreamSettings>(
  SettingsNotifier.new,
);
