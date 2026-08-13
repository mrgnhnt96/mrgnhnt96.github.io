import 'pub_stats.dart';

/// Static identity/contact info, sourced from the resume.
abstract final class Profile {
  static const name = 'Morgan Hunt';
  static const role = 'Staff Software Engineer';
  static const location = 'Mesa, AZ';
  static const tagline = 'I build the tools other Dart developers build on.';

  /// The elevator pitch — the first thing a hiring manager reads.
  ///
  /// Every sentence carries a number on purpose. This replaced a longer,
  /// softer version whose problem was that it described what I like doing
  /// instead of what I've actually shipped and at what scale.
  static final summary =
      'Staff software engineer, 8+ years deep in Dart and Flutter. I architected '
      "Couchsurfing's mobile app from an empty repo to 1.3M lines of production code serving "
      '25M+ members, and I lead the team of 9 engineers who build on it. Before that I grew a '
      "meal-planning app 5× to 10K+ monthly active users as its sole developer, on a product "
      'doing over \$1M a year at 4.8 stars. Outside the day job I maintain $pubPackageCount '
      'packages on pub.dev — including two full backend frameworks, Revali and Zonai — '
      'downloaded ${compactCount(pubDownloads30Days)} times a month. Most of it exists because '
      "some corner of the Dart ecosystem was missing it. If a tool gets in a developer's way, "
      "I'd rather fix the tool than work around it.";

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

/// A headline skill, paired with the evidence that backs it.
///
/// The old version of this was four buckets of ~20 bare technology names,
/// which said "I have heard of these" rather than "I have done this at
/// scale". Five skills that each carry their own proof beat twenty that
/// carry none.
class CoreSkill {
  const CoreSkill({required this.name, required this.proof});

  final String name;

  /// The quantified receipt for [name].
  final String proof;
}

final coreSkills = <CoreSkill>[
  const CoreSkill(name: 'Flutter & Dart', proof: '8+ years, shipped to 25M+ users'),
  const CoreSkill(name: 'Mobile architecture at scale', proof: '1.3M-line codebase, architected from scratch'),
  CoreSkill(
    name: 'Developer tooling & codegen',
    proof: '$pubPackageCount packages, ${compactCount(pubDownloads30Days)} downloads/mo',
  ),
  const CoreSkill(name: 'Backend framework design', proof: 'Revali and Zonai, built and published end to end'),
  const CoreSkill(name: 'Technical leadership', proof: 'Team of 9, 2,382 pull requests reviewed'),
];

class SkillGroup {
  const SkillGroup({required this.label, required this.items});

  final String label;
  final List<String> items;
}

/// The full stack, kept as supporting detail *below* [coreSkills] — useful
/// for keyword matching without being the first thing anyone reads.
const skillGroups = <SkillGroup>[
  SkillGroup(label: 'Languages', items: ['Dart', 'TypeScript', 'JavaScript', 'Python']),
  SkillGroup(label: 'Frameworks', items: ['Flutter', 'Jaspr', 'Nocterm', 'Revali', 'Zonai', 'NestJS']),
  SkillGroup(label: 'Platforms', items: ['iOS', 'Android', 'macOS', 'Linux', 'Windows']),
  SkillGroup(label: 'Architecture', items: ['BLoC', 'Provider', 'Scoped Deps', 'Get It', 'TDD']),
];
