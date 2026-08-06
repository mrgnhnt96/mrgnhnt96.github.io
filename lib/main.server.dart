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
  runApp(Document(
    title: 'Morgan Hunt — Staff Software Engineer',
    meta: {
      'description':
          'Personal site of Morgan Hunt, a Staff Software Engineer building tools for the Dart & Flutter ecosystem.',
      'theme-color': '#07080c',
    },
    head: [
      link(rel: 'icon', href: '/favicon.ico', type: 'image/x-icon'),
      link(rel: 'icon', href: '/favicon-32x32.png', type: 'image/png', attributes: {'sizes': '32x32'}),
      link(rel: 'icon', href: '/favicon-16x16.png', type: 'image/png', attributes: {'sizes': '16x16'}),
      link(rel: 'apple-touch-icon', href: '/apple-touch-icon.png', attributes: {'sizes': '180x180'}),

      // Open Graph / Twitter card — controls how link previews render in
      // Messages, Slack, social apps, etc. Without og:image, previews fall
      // back to a bare title + tiny favicon.
      meta(attributes: {'property': 'og:type'}, content: 'website'),
      meta(attributes: {'property': 'og:url'}, content: 'https://mrgnhnt.com/'),
      meta(attributes: {'property': 'og:site_name'}, content: 'Morgan Hunt'),
      meta(attributes: {'property': 'og:title'}, content: 'Morgan Hunt — Staff Software Engineer'),
      meta(
        attributes: {'property': 'og:description'},
        content: "Building the Dart ecosystem's missing tools — one framework at a time.",
      ),
      meta(attributes: {'property': 'og:image'}, content: 'https://mrgnhnt.com/og-image.png'),
      meta(attributes: {'property': 'og:image:width'}, content: '1200'),
      meta(attributes: {'property': 'og:image:height'}, content: '630'),
      meta(attributes: {'property': 'og:image:alt'}, content: 'Morgan Hunt — Staff Software Engineer'),
      meta(attributes: {'name': 'twitter:card'}, content: 'summary_large_image'),
      meta(attributes: {'name': 'twitter:title'}, content: 'Morgan Hunt — Staff Software Engineer'),
      meta(
        attributes: {'name': 'twitter:description'},
        content: "Building the Dart ecosystem's missing tools — one framework at a time.",
      ),
      meta(attributes: {'name': 'twitter:image'}, content: 'https://mrgnhnt.com/og-image.png'),
    ],
    styles: [
      css.import('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;700&display=swap'),
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
  ));
}
