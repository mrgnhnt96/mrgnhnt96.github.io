class ExperienceEntry {
  const ExperienceEntry({
    required this.company,
    required this.role,
    required this.period,
    required this.headline,
    required this.bullets,
  });

  final String company;
  final String role;
  final String period;

  /// The scope of the role in one scannable line — the numbers a reader
  /// should absorb before they decide whether to read the bullets at all.
  final String headline;

  /// Power statements: {action verb} + {what I did with the skill} +
  /// {outcome}. Deliberately not a list of responsibilities.
  final List<String> bullets;
}

const experience = <ExperienceEntry>[
  ExperienceEntry(
    company: 'Couchsurfing International',
    role: 'Staff Software Engineer',
    period: 'Nov 2023 — Present',
    headline: '25M+ members · 1.3M lines of code · team of 9',
    bullets: [
      'Architected the Couchsurfing Flutter app from an empty repo to 1.3M lines of production code, '
          'shipping to a global member base of 25M+ across iOS and Android.',
      'Lead and mentor a team of 9 mobile engineers, reviewing 2,382 pull requests to date and setting '
          'the architecture and engineering standards the entire mobile org now builds against.',
      'Shipped 947 pull requests and 1,100+ commits into a 67-contributor monorepo, one of its most '
          'active engineers across both the Dart and TypeScript sides.',
      'Built a type-safe code generation pipeline that syncs backend TypeScript contracts into Dart '
          'models, eliminating hand-written API models and the whole class of runtime contract bugs '
          'that came with them.',
      'Designed a fully automated CI/CD platform for multi-track iOS and Android releases, turning a '
          'manual, engineer-supervised process into a hands-off pipeline.',
    ],
  ),
  ExperienceEntry(
    company: 'Clean Simple Eats',
    role: 'Senior Software Engineer',
    period: 'Jan 2020 — Jul 2023',
    headline: r'$1M+ annual revenue · 5× user growth · 4.8★ · sole developer',
    bullets: [
      'Grew the Clean Simple Eats app from ~2K to 10K+ monthly active users — a 5× increase — as the '
          'sole developer for the majority of a 3.5-year tenure.',
      'Built and maintained the mobile product behind more than \$1M in annual revenue, owning the '
          'iOS and Android codebase end to end.',
      'Sustained a 4.8-star App Store rating across 5,700+ ratings while shipping on a two-week '
          'release cadence for both platforms.',
      'Partnered directly with product, design, and leadership to turn business objectives into '
          'shipped features, from concept through store release.',
    ],
  ),
];
