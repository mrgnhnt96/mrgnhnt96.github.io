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
