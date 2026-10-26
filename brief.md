# Livewave - Source Brief

## Title

Livewave - live streaming for creators and their communities

## Description

Livewave is a mobile live streaming app. Viewers browse who is live, drop into a full-screen stream, chat in real time, tap hearts and send virtual gifts paid with coins. Creators set up a stream in one screen (title, category, streaming engine, quality, pre-flight check), go live, and run the room: watch the timer and viewer count, pin or remove comments, see gift alerts, and open a stream health panel that shows bitrate, FPS, latency, packet loss and every reconnect attempt. When the stream ends they get a summary with peak viewers, gifts earned and top supporters.

## Store links

Not yet published (proof of concept).

## Platform

Both - iOS and Android from one Flutter codebase.

## Category

Social / Live video

## Features

- Live feed: featured stream, followed creators who are live, live-now grid
- Empty state when nobody you follow is live, with suggested creators
- Explore: search, category chips, trending carousel, top categories, rising creators
- Creator profile: live badge, stats, follow, schedule, past streams
- Watch live: full-bleed video, live comments overlay, viewer count, follow, floating hearts, HD indicator
- Gift sheet: 8 gifts, quantity x1/x5/x10, coin balance check, top-up route when short
- Go live setup: camera preview, title, category, engine choice (Agora, LiveKit, WebRTC), 480p/720p/1080p, adaptive bitrate, pre-flight check
- Host room: LIVE timer, viewers, health chip, gift alerts, pin / mute / remove moderation, mic toggle, debug overlay, network drop simulation
- Stream health: live bitrate chart against target, FPS, RTT, packet loss, resolution, connection details, reconnect log with exponential backoff
- Post-stream summary: peak viewers, views, followers, comments, gifts, watch time, latency, top supporters
- Wallet: coin balance, earnings, six coin packs, recent activity
- Profile: weekly streaming chart, replays, clips, scheduled
- Stream settings: quality, frame rate, low-latency, auto-reconnect, retries, backoff, engine, region, QA toggles, chat moderation

## Tech stack

- Flutter + Dart
- Riverpod 3 (Notifier / NotifierProvider) for state
- go_router with a StatefulShellRoute for the five-tab shell
- google_fonts (Sora + Syne), intl
- Vendor-neutral `StreamEngine` interface with a `SimulatedEngine`; production adapters wrap agora_rtc_engine, livekit_client or flutter_webrtc behind the same surface
- `ReconnectPolicy` exponential backoff (1s to 16s, capped retries)
- integration_test screenshot harness, flutter_test unit tests

## Industry

Creator economy / live video / social

## Metrics

Unpublished proof of concept. 14 core screens, 5 unit tests (backoff, health classifier, engine reconnect sequence, wallet rules), analyzer clean.

## Research notes

- Verified: all UI flows, state changes (follow, gifts debit coins, top-up credits coins, pin and remove comments, debug overlay, network drop and recovery) run in the app.
- Mocked: video frames are still photos, stats come from `SimulatedEngine`, chat and presence are scripted tickers, purchases are sandbox only.
- Future expansion: plug in the Agora / LiveKit adapter, token server for channel auth, WebSocket chat backend, in-app purchases (StoreKit 2 / Play Billing), replay recording to cloud storage, push notifications when followed creators go live, moderation word filter on the server.
