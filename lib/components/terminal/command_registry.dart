import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../data/experience.dart';
import '../../data/profile.dart';
import '../../data/projects.dart';

enum TerminalMode { terminal, human }

/// Side effects a command handler can trigger on the shell itself.
class TerminalActions {
  const TerminalActions({required this.clear, required this.setMode, required this.runCommand});

  final void Function() clear;
  final void Function(TerminalMode mode) setMode;

  /// Types out and submits [command] as if the user had entered it — used
  /// to make command names in output (e.g. `help`) tappable.
  final void Function(String command) runCommand;
}

typedef CommandHandler = List<Component> Function(List<String> args, TerminalActions actions);

class Command {
  const Command({required this.name, required this.description, required this.handler, this.aliases = const []});

  final String name;
  final String description;
  final List<String> aliases;
  final CommandHandler handler;
}

List<String> tokenize(String input) => input.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

Component _muted(String text) => p(classes: 'term-muted', [.text(text)]);
Component _line(String text) => p([.text(text)]);
Component _link(String href, String label) => a(href: href, target: .blank, classes: 'term-link', [.text(label)]);
Component _error(String text) => p(classes: 'term-error', [.text(text)]);

Component _runnableLink(String name, TerminalActions actions) => span(
  classes: 'term-link',
  events: {
    // Stop this from bubbling to '.terminal's click handler, which focuses
    // the input — these links exist so tapping a command works *without*
    // ever needing the keyboard, so that focus (and the keyboard popping
    // up) is exactly what shouldn't happen here.
    'click': (e) {
      e.stopPropagation();
      actions.runCommand(name);
    },
  },
  [.text(name)],
);

// The negative lookbehind keeps this from treating a contraction's
// apostrophe (e.g. "I've") as an opening quote — it only matches a quote
// that isn't immediately preceded by a letter/digit.
final RegExp _quotedCommandRe = RegExp(r"(?<!\w)'([^']+)'");

/// Splits [text] on single-quoted command references (e.g. "Type 'help' to
/// look around") and makes each one tappable, same as the command names in
/// `help` output. Exposed for [terminal_shell.dart]'s boot lines, which
/// reference commands the same way.
List<Component> linkifyCommands(String text, TerminalActions actions) {
  final parts = <Component>[];
  var last = 0;
  for (final match in _quotedCommandRe.allMatches(text)) {
    if (match.start > last) parts.add(.text(text.substring(last, match.start)));
    parts.add(.text("'"));
    parts.add(_runnableLink(match.group(1)!, actions));
    parts.add(.text("'"));
    last = match.end;
  }
  if (last < text.length) parts.add(.text(text.substring(last)));
  return parts;
}

Component _mutedHint(String text, TerminalActions actions) => p(classes: 'term-muted', linkifyCommands(text, actions));
Component _errorHint(String text, TerminalActions actions) => p(classes: 'term-error', linkifyCommands(text, actions));

List<Component> _helpOutput(List<String> args, TerminalActions actions) => [
  _muted('Available commands:'),
  div(classes: 'term-help-list', [
    for (final cmd in commands)
      div(classes: 'term-help-row', [
        _runnableLink(cmd.name, actions),
        span(classes: 'term-muted', [.text(cmd.description)]),
      ]),
    div(classes: 'term-help-row', [
      _runnableLink('clear', actions),
      span(classes: 'term-muted', [.text('clear the screen')]),
    ]),
  ]),
  _muted("Tip: tap a command above, or use the mode toggle up top if typing isn't your thing."),
];

List<Component> _whoamiOutput(List<String> args, TerminalActions actions) => [
  p(classes: 'term-strong', [.text(Profile.name)]),
  _muted('${Profile.role} · ${Profile.location}'),
  p(classes: 'term-accent', [.text(Profile.tagline)]),
  _mutedHint("Type 'about', 'experience', or 'ls projects' to dig in.", actions),
];

List<Component> _aboutOutput(List<String> args, TerminalActions actions) => [
  _line(Profile.summary),
  _line(Profile.howIWork),
  _mutedHint("Next: 'experience' for the work history, 'ls projects' for what I've built, or 'zelda' for a fact.", actions),
];

List<Component> _zeldaOutput(List<String> args, TerminalActions actions) => [
  p(classes: 'term-accent', [.text(Profile.zeldaFact)]),
];

List<Component> _experienceOutput(List<String> args, TerminalActions actions) => [
  for (final job in experience)
    div(classes: 'term-block', [
      p(classes: 'term-strong', [.text('${job.company} — ${job.role}')]),
      _muted(job.period),
      ul(classes: 'term-list', [for (final bullet in job.bullets) li([.text(bullet)])]),
    ]),
  _mutedHint("See 'ls projects' for things I've built on the side, or 'contact' to reach out.", actions),
];

List<Component> _lsOutput(List<String> args, TerminalActions actions) {
  final category = args.isEmpty ? null : args.first.toLowerCase();
  final categories = switch (category) {
    'projects' => [ProjectCategory.flagship],
    'tools' => [ProjectCategory.tool],
    'games' => [ProjectCategory.game],
    null => [ProjectCategory.flagship, ProjectCategory.tool, ProjectCategory.game],
    _ => null,
  };

  if (categories == null) {
    return [_error("ls: unknown target '$category' — try 'ls', 'ls projects', 'ls tools', or 'ls games'")];
  }

  if (category == null) {
    return [
      _muted('projects/  tools/  games/'),
      _mutedHint("run 'ls projects', 'ls tools', or 'ls games' to look inside.", actions),
    ];
  }

  final entries = projectsByCategory(categories.first);
  final hint = switch (category) {
    'projects' => "Try 'cat resume' for the short version, or 'contact' to reach out.",
    'tools' => "Back to 'ls projects' for the bigger stuff, or 'contact' to reach out.",
    'games' => "Yes, I have a problem. Try 'ls projects' for the serious stuff.",
    _ => "Try 'contact' to reach out.",
  };
  return [
    for (final entry in entries)
      div(classes: 'term-ls-row', [
        span(classes: 'term-link', [.text('${entry.name}/')]),
        span(classes: 'term-muted', [.text(entry.description)]),
        if (entry.stars != null) span(classes: 'term-accent-amber', [.text('★ ${entry.stars}')]),
      ]),
    _mutedHint(hint, actions),
  ];
}

List<Component> _catOutput(List<String> args, TerminalActions actions) {
  final target = args.isEmpty ? '' : args.first.toLowerCase();
  if (target.contains('resume')) {
    return [
      _line(Profile.summary),
      div(classes: 'term-block', [
        a(href: '/resume.pdf', download: 'Morgan-Hunt-Resume.pdf', classes: 'term-link', [
          .text('⭳ download resume.pdf'),
        ]),
      ]),
      _mutedHint("or type 'human' to read it as a normal page.", actions),
    ];
  }
  return [_errorHint("cat: $target: no such file — try 'cat resume'", actions)];
}

List<Component> _contactOutput(List<String> args, TerminalActions actions) => [
  div(classes: 'term-ls-row', [
    span(classes: 'term-muted', [.text('email')]),
    _link('mailto:${Profile.email}', Profile.email),
  ]),
  div(classes: 'term-ls-row', [
    span(classes: 'term-muted', [.text('github')]),
    _link(Profile.github, '@${Profile.githubHandle}'),
  ]),
  div(classes: 'term-ls-row', [
    span(classes: 'term-muted', [.text('linkedin')]),
    _link(Profile.linkedin, 'in/mrgnhnt96'),
  ]),
  div(classes: 'term-ls-row', [
    span(classes: 'term-muted', [.text('twitter')]),
    _link(Profile.twitter, '@${Profile.twitterHandle}'),
  ]),
  _mutedHint("Or just poke around — 'ls projects', 'experience', 'help'.", actions),
];

List<Component> _sudoOutput(List<String> args, TerminalActions actions) {
  if (args.join(' ').toLowerCase() == 'make me a sandwich') {
    return [p(classes: 'term-accent', [.text('Okay.')])];
  }
  return [_error('Permission denied. (nice try, though)')];
}

final commands = <Command>[
  Command(name: 'help', description: 'list available commands', handler: _helpOutput),
  Command(name: 'whoami', description: 'who is this, anyway', handler: _whoamiOutput),
  Command(name: 'about', description: 'the longer story', handler: _aboutOutput),
  Command(name: 'experience', description: 'work history', handler: _experienceOutput),
  Command(name: 'ls', description: "list 'projects', 'tools', or 'games'", handler: _lsOutput),
  Command(name: 'cat', description: 'read a file, e.g. cat resume', handler: _catOutput),
  Command(name: 'contact', description: 'how to reach me', handler: _contactOutput),
  Command(
    name: 'human',
    description: 'switch to human mode',
    aliases: ['mode', 'theme'],
    handler: (args, actions) {
      actions.setMode(TerminalMode.human);
      return [_muted('Switching to human-readable mode…')];
    },
  ),
  Command(
    name: 'terminal',
    description: 'switch back to the terminal',
    handler: (args, actions) {
      actions.setMode(TerminalMode.terminal);
      return [_muted('Back to the shell.')];
    },
  ),
  Command(name: 'sudo', description: 'try it', handler: _sudoOutput),
  Command(name: 'zelda', description: "you'll see", handler: _zeldaOutput),
];

Command? findCommand(String name) {
  for (final cmd in commands) {
    if (cmd.name == name || cmd.aliases.contains(name)) return cmd;
  }
  return null;
}

List<Component> notFoundOutput(String cmd, TerminalActions actions) => [
  _errorHint("$cmd: command not found — try 'help'", actions),
];
