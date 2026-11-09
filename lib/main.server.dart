/// The entrypoint for the **server** environment.
///
/// The [main] method will only be executed on the server during pre-rendering.
/// To run code on the client, check the `main.client.dart` file.
library;

import 'package:jaspr/dom.dart';
// Server-specific Jaspr import.
import 'package:jaspr/server.dart';

// Imports the [App] component.
import 'app.dart';
import 'data/code_stats.dart';
import 'data/pub_stats.dart';
import 'theme.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'main.server.options.dart';

void main() {
  // Initializes the server environment with the generated default options.
  Jaspr.initializeApp(
    options: defaultServerOptions,
  );

  // Starts the app.
  //
  // [Document] renders the root document structure (<html>, <head> and <body>)
  // with the provided parameters and components.
  runApp(
    Document(
      title: 'Morgan Hunt — Staff Software Engineer',
      // resizes-content makes the visual viewport (and dvh) actually shrink
      // when the on-screen keyboard opens, instead of Safari panning the page
      // to keep the focused input clear of the keyboard — which is what was
      // causing the whole page to "scroll" and reveal dead space on mobile.
      viewport: 'width=device-width, initial-scale=1.0, interactive-widget=resizes-content',
      lang: 'en',
      meta: {
        // The per-page `description` lives on each route in `app.dart`, so
        // the résumé gets its own search snippet instead of the home page's.
        'theme-color': '#07080c',
      },
      head: [
        link(rel: 'icon', href: '/favicon.ico', type: 'image/x-icon'),
        link(rel: 'icon', href: '/favicon-32x32.png', type: 'image/png', attributes: {'sizes': '32x32'}),
        link(rel: 'icon', href: '/favicon-16x16.png', type: 'image/png', attributes: {'sizes': '16x16'}),
        link(rel: 'apple-touch-icon', href: '/apple-touch-icon.png', attributes: {'sizes': '180x180'}),

        // Self-hosted rather than a Google Fonts `@import`: the import was a
        // render-blocking chain of two extra origins before first paint. One
        // variable file covers every weight the site uses (400-700).
        link(
          rel: 'preload',
          href: monoFontUrl,
          attributes: {'as': 'font', 'type': 'font/woff2', 'crossorigin': ''},
        ),

        // Open Graph / Twitter card — controls how link previews render in
        // Messages, Slack, social apps, etc. Without og:image, previews fall
        // back to a bare title + tiny favicon.
        // `og:url` and `rel=canonical` are per-route and live in `app.dart` —
        // a second copy here would win on every page, since scrapers read the
        // first matching tag and the shared head renders first.
        meta(attributes: {'property': 'og:type'}, content: 'website'),
        meta(attributes: {'property': 'og:site_name'}, content: 'Morgan Hunt'),
        meta(attributes: {'property': 'og:title'}, content: 'Morgan Hunt — Staff Software Engineer'),
        meta(
          attributes: {'property': 'og:description'},
          content:
              'A 1.3M-line Flutter app serving 25M+ users. A team of 9. '
              '$pubPackageCount Dart packages, ${compactCount(pubDownloads30Days)} downloads a month.',
        ),
        meta(attributes: {'property': 'og:image'}, content: 'https://mrgnhnt.com/og-image.png'),
        meta(attributes: {'property': 'og:image:width'}, content: '1200'),
        meta(attributes: {'property': 'og:image:height'}, content: '630'),
        // Mirrors what the card actually shows — it's generated from the same
        // headline metrics by `tool/og_image.dart`, so the alt text carries
        // the numbers too rather than describing a blank nameplate.
        meta(
          attributes: {'property': 'og:image:alt'},
          content:
              'Morgan Hunt — Staff Software Engineer. 25M+ users reached, '
              '${compactCount(pubDownloads30Days)} package downloads a month, \$1M+ annual revenue, '
              '${compactCount(totalCodeLines)} lines written.',
        ),
        meta(attributes: {'name': 'twitter:card'}, content: 'summary_large_image'),
        meta(attributes: {'name': 'twitter:title'}, content: 'Morgan Hunt — Staff Software Engineer'),
        meta(
          attributes: {'name': 'twitter:description'},
          content:
              'A 1.3M-line Flutter app serving 25M+ users. A team of 9. '
              '$pubPackageCount Dart packages, ${compactCount(pubDownloads30Days)} downloads a month.',
        ),
        meta(attributes: {'name': 'twitter:image'}, content: 'https://mrgnhnt.com/og-image.png'),
      ],
      styles: [
        const _MonoFontFace(),
        css('html, body').styles(
          width: 100.percent,
          minHeight: 100.vh,
          padding: .zero,
          margin: .zero,
          color: textPrimary,
          fontFamily: fontStack,
          backgroundColor: bgVoid,
        ),
        css('*').styles(boxSizing: .borderBox),
        css('a').styles(color: .inherit),
      ],
      body: App(),
    ),
  );
}

/// `@font-face` for the self-hosted JetBrains Mono. Jaspr's own
/// `css.fontFace` can't express `font-weight` ranges or `font-display`, both
/// of which this needs: the range so 500 and 700 come from the one variable
/// file, and `swap` so text paints in the fallback mono while it loads.
class _MonoFontFace implements StyleRule {
  const _MonoFontFace();

  @override
  String toCss([String indent = '']) =>
      '$indent@font-face { font-family: "JetBrains Mono"; font-style: normal; font-weight: 400 700; '
      "font-display: swap; src: url($monoFontUrl) format('woff2'); "
      'unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, '
      'U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD; }';
}
