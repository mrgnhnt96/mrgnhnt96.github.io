import 'dart:math';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../data/experience.dart';
import '../../data/metrics.dart';
import '../../data/profile.dart';
import '../../data/projects.dart';

final _random = Random();

T _pick<T>(List<T> options) => options[_random.nextInt(options.length)];

enum TerminalMode { terminal, human }

/// Side effects a command handler can trigger on the shell itself.
class TerminalActions {
  const TerminalActions({
    required this.clear,
    required this.setMode,
    required this.runCommand,
    required this.openUrl,
    required this.queuePunchline,
  });

  final void Function() clear;
  final void Function(TerminalMode mode) setMode;

  /// Types out and submits [command] as if the user had entered it — used
  /// to make command names in output (e.g. `help`) tappable.
  final void Function(String command) runCommand;

  /// Opens [url] in a new tab — used by the `open` command.
  final void Function(String url) openUrl;

  /// Holds [punchline] until the next bare Enter press reveals it — used by
  /// the `jokes` command's setup/punchline delivery.
  final void Function(String punchline) queuePunchline;
}

Component punchlineOutput(String text) => p(classes: 'term-accent', [.text(text)]);

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

Component _runnableLink(String label, TerminalActions actions, {String? runs}) => span(
  classes: 'term-link',
  events: {
    // Stop this from bubbling to '.terminal's click handler, which focuses
    // the input — these links exist so tapping a command works *without*
    // ever needing the keyboard, so that focus (and the keyboard popping
    // up) is exactly what shouldn't happen here.
    'click': (e) {
      e.stopPropagation();
      actions.runCommand(runs ?? label);
    },
  },
  [.text(label)],
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
  _mutedHint("Type 'metrics', 'about', 'experience', or 'ls projects' to dig in.", actions),
];

List<Component> _aboutOutput(List<String> args, TerminalActions actions) => [
  _line(Profile.summary),
  _mutedHint(
    "Next: 'metrics' for the numbers, 'experience' for the work history, 'ls projects' for what I've built.",
    actions,
  ),
];

// Not const: the headline and open-source groups interpolate values pulled
// at build time, so they're 'final' rather than compile-time constants.
final _metricSections = {
  'scale': headlineMetrics,
  'impact': impactMetrics,
  'open source': openSourceMetrics,
};

List<Component> _metricsOutput(List<String> args, TerminalActions actions) => [
  for (final MapEntry(key: title, value: metrics) in _metricSections.entries)
    div(classes: 'term-block', [
      p(classes: 'term-accent-violet', [.text('// $title')]),
      for (final metric in metrics)
        div(classes: 'term-metric-row', [
          span(classes: 'term-metric-value', [.text(metric.value)]),
          span(classes: 'term-strong', [.text(metric.label)]),
          if (metric.detail != null) span(classes: 'term-muted', [.text(metric.detail!)]),
        ]),
    ]),
  _mutedHint(
    "Download and contribution counts come straight from the pub.dev and GitHub APIs. "
    "Run 'ls projects' to see what they're counting.",
    actions,
  ),
];

const _gamingLines = [
  Profile.zeldaFact,
  "Two of my projects are secretly named after Zelda lore. See if you can spot it in 'ls projects'.",
  'Ocarina of Time broke my brain as a kid, in the best way. Never really recovered.',
  "High score: most Korok seeds collected before I remembered Hyrule has a main story too.",
  'Ask me about Tears of the Kingdom sometime. I have opinions and very little restraint.',
  "Breath of the Wild is the reason 'just one more shrine' has never once been true.",
  "Majora's Mask is criminally underrated. Fight me.",
  "I've named two backend frameworks after Zelda lore. A therapist might have thoughts.",
  "If Hyrule had a monorepo, I'd already be refactoring it.",
];

List<Component> _gamingOutput(List<String> args, TerminalActions actions) => [
  p(classes: 'term-accent', [.text(_pick(_gamingLines))]),
];

List<Component> _experienceOutput(List<String> args, TerminalActions actions) => [
  for (final job in experience)
    div(classes: 'term-block', [
      p(classes: 'term-strong', [.text('${job.company} — ${job.role}')]),
      _muted(job.period),
      p(classes: 'term-accent-amber', [.text(job.headline)]),
      ul(classes: 'term-list', [
        for (final bullet in job.bullets) li([.text(bullet)]),
      ]),
    ]),
  _mutedHint("See 'ls projects' for things I've built on the side, or 'contact' to reach out.", actions),
];

const _lsFlagJokes = [
  "ls: -a shows hidden files, but the only thing hidden here is my sense of shame about early CSS.",
  "ls: nice try — the only dotfile here is .gitignore, and it's not talking.",
  'ls: hidden files revealed: .fears .imposter_syndrome .that_bug_from_2019',
  "ls: -a isn't supported, but respect for reaching for the real flags.",
  "ls: there's nothing hidden — I put all my secrets in 'about'.",
];

List<Component> _lsOutput(List<String> args, TerminalActions actions) {
  final category = args.isEmpty ? null : args.first.toLowerCase();
  if (category != null && category.startsWith('-')) {
    return [_error(_pick(_lsFlagJokes))];
  }
  final categories = switch (category) {
    'projects' => [ProjectCategory.project],
    'tools' => [ProjectCategory.tool],
    'games' => [ProjectCategory.game],
    null => [ProjectCategory.project, ProjectCategory.tool, ProjectCategory.game],
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

  // Featured entries first, so the two frameworks lead the listing instead of
  // sitting wherever the data file happens to put them.
  final inCategory = projectsByCategory(categories.first);
  final entries = [
    ...inCategory.where((entry) => entry.featured),
    ...inCategory.where((entry) => !entry.featured),
  ];
  final hint = switch (category) {
    'projects' =>
      "Revali and Zonai are the two I've spent years on — run 'info revali' or 'info zonai' for the full story.",
    'tools' => "Back to 'ls projects' for the bigger stuff, or 'contact' to reach out.",
    'games' => "Yes, I have a problem. Try 'ls projects' for the serious stuff.",
    _ => "Try 'contact' to reach out.",
  };
  return [
    for (final entry in entries)
      div(classes: 'term-ls-row', [
        if (entry.link != null)
          _runnableLink('${entry.name}/', actions, runs: 'open ${entry.name}')
        else
          span(classes: 'term-muted', [.text('${entry.name}/')]),
        if (entry.featured) span(classes: 'term-accent-violet', [.text('★ flagship')]),
        span(classes: 'term-muted', [.text(entry.description)]),
        if (entry.stars != null) span(classes: 'term-accent-amber', [.text('★ ${entry.stars}')]),
      ]),
    _mutedHint(hint, actions),
  ];
}

List<Component> _infoOutput(List<String> args, TerminalActions actions) {
  if (args.isEmpty) {
    return [_errorHint("info: missing project name — try 'info revali' or 'info zonai'.", actions)];
  }
  final name = args.first.toLowerCase();
  final entry = _findProject(name);
  if (entry == null) {
    return [_errorHint("info: $name: no such project — try 'ls projects'.", actions)];
  }
  if (entry.highlights.isEmpty) {
    return [
      div(classes: 'term-ls-row', [
        p(classes: 'term-strong', [.text(entry.name)]),
        if (entry.stars != null) span(classes: 'term-accent-amber', [.text('★ ${entry.stars}')]),
      ]),
      _muted(entry.description),
      _mutedHint("Only the flagships have a long version — try 'info revali' or 'info zonai'.", actions),
    ];
  }
  return [
    div(classes: 'term-block', [
      p(classes: 'term-strong', [.text(entry.name)]),
      if (entry.status != null) p(classes: 'term-accent-amber', [.text(entry.status!)]),
      p(classes: 'term-accent', [.text(entry.description)]),
      ul(classes: 'term-list', [
        for (final highlight in entry.highlights) li([.text(highlight)]),
      ]),
      div(classes: 'term-ls-row', [
        if (entry.docsUrl != null) _link(entry.docsUrl!, 'docs: ${entry.docsUrl}'),
        if (entry.link != null) _link(entry.link!, 'source: ${entry.link}'),
      ]),
    ]),
    _mutedHint("Run 'open ${entry.name}' to jump straight to the repo.", actions),
  ];
}

ProjectEntry? _findProject(String name) {
  for (final project in projects) {
    if (project.name == name) return project;
  }
  return null;
}

List<Component> _catOutput(List<String> args, TerminalActions actions) {
  final target = args.isEmpty ? '' : args.first.toLowerCase();
  if (target.contains('resume')) {
    return [
      _line(Profile.summary),
      div(classes: 'term-block', [
        a(href: '/resume.pdf', download: 'Morgan-Hunt-Resume.pdf', classes: 'term-link', [
          .text('↓ download resume.pdf'),
        ]),
      ]),
      _mutedHint("or type 'human' to read it as a normal page.", actions),
    ];
  }
  return [_errorHint("cat: $target: no such file — try 'cat resume'", actions)];
}

List<Component> _openOutput(List<String> args, TerminalActions actions) {
  if (args.isEmpty) {
    return [_errorHint("open: missing project name — try 'ls projects' first.", actions)];
  }
  final name = args.first.toLowerCase();
  final entry = _findProject(name);
  if (entry == null) {
    return [_errorHint("open: $name: no such project — try 'ls projects', 'ls tools', or 'ls games'.", actions)];
  }
  final link = entry.link;
  if (link == null) {
    return [_muted("open: $name has no public repo yet — it's still under wraps.")];
  }
  actions.openUrl(link);
  return [_muted('Opening $link in a new tab…')];
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

class _Joke {
  const _Joke(this.setup, this.punchline);

  final String setup;
  final String punchline;
}

const _dadJokes = <_Joke>[
  _Joke('Why do programmers prefer dark mode?', 'Because light attracts bugs.'),
  _Joke('Why do Java developers wear glasses?', "Because they don't C#."),
  _Joke(
    'There are 10 types of people in this world.',
    "Those who understand binary, and those who don't.",
  ),
  _Joke('Why did the developer go broke?', 'He used up all his cache.'),
  _Joke('A SQL query walks into a bar and sees two tables.', 'Can I join you?'),
  _Joke('Why was the JavaScript developer sad?', "He didn't Node how to Express himself."),
  _Joke('Want to hear a UDP joke?', "Never mind, you might not get it."),
  _Joke("Why is `!false` funny?", "Because it's true."),
  _Joke("Why don't skeletons fight each other?", "They don't have the guts."),
  _Joke("I'm reading a book about anti-gravity.", "It's impossible to put down."),
  _Joke('Why did the scarecrow win an award?', 'He was outstanding in his field.'),
  _Joke('What do you call fake spaghetti?', 'An impasta.'),
  _Joke('I used to hate facial hair.', 'But then it grew on me.'),
  _Joke('Why do programmers hate nature?', 'Too many bugs, not enough documentation.'),
  _Joke('What did the router say to the doctor?', 'It hurts when IP.'),
];

List<Component> _jokesOutput(List<String> args, TerminalActions actions) {
  final joke = _pick(_dadJokes);
  actions.queuePunchline(joke.punchline);
  return [
    p(classes: 'term-accent', [.text(joke.setup)]),
    _muted('(press enter for the punchline)'),
  ];
}

List<Component> _sudoOutput(List<String> args, TerminalActions actions) {
  if (args.join(' ').toLowerCase() == 'make me a sandwich') {
    return [
      p(classes: 'term-accent', [.text('Okay.')]),
    ];
  }
  return [_error('Permission denied. (nice try, though)')];
}

enum _EggStyle { muted, error, accent }

Component _styled(_EggStyle style, String text) => switch (style) {
  _EggStyle.muted => _muted(text),
  _EggStyle.error => _error(text),
  _EggStyle.accent => p(classes: 'term-accent', [.text(text)]),
};

class _Egg {
  const _Egg(this.names, this.responses, {this.style = _EggStyle.muted});

  final List<String> names;
  final List<String> responses;
  final _EggStyle style;
}

/// Hidden joke responses for common shell muscle-memory — deliberately not
/// registered in [commands], so they never show up in `help` or tab
/// completion. Each one picks a random line from its pool so retyping the
/// same command doesn't feel like hitting the same wall twice.
final _easterEggs = <_Egg>[
  _Egg(
    ['grep'],
    [
      "grep: no haystack, no needle — this whole site fits on one page.",
      "grep: 0 matches for 'attention span'. try 'help' instead.",
      "grep: this terminal doesn't have a filesystem, just vibes.",
      'grep: I use ctrl+F like everyone else.',
      'grep: pattern not found — much like a clean regex on the first try.',
    ],
  ),
  _Egg(
    ['touch'],
    [
      "touch: cannot create file — there's no filesystem, just this conversation.",
      "touch: permission denied. some things are better left un-touch'd.",
      'touch grass: now THAT command I can get behind.',
      "touch: file exists — it's called this website, and I already built it.",
      'touch: nothing to create here, only things to read.',
    ],
  ),
  _Egg(
    ['cd'],
    [
      "cd: nowhere to go — you're already exactly where you need to be.",
      "cd: this isn't a filesystem, it's a conversation. try 'help'.",
      "cd ..: relatable, but there's no parent directory here.",
      "cd /: access denied, mostly because '/' doesn't exist in a browser tab.",
      'cd: I got rid of directories years ago. ask me about monorepo tooling sometime.',
    ],
  ),
  _Egg(
    ['pwd'],
    [
      'pwd: you are here. right now. reading this.',
      "pwd: somewhere between 'curious' and 'procrastinating'.",
      'pwd: /home/visitor/probably-should-be-working',
      "pwd: this is a website, not a filesystem — but you're in the terminal panel, if that helps.",
    ],
  ),
  _Egg(
    ['mkdir'],
    [
      'mkdir: permission denied — I already built enough folders for one lifetime.',
      "mkdir: directory not created. this site's flat by design.",
      "mkdir new_career: nice thought, but let's not, not today.",
    ],
  ),
  _Egg(
    ['rm'],
    [
      'rm: not today. this site has feelings.',
      "rm -rf /: absolutely not — I've seen that story end badly enough times.",
      'rm: permission denied. everything here is load-bearing.',
      "rm: nice try. this isn't your monorepo's node_modules.",
      'rm -rf: I like you, but not that much.',
    ],
    style: _EggStyle.error,
  ),
  _Egg(
    ['vim', 'nvim'],
    [
      "vim: you're in. good luck getting out. (:wq, if you're new here.)",
      "vim: opened a file that doesn't exist. classic Tuesday.",
      "vim: entering insert mode... just kidding, there's nothing to insert.",
      ':wq: that one you can actually type in real life. carry on.',
    ],
  ),
  _Egg(
    ['nano'],
    [
      "nano: opened a file that doesn't exist, in an editor that isn't running. ctrl+x to feel something.",
      'nano: respect for skipping the vim exit joke entirely.',
      'nano: saved nothing, changed nothing, felt something.',
    ],
  ),
  _Egg(
    ['emacs'],
    [
      'emacs: an excellent operating system, lacking only a decent terminal portfolio site.',
      'emacs: M-x nothing-happens',
      "emacs vs vim: not getting involved. I like my friendships intact.",
    ],
  ),
  _Egg(
    ['git'],
    [
      "git status: everything's committed. nothing to see here.",
      'git blame: it was already like this when I got here.',
      "git log: 'fix typo' × 47",
      'git push --force: living dangerously, I see.',
      "git: this site doesn't need version control, just vibes and Jaspr.",
    ],
  ),
  _Egg(
    ['npm', 'yarn', 'pnpm'],
    [
      'npm install: this site runs on Dart, not node_modules. no gigabytes were harmed.',
      'npm audit: 1400 vulnerabilities found. luckily, not here.',
      "yarn: cozy package manager, wrong ecosystem — try 'dart pub get'.",
      'pnpm: efficient choice, wrong site.',
    ],
  ),
  _Egg(
    ['python', 'python3'],
    [
      'python: wrong snake, wrong charmer. this site speaks Dart.',
      'python3: there are two Pythons and infinite opinions about which one you meant.',
      'import antigravity: nice reference, wrong tab.',
    ],
  ),
  _Egg(
    ['curl', 'wget'],
    [
      "curl: nothing to fetch — you're already looking at the response.",
      'curl -X GET https://this-site: 200 OK, obviously.',
      'wget: downloading nothing, at full speed.',
    ],
  ),
  _Egg(
    ['ssh'],
    [
      'ssh: connecting to production... just kidding, there is no production, this is static-rendered.',
      "ssh: permission denied (publickey, and also this isn't a server).",
      "ssh root@localhost: bold of you to assume I'd give you root.",
    ],
    style: _EggStyle.error,
  ),
  _Egg(
    ['man'],
    [
      "man: no manual entry for that. try 'help' — it's shorter anyway.",
      'man: RTFM energy noted. there is no manual, just a website.',
      "man grep: now you're just chaining jokes. I respect it.",
    ],
  ),
  _Egg(
    ['history'],
    [
      "history: mostly 'help', a few typos, and one very confident 'sudo rm -rf /'.",
      'history: you can already scroll up for this, but I respect the effort.',
      'history | grep regret: too many matches to display.',
    ],
  ),
  _Egg(
    ['exit', 'quit', 'logout'],
    [
      'exit: there is no escape. this is a single-page app.',
      "logout: you're not logged in. you're just... here.",
      'quit: the real exit is closing the tab, and even that feels rude.',
      'exit: ctrl+w is right there, no judgment.',
    ],
    style: _EggStyle.accent,
  ),
  _Egg(
    ['ps', 'top'],
    [
      'ps aux: coffee.exe (running), vim (still open since 2019), motivation (sleeping)',
      'top: CPU 2%, procrastination 98%.',
      "ps: 1 process found — you, reading a terminal joke instead of 'ls projects'.",
    ],
  ),
  _Egg(
    ['chmod', 'chown'],
    [
      'chmod 777: living dangerously. respect, but no.',
      "chown: this isn't yours to own — but nice try.",
      'chmod +x life: if only it worked that way.',
    ],
    style: _EggStyle.error,
  ),
  _Egg(
    ['kill'],
    [
      "kill: cannot kill process 1 — it's a metaphor, and also init.",
      "kill -9: brutal, and also unnecessary. nothing's running.",
      "kill: there's nothing to end here except your patience.",
    ],
    style: _EggStyle.error,
  ),
  _Egg(
    ['reboot', 'shutdown', 'poweroff'],
    [
      "shutdown: this isn't that kind of terminal — try refreshing the page.",
      'reboot: rebooting... just kidding, everything here is already stateless.',
      'poweroff: bold command for a static site.',
    ],
    style: _EggStyle.error,
  ),
];

/// Looks up a hidden joke response for [name], picking a random line from
/// its pool. Returns null if [name] isn't one of the easter eggs, so callers
/// can fall back to [notFoundOutput].
List<Component>? tryEasterEgg(String name, List<String> args, TerminalActions actions) {
  for (final egg in _easterEggs) {
    if (egg.names.contains(name)) return [_styled(egg.style, _pick(egg.responses))];
  }
  return null;
}

final commands = <Command>[
  Command(name: 'help', description: 'list available commands', handler: _helpOutput),
  Command(name: 'whoami', description: 'who is this, anyway', handler: _whoamiOutput),
  Command(name: 'about', description: 'the longer story', handler: _aboutOutput),
  Command(name: 'metrics', description: 'the numbers, quantified', aliases: ['stats'], handler: _metricsOutput),
  Command(name: 'experience', description: 'work history', handler: _experienceOutput),
  Command(name: 'ls', description: "list 'projects', 'tools', or 'games'", handler: _lsOutput),
  Command(name: 'info', description: 'the long version, e.g. info zonai', handler: _infoOutput),
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
  Command(name: 'sudo', description: 'try it', handler: _sudoOutput),
  Command(name: 'gaming', description: "you'll see", handler: _gamingOutput),
  Command(name: 'jokes', description: 'bad jokes, on demand', handler: _jokesOutput),
  Command(name: 'open', description: "open a project's repo, e.g. open sip", handler: _openOutput),
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
