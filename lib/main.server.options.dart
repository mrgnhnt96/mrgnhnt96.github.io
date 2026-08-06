// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:site/components/terminal/output_line.dart' as _output_line;
import 'package:site/components/terminal/terminal_shell.dart'
    as _terminal_shell;
import 'package:site/components/ambient_background.dart' as _ambient_background;
import 'package:site/components/human_mode_content.dart' as _human_mode_content;
import 'package:site/pages/home.dart' as _home;
import 'package:site/pages/resume.dart' as _resume;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {_home.Home: ClientTarget<_home.Home>('home')},
  styles: () => [
    ..._output_line.outputLineStyles,
    ..._ambient_background.AmbientBackground.styles,
    ..._human_mode_content.HumanModeContent.styles,
    ..._terminal_shell.TerminalShellState.styles,
    ..._home.HomeState.styles,
    ..._home.ModeToggle.styles,
    ..._resume.ResumePage.styles,
  ],
);
