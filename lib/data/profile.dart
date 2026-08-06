/// Static identity/contact info, sourced from the resume.
abstract final class Profile {
  static const name = 'Morgan Hunt';
  static const role = 'Staff Software Engineer';
  static const location = 'Mesa, AZ';
  static const tagline = 'Building the Dart ecosystem\'s missing tools — one framework at a time.';
  static const summary =
      'Senior software engineer with 8+ years building high-quality mobile apps, developer '
      'tools, and backend systems. Specialized in Flutter and Dart, with a focus on '
      'performance, developer experience, and clean architecture.';

  static const email = 'mrgnhnt96@gmail.com';
  static const github = 'https://github.com/mrgnhnt96';
  static const githubHandle = 'mrgnhnt96';
  static const linkedin = 'https://www.linkedin.com/in/mrgnhnt';
}

class SkillGroup {
  const SkillGroup({required this.label, required this.items});

  final String label;
  final List<String> items;
}

const skillGroups = <SkillGroup>[
  SkillGroup(label: 'Languages', items: ['Dart', 'TypeScript', 'JavaScript', 'Python']),
  SkillGroup(label: 'Frameworks', items: ['Flutter', 'Jaspr', 'Nocterm', 'Revali', 'NestJS']),
  SkillGroup(label: 'Platforms', items: ['iOS', 'Android', 'macOS', 'Linux', 'Windows']),
  SkillGroup(label: 'Architecture', items: ['Clean Architecture', 'BLoC', 'Provider', 'Scoped Deps', 'Get It', 'TDD']),
];
