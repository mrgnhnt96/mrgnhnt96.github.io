enum ProjectCategory {
  project,
  tool,
  game;

  String get label => switch (this) {
    ProjectCategory.project => 'projects',
    ProjectCategory.tool => 'tools',
    ProjectCategory.game => 'games',
  };
}

class ProjectEntry {
  const ProjectEntry({
    required this.name,
    required this.description,
    required this.category,
    this.url,
    this.pubDevUrl,
    this.docsUrl,
    this.stars,
    this.featured = false,
    this.status,
    this.highlights = const [],
  });

  final String name;
  final String description;
  final ProjectCategory category;
  final String? url;
  final String? pubDevUrl;

  /// A dedicated documentation site, for the projects big enough to need one.
  final String? docsUrl;
  final int? stars;

  /// The two frameworks the rest of the list orbits around. Featured entries
  /// get their own section up top instead of being one card among ten.
  final bool featured;

  /// Short "where this stands today" line — only worth showing for [featured]
  /// entries, where visitors are likely to ask whether they can use it yet.
  final String? status;

  /// The two or three things worth knowing, for entries that get a full
  /// write-up rather than a one-liner.
  final List<String> highlights;

  /// Where this project's code actually lives — its repo if there is one,
  /// its pub.dev listing otherwise. Null if neither exists (yet).
  String? get link => url ?? pubDevUrl;
}

const projects = <ProjectEntry>[
  ProjectEntry(
    name: 'revali',
    description:
        'A Dart backend framework inspired by NestJS — decorators, DI, and structure for building APIs. '
        '(Yes, named after the Zelda champion.)',
    category: ProjectCategory.project,
    url: 'https://github.com/mrgnhnt96/revali',
    docsUrl: 'https://revali.dev',
    stars: 9,
    featured: true,
    status: 'Published on pub.dev · docs at revali.dev',
    highlights: [
      'Annotate a controller and Revali generates the router, request binding, and DI wiring — no boilerplate to hand-maintain.',
      'Constructs extend the build: Swagger docs, a typed Dart client, and Docker output all fall out of the same annotations.',
      'Ships a CLI (dev server, route inspection, scaffolding, doctor) and an MCP server, so agents can read your routes too.',
    ],
  ),
  ProjectEntry(
    name: 'zonai',
    description:
        'A batteries-included Dart backend framework — auth, a typed database layer, live query streams, file '
        'storage, cron, and rules-based access control, generated from a schema you write in Dart. '
        "Named after Tears of the Kingdom's ancient civilization.",
    category: ProjectCategory.project,
    url: 'https://github.com/mrgnhnt96/zonai',
    docsUrl: 'https://docs.zonai.dev',
    featured: true,
    status: 'v0.6.0 · docs at docs.zonai.dev · pub release pending',
    highlights: [
      'Live query streams: clients subscribe to a query and get pushed updates as rows change — no polling loop to write.',
      'Schema-first — declare your tables in Dart and get CRUD, auth flows, SQL, and a typed client generated at compile time.',
      'Auth is built in: JWT sessions, OTP, magic links, external identity providers, and per-row access rules.',
      "Built on Revali's router, so the two frameworks share a foundation — Zonai is what Revali looks like with the batteries included.",
    ],
  ),
  ProjectEntry(
    name: 'sip',
    description: 'A CLI to manage Dart mono-repos — run scripts, tests, and pub commands across every package.',
    category: ProjectCategory.project,
    url: 'https://github.com/mrgnhnt96/sip',
    stars: 5,
  ),
  ProjectEntry(
    name: 'hooksman',
    description: 'Git hooks and tasks defined as Dart scripts or shell commands — a Dart-native Husky.',
    category: ProjectCategory.project,
    url: 'https://github.com/mrgnhnt96/hooksman',
    stars: 5,
  ),
  ProjectEntry(
    name: 'oat',
    description: 'A macOS app for managing shell aliases, functions, env vars, and PATH entries — GUI + CLI.',
    category: ProjectCategory.project,
  ),
  ProjectEntry(
    name: 'equatable_gen',
    description: 'Auto-generates `props` getters for classes using the equatable package.',
    category: ProjectCategory.tool,
    url: 'https://github.com/mrgnhnt96/equatable_gen',
    stars: 5,
  ),
  ProjectEntry(
    name: 'import_ozempic',
    description: 'Replaces Dart barrel imports with direct source imports. Trims the fat.',
    category: ProjectCategory.tool,
    url: 'https://github.com/mrgnhnt96/import_ozempic',
    stars: 2,
  ),
  ProjectEntry(
    name: 'change_case',
    description: 'Convert strings between camelCase, snake_case, kebab-case, and more.',
    category: ProjectCategory.tool,
    url: 'https://github.com/mrgnhnt96/change_case',
    stars: 12,
  ),
  ProjectEntry(
    name: 'minesweeper',
    description: 'Classic Minesweeper, recreated for the command line.',
    category: ProjectCategory.game,
    url: 'https://github.com/mrgnhnt96/minesweeper',
    stars: 15,
  ),
  ProjectEntry(
    name: 'snake',
    description: 'Classic Snake, recreated for the command line.',
    category: ProjectCategory.game,
    url: 'https://github.com/mrgnhnt96/snake',
    stars: 5,
  ),
  ProjectEntry(
    name: 'gun_fu',
    description: 'A terminal game about a gunfight. Draw fast.',
    category: ProjectCategory.game,
    url: 'https://github.com/mrgnhnt96/gun_fu',
  ),
];

List<ProjectEntry> projectsByCategory(ProjectCategory category) =>
    projects.where((p) => p.category == category).toList();

/// The frameworks that lead the list — see [ProjectEntry.featured].
List<ProjectEntry> get featuredProjects => projects.where((p) => p.featured).toList();
