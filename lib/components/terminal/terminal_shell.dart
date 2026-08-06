import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../../theme.dart';
import 'command_registry.dart';
import 'output_line.dart';

class _Entry {
  const _Entry({required this.content, required this.delayMs, required this.keyId});

  final Component content;
  final int delayMs;
  final int keyId;
}

/// The interactive terminal panel: boot lines, scrolling history, and a
/// live prompt. Nested under the page's `@client` root — doesn't need its
/// own `@client` annotation.
class TerminalShell extends StatefulComponent {
  const TerminalShell({required this.onModeChange, super.key});

  final void Function(TerminalMode mode) onModeChange;

  @override
  State<TerminalShell> createState() => TerminalShellState();
}

class TerminalShellState extends State<TerminalShell> {
  final List<_Entry> _entries = [];
  final List<String> _commandHistory = [];
  final GlobalNodeKey<web.HTMLInputElement> _inputKey = GlobalNodeKey();

  int _historyIndex = 0;
  int _nextKeyId = 0;
  String _draft = '';

  @override
  void initState() {
    super.initState();
    _seedBoot();
    if (kIsWeb) {
      Future.microtask(() => _inputKey.currentNode?.focus());
    }
  }

  void _seedBoot() {
    const lines = [
      'Morgan Hunt — Staff Software Engineer',
      'Dart & Flutter ecosystem tooling · Mesa, AZ',
      "Type 'help' to look around — or just use the toggle up top.",
    ];
    for (var i = 0; i < lines.length; i++) {
      _entries.add(
        _Entry(content: p(classes: 'term-boot', [.text(lines[i])]), delayMs: i * 110, keyId: _nextKeyId++),
      );
    }
  }

  void _append(Component content, int delayMs) {
    _entries.add(_Entry(content: content, delayMs: delayMs, keyId: _nextKeyId++));
  }

  Component _echo(String text) => div(classes: 'term-line-cmd', [
    span(classes: 'terminal__prompt-glyph', [.text('❯')]),
    span([.text(text)]),
  ]);

  void _submit() {
    final trimmed = _draft.trim();
    setState(() => _draft = '');
    if (trimmed.isEmpty) return;

    _commandHistory.add(trimmed);
    _historyIndex = _commandHistory.length;

    if (trimmed.toLowerCase() == 'clear') {
      setState(_entries.clear);
      return;
    }

    final tokens = tokenize(trimmed);
    final name = tokens.first.toLowerCase();
    final args = tokens.skip(1).toList();
    final cmd = findCommand(name);
    final actions = TerminalActions(clear: () => setState(_entries.clear), setMode: component.onModeChange);
    final outputs = cmd != null ? cmd.handler(args, actions) : notFoundOutput(name);

    setState(() {
      _append(_echo(trimmed), 0);
      for (var i = 0; i < outputs.length; i++) {
        _append(outputs[i], (i + 1) * 45);
      }
    });
  }

  void _historyUp() {
    if (_commandHistory.isEmpty) return;
    setState(() {
      _historyIndex = (_historyIndex - 1).clamp(0, _commandHistory.length - 1);
      _draft = _commandHistory[_historyIndex];
    });
  }

  void _historyDown() {
    if (_commandHistory.isEmpty) return;
    setState(() {
      _historyIndex = (_historyIndex + 1).clamp(0, _commandHistory.length);
      _draft = _historyIndex >= _commandHistory.length ? '' : _commandHistory[_historyIndex];
    });
  }

  void _handleKeyDown(web.Event event) {
    final e = event as web.KeyboardEvent;
    switch (e.key) {
      case 'Enter':
        e.preventDefault();
        _submit();
        break;
      case 'ArrowUp':
        e.preventDefault();
        _historyUp();
        break;
      case 'ArrowDown':
        e.preventDefault();
        _historyDown();
        break;
    }
  }

  void _focusInput(web.Event event) {
    if (kIsWeb) _inputKey.currentNode?.focus();
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'terminal', events: {'click': _focusInput}, [
      div(classes: 'terminal__titlebar', [
        div(classes: 'terminal__dots', [span([]), span([]), span([])]),
        span(classes: 'terminal__title', [.text('morgan@personal — zsh')]),
      ]),
      div(classes: 'terminal__body', [
        for (final entry in _entries)
          OutputLine(key: ValueKey(entry.keyId), delayMs: entry.delayMs, child: entry.content),
        div(classes: 'terminal__prompt-row', [
          span(classes: 'terminal__prompt-glyph', [.text('❯')]),
          input<String>(
            key: _inputKey,
            type: .text,
            value: _draft,
            onInput: (v) => setState(() => _draft = v),
            events: {'keydown': _handleKeyDown},
            classes: 'terminal__input',
            attributes: {
              'autocomplete': 'off',
              'autocapitalize': 'off',
              'spellcheck': 'false',
              'aria-label': 'terminal input',
            },
          ),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.terminal', [
      css('&').styles(
        width: 100.percent,
        maxWidth: 720.px,
        maxHeight: 78.vh,
        padding: .zero,
        boxSizing: .borderBox,
        border: .all(color: borderSubtle, width: 1.px),
        radius: .all(.circular(14.px)),
        overflow: .hidden,
        shadow: BoxShadow(offsetX: .zero, offsetY: 20.px, blur: 60.px, spread: .zero, color: .rgba(0, 0, 0, 0.45)),
        backdropFilter: .blur(18.px),
        cursor: .text,
        fontFamily: fontStack,
        backgroundColor: bgPanel,
      ),
      css('&__titlebar').styles(
        display: .flex,
        padding: .symmetric(horizontal: 1.rem, vertical: 0.75.rem),
        border: .only(bottom: BorderSide.solid(color: borderSubtle, width: 1.px)),
        alignItems: .center,
        gap: Gap(column: 0.75.rem),
      ),
      css('&__dots').styles(display: .flex, gap: Gap(column: 6.px)),
      css('&__dots span').styles(
        width: 11.px,
        height: 11.px,
        radius: .all(.circular(50.percent)),
        backgroundColor: .rgba(255, 255, 255, 0.15),
      ),
      css('&__title').styles(color: textDim, fontSize: 0.8.rem),
      css('&__body').styles(
        display: .flex,
        maxHeight: 60.vh,
        padding: .all(1.25.rem),
        overflow: .only(y: .auto),
        flexDirection: .column,
        gap: Gap(row: 0.65.rem),
        color: textPrimary,
        fontSize: 0.92.rem,
        lineHeight: 1.55.em,
      ),
      css('&__prompt-row').styles(display: .flex, alignItems: .center, gap: Gap(column: 0.6.rem)),
      css('&__prompt-glyph').styles(color: accentCyan, fontWeight: .w700),
      css('&__input', [
        css('&').styles(
          padding: .zero,
          border: Border.none,
          flex: .grow(1),
          color: textPrimary,
          fontFamily: fontStack,
          fontSize: 0.92.rem,
          backgroundColor: Colors.transparent,
          raw: {'outline': 'none', 'caret-color': '#5eead4'},
        ),
      ]),
    ]),
    // Output typography, shared by command_registry.dart output builders.
    css('.term-line').styles(raw: {'overflow-wrap': 'break-word'}),
    css('.term-line-cmd').styles(display: .flex, gap: Gap(column: 0.6.rem), color: textPrimary),
    css('.term-boot').styles(margin: .zero, color: accentCyan),
    css('.term-strong').styles(margin: .zero, color: textPrimary, fontWeight: .w700),
    css('.term-muted').styles(margin: .zero, color: textMuted),
    css('.term-accent').styles(margin: .zero, color: accentCyan),
    css('.term-accent-amber').styles(color: accentAmber),
    css('.term-error').styles(margin: .zero, color: accentDanger),
    css('.term-link', [
      css('&').styles(
        color: accentCyan,
        textDecoration: TextDecoration(line: .underline, color: .rgba(94, 234, 212, 0.35)),
      ),
      css('&:hover').styles(color: textPrimary),
    ]),
    css('.term-block').styles(margin: .only(top: 0.5.rem, bottom: 0.5.rem)),
    css('.term-list').styles(padding: .only(left: 1.1.rem), margin: .only(top: 0.35.rem), color: textMuted),
    css('.term-list li').styles(margin: .only(bottom: 0.25.rem)),
    css('.term-ls-row').styles(
      display: .flex,
      flexWrap: .wrap,
      alignItems: .baseline,
      gap: Gap(column: 0.75.rem),
    ),
    css('.term-help-list').styles(
      display: .flex,
      margin: .only(top: 0.4.rem, bottom: 0.4.rem),
      flexDirection: .column,
      gap: Gap(row: 0.3.rem),
    ),
    css('.term-help-row', [
      css('&').styles(display: .flex, flexWrap: .wrap, gap: Gap(column: 1.rem)),
      css('& > span:first-child').styles(minWidth: 6.rem),
    ]),
    css.media(MediaQuery.screen(maxWidth: 640.px), [
      css('.terminal').styles(maxHeight: 82.vh, radius: .all(.circular(0.px))),
      css('.terminal__body').styles(padding: .all(0.9.rem), fontSize: 0.85.rem),
    ]),
  ];
}
