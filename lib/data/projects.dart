enum ProjectCategory {
  flagship,
  tool,
  game;

  String get label => switch (this) {
    ProjectCategory.flagship => 'projects',
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
    this.stars,
  });

  final String name;
  final String description;
  final ProjectCategory category;
  final String? url;
  final String? pubDevUrl;
  final int? stars;

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
    category: ProjectCategory.flagship,
    url: 'https://github.com/mrgnhnt96/revali',
    stars: 9,
  ),
  ProjectEntry(
    name: 'zonai',
    description:
        'Batteries-included Dart backend framework — auth, database, live query streams, file storage, cron. '
        "Named after Tears of the Kingdom's ancient civilization. (Pending release)",
    category: ProjectCategory.flagship,
    url: 'https://github.com/mrgnhnt96/zonai',
  ),
  ProjectEntry(
    name: 'sip',
    description: 'A CLI to manage Dart mono-repos — run scripts, tests, and pub commands across every package.',
    category: ProjectCategory.flagship,
    url: 'https://github.com/mrgnhnt96/sip',
    stars: 5,
  ),
  ProjectEntry(
    name: 'hooksman',
    description: 'Git hooks and tasks defined as Dart scripts or shell commands — a Dart-native Husky.',
    category: ProjectCategory.flagship,
    url: 'https://github.com/mrgnhnt96/hooksman',
    stars: 5,
  ),
  ProjectEntry(
    name: 'oat',
    description: 'A macOS app for managing shell aliases, functions, env vars, and PATH entries — GUI + CLI.',
    category: ProjectCategory.flagship,
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
