/// Renders `web/og-image.png` — the link-preview card — from the same data
/// the site itself renders.
///
/// The card leads with [headlineMetrics], and one of those numbers (pub.dev
/// downloads) is rewritten by CI on every build. A hand-drawn PNG would go
/// stale the first time that happened and nobody would notice, because the
/// image is only ever seen in someone else's Slack. So it's generated:
/// this script writes an HTML card and screenshots it with headless Chrome
/// at exactly the 1200x630 declared in the `og:image:width/height` tags.
///
/// ```sh
/// dart run tool/og_image.dart
/// ```
///
/// Chrome is found at the usual macOS and Linux locations, or via
/// `CHROME_PATH`. Failing to find it is a hard error locally; the deploy
/// workflow tolerates it and ships the committed PNG instead.
library;

import 'dart:convert';
import 'dart:io';

import 'package:site/data/metrics.dart';
import 'package:site/data/profile.dart';

const _width = 1200;
const _height = 630;

void main(List<String> args) async {
  final root = File.fromUri(Platform.script).parent.parent;
  final output = File('${root.path}/web/og-image.png');
  final logo = File('${root.path}/web/apple-touch-icon.png');

  final html = File('${Directory.systemTemp.path}/og-image.html');
  html.writeAsStringSync(_card(logo: base64.encode(logo.readAsBytesSync())));

  final chrome = _findChrome();
  if (chrome == null) {
    stderr.writeln('No Chrome found. Set CHROME_PATH to a Chrome or Chromium binary.');
    exit(1);
  }

  final result = await Process.run(chrome, [
    '--headless=new',
    '--disable-gpu',
    '--hide-scrollbars',
    // The page is a local file this script just wrote, so the sandbox is
    // buying nothing — and without these two, Chrome refuses to start in
    // the kind of root/containerised environment CI runs in.
    '--no-sandbox',
    '--disable-dev-shm-usage',
    '--force-device-scale-factor=1',
    '--window-size=$_width,$_height',
    '--screenshot=${output.path}',
    // Long enough for the webfont request to resolve. Chrome fast-forwards
    // timers rather than sleeping, so this costs nothing when the font is
    // already cached — and a card rendered in the fallback font would be
    // silently wrong, not obviously broken.
    '--virtual-time-budget=8000',
    html.uri.toString(),
  ]);

  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    exit(result.exitCode);
  }
  stdout.writeln('wrote ${output.path} (${output.lengthSync() ~/ 1024}KB)');
}

/// The first Chrome-like binary that actually exists on this machine.
String? _findChrome() {
  final candidates = [
    if (Platform.environment['CHROME_PATH'] case final path?) path,
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium',
    '/usr/bin/google-chrome',
    '/usr/bin/chromium-browser',
    '/usr/bin/chromium',
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  return null;
}

/// The card markup. Deliberately a single self-contained string rather than
/// a Jaspr component: it renders in Chrome, not in the app, and coupling it
/// to the component tree would mean booting the whole site to take a
/// screenshot of four numbers.
String _card({required String logo}) {
  final metrics = headlineMetrics
      .map(
        (metric) => '''
        <div class="metric">
          <div class="value">${_escape(metric.value)}</div>
          <div class="label">${_escape(metric.label)}</div>
        </div>''',
      )
      .join('\n');

  return '''
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=block" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: ${_width}px;
    height: ${_height}px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
    background-color: #07080c;
    font-family: 'JetBrains Mono', monospace;
    -webkit-font-smoothing: antialiased;
  }
  /* The aurora wash from the site's ambient background, flattened to
     three static glows — cyan top-left, amber top-right, violet bottom. */
  .glow {
    position: absolute;
    inset: 0;
    background:
      radial-gradient(620px 420px at 8% 2%, rgba(45, 212, 191, 0.20), transparent 70%),
      radial-gradient(520px 360px at 78% -6%, rgba(251, 191, 36, 0.16), transparent 70%),
      radial-gradient(680px 460px at 96% 104%, rgba(167, 139, 250, 0.16), transparent 70%);
  }
  .grid {
    position: absolute;
    inset: 0;
    background-image: radial-gradient(rgba(255, 255, 255, 0.055) 1px, transparent 1px);
    background-size: 26px 26px;
    -webkit-mask-image: radial-gradient(circle at 50% 45%, #000 55%, transparent 100%);
  }
  .logo {
    position: absolute;
    top: 40px;
    right: 44px;
    width: 96px;
    height: 96px;
    border-radius: 22px;
    box-shadow: 0 18px 44px rgba(45, 212, 191, 0.22);
  }
  .window {
    position: relative;
    width: 920px;
    border: 1px solid rgba(255, 255, 255, 0.09);
    border-radius: 16px;
    overflow: hidden;
    background: rgba(15, 17, 26, 0.82);
    box-shadow: 0 30px 90px rgba(0, 0, 0, 0.55);
  }
  .titlebar {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 19px 24px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.07);
    background: rgba(255, 255, 255, 0.02);
  }
  .dot { width: 12px; height: 12px; border-radius: 50%; background: #2b3040; }
  .title { margin-left: 12px; color: #8b93a7; font-size: 15px; }
  .title span { color: #4b5468; }
  .body { padding: 34px 40px 36px; }
  h1 {
    color: #5eead4;
    font-size: 46px;
    font-weight: 700;
    letter-spacing: -1px;
    line-height: 1.1;
  }
  .role { margin-top: 14px; color: #e6e9f0; font-size: 23px; font-weight: 500; }
  .tagline { margin-top: 10px; color: #8b93a7; font-size: 16px; }
  /* The reason this card exists: the four numbers, above the fold of a
     Slack unfurl, before anyone has clicked anything. */
  .metrics {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 18px;
    margin-top: 28px;
    padding-top: 24px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
  }
  .value { color: #5eead4; font-size: 28px; font-weight: 700; line-height: 1.1; }
  /* A step brighter than the site's label tone: a Slack unfurl renders
     this card at roughly half size, where #4b5468 stops being legible. */
  .label {
    margin-top: 8px;
    color: #8b93a7;
    font-size: 13px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
  }
  .prompt {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-top: 30px;
    color: #e6e9f0;
    font-size: 22px;
  }
  .caret { color: #5eead4; font-weight: 700; }
  .cursor {
    width: 11px;
    height: 24px;
    margin-left: 6px;
    background: #5eead4;
  }
</style>
</head>
<body>
  <div class="glow"></div>
  <div class="grid"></div>
  <img class="logo" src="data:image/png;base64,$logo" alt="">
  <div class="window">
    <div class="titlebar">
      <div class="dot"></div><div class="dot"></div><div class="dot"></div>
      <div class="title">morgan@personal <span>&mdash; zsh</span></div>
    </div>
    <div class="body">
      <h1>${_escape(Profile.name)}</h1>
      <div class="role">${_escape(Profile.role)} &mdash; Dart &amp; Flutter</div>
      <div class="tagline">${_escape(Profile.tagline)}</div>
      <div class="metrics">
$metrics
      </div>
      <div class="prompt">
        <span class="caret">&gt;</span>
        <span>mrgnhnt.com</span>
        <span class="cursor"></span>
      </div>
    </div>
  </div>
</body>
</html>
''';
}

String _escape(String value) =>
    value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
