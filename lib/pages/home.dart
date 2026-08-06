import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/ambient_background.dart';
import '../components/human_mode_content.dart';
import '../components/terminal/command_registry.dart';
import '../components/terminal/terminal_shell.dart';
import '../theme.dart';

@client
class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  var _mode = TerminalMode.terminal;

  void _setMode(TerminalMode mode) {
    if (mode == _mode) return;
    setState(() => _mode = mode);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'home', [
      const AmbientBackground(),
      ModeToggle(mode: _mode, onToggle: _setMode),
      div(classes: 'home__stage', [
        if (_mode == TerminalMode.terminal)
          div(key: const ValueKey('terminal-pane'), classes: 'home__pane', [TerminalShell(onModeChange: _setMode)])
        else
          div(key: const ValueKey('human-pane'), classes: 'home__pane', [const HumanModeContent()]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.home', [
      css('&').styles(
        display: .flex,
        position: .relative(),
        minHeight: 100.vh,
        padding: .symmetric(vertical: 2.rem, horizontal: 1.rem),
        boxSizing: .borderBox,
        justifyContent: .center,
        alignItems: .center,
      ),
      css('&__stage').styles(display: .flex, width: 100.percent, justifyContent: .center),
      css('&__pane', [
        css('&').styles(
          display: .flex,
          position: .relative(),
          width: 100.percent,
          animation: Animation(name: 'pane-in', duration: durSlow, curve: curveSnappy, fillMode: .both),
          justifyContent: .center,
        ),
      ]),
    ]),
    css.keyframes('pane-in', {
      '0%': Styles(opacity: 0, transform: .combine([.translate(y: 10.px), .scale(0.98)])),
      '100%': Styles(opacity: 1, transform: .combine([.translate(y: 0.px), .scale(1)])),
    }),
  ];
}

class ModeToggle extends StatelessComponent {
  const ModeToggle({required this.mode, required this.onToggle});

  final TerminalMode mode;
  final void Function(TerminalMode mode) onToggle;

  @override
  Component build(BuildContext context) {
    final isTerminal = mode == TerminalMode.terminal;
    return button(
      classes: 'mode-toggle',
      onClick: () => onToggle(isTerminal ? TerminalMode.human : TerminalMode.terminal),
      [
        span(classes: isTerminal ? 'mode-toggle__seg mode-toggle__seg--active' : 'mode-toggle__seg', [
          .text('Terminal'),
        ]),
        span(classes: !isTerminal ? 'mode-toggle__seg mode-toggle__seg--active' : 'mode-toggle__seg', [
          .text('Human'),
        ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.mode-toggle', [
      css('&').styles(
        display: .flex,
        position: .fixed(top: 1.25.rem, right: 1.25.rem),
        zIndex: ZIndex(10),
        padding: .all(3.px),
        border: .all(color: borderSubtle, width: 1.px),
        radius: .all(.circular(999.px)),
        backdropFilter: .blur(12.px),
        cursor: .pointer,
        gap: Gap(column: 2.px),
        fontFamily: fontStack,
        backgroundColor: bgPanel,
        raw: {'appearance': 'none'},
      ),
      css('&__seg', [
        css('&').styles(
          padding: .symmetric(horizontal: 0.85.rem, vertical: 0.4.rem),
          radius: .all(.circular(999.px)),
          transition: Transition.combine([
            Transition('color', duration: durFast),
            Transition('background-color', duration: durFast),
          ]),
          color: textMuted,
          fontSize: 0.78.rem,
        ),
        css('&--active').styles(color: bgVoid, backgroundColor: accentCyan),
      ]),
    ]),
  ];
}
