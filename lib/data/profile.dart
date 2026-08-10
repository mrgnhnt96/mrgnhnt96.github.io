/// Static identity/contact info, sourced from the resume.
abstract final class Profile {
  static const name = 'Morgan Hunt';
  static const role = 'Staff Software Engineer';
  static const location = 'Mesa, AZ';
  static const tagline = 'Building the Dart ecosystem\'s missing tools — one framework at a time.';
  static const summary =
      'Staff software engineer with 8+ years building high-quality mobile apps, developer '
      'tools, and backend systems. Specialized in Flutter and Dart, with a focus on '
      'performance, developer experience, and clean architecture. Most of what I build outside '
      'the day job exists because some corner of the Dart ecosystem was missing it — two backend '
      'frameworks (Revali and Zonai), monorepo tooling, git hooks, a pile of code generators. If a tool gets in a '
      "developer's way, I'd rather fix the tool than work around it.";

  static const howIWork =
      'At Couchsurfing I lead and mentor a team of 9, but the instinct is the same at any '
      'scale: remove friction before adding process. I like small, sharp tools that compose — '
      'a CLI that does one thing well, a codegen step that kills a whole class of bugs, a git '
      "hook that catches a mistake before it ships. If I can automate the boring part, everyone "
      'gets more time for the interesting part.';

  static const zeldaFact =
      "Ocarina of Time was the first game I ever beat, and I've been playing Zelda ever since — "
      "Revali and Zonai are both named after Zelda lore, if that wasn't obvious. Current "
      'favorite: Tears of the Kingdom.';

  static const email = 'mrgnhnt96@gmail.com';
  static const github = 'https://github.com/mrgnhnt96';
  static const githubHandle = 'mrgnhnt96';
  static const linkedin = 'https://www.linkedin.com/in/mrgnhnt96/';
  static const twitter = 'https://x.com/mrgnhnt96_dev';
  static const twitterHandle = 'mrgnhnt96_dev';
}

class SkillGroup {
  const SkillGroup({required this.label, required this.items});

  final String label;
  final List<String> items;
}

const skillGroups = <SkillGroup>[
  SkillGroup(label: 'Languages', items: ['Dart', 'TypeScript', 'JavaScript', 'Python']),
  SkillGroup(label: 'Frameworks', items: ['Flutter', 'Jaspr', 'Nocterm', 'Revali', 'Zonai', 'NestJS']),
  SkillGroup(label: 'Platforms', items: ['iOS', 'Android', 'macOS', 'Linux', 'Windows']),
  SkillGroup(label: 'Architecture', items: ['Clean Architecture', 'BLoC', 'Provider', 'Scoped Deps', 'Get It', 'TDD']),
];
