# Regenerating screenshots and demo GIFs

## iOS screenshots

```sh
xcrun simctl boot "iPhone 17 Pro"
open -a Simulator
flutter pub get
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d "iPhone 17 Pro"
```

How it works:

- `integration_test/screenshot_test.dart` launches the app, drives the router (`appRouter.go/push`) and taps keyed widgets (`get-started`, `gift-button`, `go-live`, `simulate-drop`, `open-health`, `end-stream`, `open-settings`).
- It calls `binding.convertFlutterSurfaceToImage()` once, then `binding.takeScreenshot('NN-name')` per screen.
- The live rooms animate continuously (chat ticker, floating hearts, stats engine), so the test uses fixed `pump(Duration)` calls, never `pumpAndSettle`.
- `test_driver/integration_test.dart` receives each PNG through `integrationDriver(onScreenshot:)` and writes it to `screenshots/`.

## Demo GIFs

iOS:

```sh
xcrun simctl io booted recordVideo --codec h264 /tmp/ios.mp4   # Ctrl-C to stop
```

Android (always use `--time-limit` so the mp4 is finalized):

```sh
emulator -avd Medium_Phone_API_36.1 &
flutter run -d emulator-5554 --release
adb shell screenrecord --time-limit 27 --size 540x1200 /sdcard/ademo.mp4
adb pull /sdcard/ademo.mp4 /tmp/android.mp4
```

Convert either to a GIF (12 fps, 300 px wide):

```sh
ffmpeg -y -i in.mp4 -vf "fps=12,scale=300:-1:flags=lanczos,palettegen=stats_mode=diff" /tmp/pal.png
ffmpeg -y -i in.mp4 -i /tmp/pal.png -lavfi "fps=12,scale=300:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3" screenshots/demo.gif
```

## Unit tests

```sh
flutter test
```

Covers the exponential backoff policy, the health classifier, the simulated engine's drop, retry and recover sequence, and wallet spend and top-up rules.
