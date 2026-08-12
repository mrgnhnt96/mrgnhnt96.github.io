import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../components/ambient_background.dart';
import '../components/human_mode_content.dart';
import '../components/metrics_band.dart';
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

  // The pane's entrance animation used to trigger from plain CSS (present
  // the instant '.home__pane' rendered), which plays immediately on the
  // SSR-painted HTML before any JS loads — but hydration taking over
  // sometimes restarts that same CSS animation a beat later on the very
  // same DOM node, which showed up as a visible double entrance. Since it's
  // the exact same node, there's no way to tell "the real one" from "the
  // restart" after the fact.
  //
  // So instead this renders with the animation class absent (matching on
  // both server and initial client build, for a clean hydration with
  // nothing to restart), then adds it itself, once, right after mount —
  // there's now only ever one trigger, and it's ours.
  bool _paneRevealed = false;

  @override
  void initState() {
    super.initState();
    _syncScrollLock();
    _revealPane();
  }

  @override
  void dispose() {
    if (kIsWeb) web.document.documentElement?.classList.remove('scroll-locked');
    super.dispose();
  }

  void _revealPane() {
    if (!kIsWeb) return;
    Future.microtask(() {
      if (mounted) setState(() => _paneRevealed = true);
    });
  }

  void _setMode(TerminalMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _paneRevealed = false;
    });
    _revealPane();
    _syncScrollLock();
  }

  // Locks scrolling on <html>/<body> themselves while the terminal is
  // showing — not just the '.home' div. Without this, the document root
  // stays the scrollable ancestor mobile Safari reaches for when it scrolls
  // a focused input clear of the keyboard, which reveals dead space below
  // the terminal panel. This has to run as a DOM side effect since it
  // reaches outside this component's own subtree. Human mode removes the
  // lock so its longer content can scroll normally.
  //
  // Touch-only: this is purely a workaround for the mobile keyboard-avoidance
  // behavior above. Desktop never had that problem, and locking there too
  // just removes the normal page-scroll fallback for no reason.
  void _syncScrollLock() {
    if (!kIsWeb) return;
    final root = web.document.documentElement?.classList;
    final isTouch = web.window.matchMedia('(pointer: coarse)').matches;
    if (_mode == TerminalMode.terminal && isTouch) {
      root?.add('scroll-locked');
    } else {
      root?.remove('scroll-locked');
    }
  }

  @override
  Component build(BuildContext context) {
    // Locked to the viewport (no document-level scroll) while the terminal
    // is showing — mobile Safari otherwise reveals dead space by scrolling
    // the whole page to keep the focused input clear of the keyboard, since
    // 100dvh doesn't itself shrink for the keyboard. Locking here forces any
    // keyboard-avoidance scroll to happen inside the terminal's own scroll
    // region instead. Human mode needs to scroll normally, so it opts out.
    final classes = _mode == TerminalMode.terminal ? 'home home--locked' : 'home';
    final paneClasses = _paneRevealed ? 'home__pane home__pane--in' : 'home__pane';
    return div(classes: classes, [
      const AmbientBackground(),
      ModeToggle(mode: _mode, onToggle: _setMode),
      // Terminal mode only — human mode renders its own hero and a fuller
      // metrics grid, so showing the band there would just say it twice.
      if (_mode == TerminalMode.terminal) const MetricsBand(),
      div(classes: 'home__stage', [
        if (_mode == TerminalMode.terminal)
          div(key: const ValueKey('terminal-pane'), classes: paneClasses, [
            TerminalShell(onModeChange: _setMode),
          ])
        else
          div(key: const ValueKey('human-pane'), classes: paneClasses, [const HumanModeContent()]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('html.scroll-locked, body.scroll-locked').styles(
      height: Unit.expression('100dvh'),
      overflow: .hidden,
    ),
    css('.home', [
      css('&').styles(
        display: .flex,
        position: .relative(),
        // dvh so the page doesn't reflow as mobile browser chrome
        // collapses/expands on scroll.
        minHeight: Unit.expression('100dvh'),
        padding: .symmetric(vertical: 2.rem, horizontal: 1.rem),
        boxSizing: .borderBox,
        // Column, so the metrics band can stack above the stage. Centering
        // still reads the same: 'align' now centers horizontally and
        // 'justify' vertically, which is what both were doing before.
        flexDirection: .column,
        justifyContent: .center,
        alignItems: .center,
      ),
      // Deliberately *not* flex-grow on desktop: the stage shrink-wraps the
      // terminal so '.home' can center the band-plus-terminal group as one
      // block. Growing here would pin the group to the top and leave the
      // slack below it. Mobile overrides this (see the media query), where
      // the terminal does want every pixel the band leaves.
      css('&__stage').styles(
        display: .flex,
        width: 100.percent,
        justifyContent: .center,
      ),
      css('&__pane', [
        css('&').styles(
          display: .flex,
          position: .relative(),
          width: 100.percent,
          // Fills the stage so the mobile terminal can size itself to '100%'
          // of the space left over after the band, rather than hard-coding
          // the band's height into its own 'dvh' math.
          height: 100.percent,
          justifyContent: .center,
          // Sit in the animation's 0% pose by default (see '_paneRevealed')
          // so adding '&--in' has something to animate *from* instead of a
          // jump-cut. Overridden below for non-scripting contexts, so a
          // pane that'll never get JS-revealed isn't stuck invisible.
          opacity: 0,
          transform: .combine([.translate(y: 10.px), .scale(0.98)]),
        ),
        css('&--in').styles(
          animation: Animation(name: 'pane-in', duration: durSlow, curve: curveSnappy, fillMode: .both),
        ),
      ]),
    ]),
    css.keyframes('pane-in', {
      '0%': Styles(opacity: 0, transform: .combine([.translate(y: 10.px), .scale(0.98)])),
      '100%': Styles(opacity: 1, transform: .combine([.translate(y: 0.px), .scale(1)])),
    }),
    // '_paneRevealed' is what plays the entrance animation — deliberately
    // client-triggered, once, well after mount (see its comment for why).
    // That means a pane that never gets hydrated (JS disabled/blocked)
    // would otherwise sit permanently invisible, so force it visible
    // whenever scripting isn't actually available.
    css.media(MediaQuery.raw('(scripting: none)'), [
      css('.home__pane').styles(opacity: 1, transform: .none),
    ]),
    // Give the terminal window as much of the screen as possible — the
    // margins that look intentional on desktop just read as wasted space
    // once the panel is nearly as wide as the viewport anyway.
    css.media(MediaQuery.screen(maxWidth: 640.px), [
      css('.home').styles(
        padding: .symmetric(vertical: 0.5.rem, horizontal: 0.4.rem),
      ),
      // Touch-only lock (see '_syncScrollLock') — desktop keeps normal page
      // scroll as a fallback, since it never had the keyboard-avoidance
      // problem this works around.
      css('.home--locked').styles(height: Unit.expression('100dvh'), overflow: .hidden),
      // Here (unlike desktop) the terminal should claim every pixel the band
      // leaves, so the stage grows and '.terminal' measures its '100%'
      // against it. 'min-height: 0' is required: flex items default to
      // 'min-height: auto' and would otherwise refuse to shrink below their
      // content, overflowing the locked viewport instead of fitting it.
      css('.home__stage').styles(minHeight: 0.px, flex: .grow(1)),
    ]),
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
        raw: {'appearance': 'none', '-webkit-backdrop-filter': 'blur(12px)'},
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
