import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../data/experience.dart';
import '../../data/profile.dart';
import '../../data/projects.dart';

enum TerminalMode { terminal, human }

/// Side effects a command handler can trigger on the shell itself.
class TerminalActions {
  const TerminalActions({required this.clear, required this.setMode});

  final void Function() clear;
  final void Function(TerminalMode mode) setMode;
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

List<Component> _helpOutput(List<String> args, TerminalActions actions) => [
  _muted('Available commands:'),
  div(classes: 'term-help-list', [
    for (final cmd in commands)
      div(classes: 'term-help-row', [
        span(classes: 'term-link', [.text(cmd.name)]),
        span(classes: 'term-muted', [.text(cmd.description)]),
      ]),
    div(classes: 'term-help-row', [
      span(classes: 'term-link', [.text('clear')]),
      span(classes: 'term-muted', [.text('clear the screen')]),
    ]),
  ]),
  _muted("Tip: use the mode toggle up top if typing isn't your thing."),
];

List<Component> _whoamiOutput(List<String> args, TerminalActions actions) => [
  p(classes: 'term-strong', [.text(Profile.name)]),
  _muted('${Profile.role} · ${Profile.location}'),
  p(classes: 'term-accent', [.text(Profile.tagline)]),
  _muted("Type 'about', 'experience', or 'ls projects' to dig in."),
];

List<Component> _aboutOutput(List<String> args, TerminalActions actions) => [
  _line(Profile.summary),
  _muted("Next: 'experience' for the work history, or 'ls projects' for what I've built."),
];

List<Component> _experienceOutput(List<String> args, TerminalActions actions) => [
  for (final job in experience)
    div(classes: 'term-block', [
      p(classes: 'term-strong', [.text('${job.company} — ${job.role}')]),
      _muted(job.period),
      ul(classes: 'term-list', [for (final bullet in job.bullets) li([.text(bullet)])]),
    ]),
  _muted("See 'ls projects' for things I've built on the side, or 'contact' to reach out."),
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
      _muted("run 'ls projects', 'ls tools', or 'ls games' to look inside."),
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
    _muted(hint),
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
      _muted("or type 'human' to read it as a normal page."),
    ];
  }
  return [_error("cat: $target: no such file — try 'cat resume'")];
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
    _link(Profile.linkedin, 'in/mrgnhnt'),
  ]),
  div(classes: 'term-ls-row', [
    span(classes: 'term-muted', [.text('twitter')]),
    _link(Profile.twitter, '@${Profile.twitterHandle}'),
  ]),
  _muted("Or just poke around — 'ls projects', 'experience', 'help'."),
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
];

Command? findCommand(String name) {
  for (final cmd in commands) {
    if (cmd.name == name || cmd.aliases.contains(name)) return cmd;
  }
  return null;
}

List<Component> notFoundOutput(String cmd) => [_error("$cmd: command not found — try 'help'")];
