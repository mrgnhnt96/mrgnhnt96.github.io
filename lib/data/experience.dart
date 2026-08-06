class ExperienceEntry {
  const ExperienceEntry({
    required this.company,
    required this.role,
    required this.period,
    required this.bullets,
  });

  final String company;
  final String role;
  final String period;
  final List<String> bullets;
}

const experience = <ExperienceEntry>[
  ExperienceEntry(
    company: 'Couchsurfing International',
    role: 'Staff Software Engineer',
    period: 'Nov 2023 — Present',
    bullets: [
      'Led and mentored a team of 9 mobile engineers, defining technical direction and engineering standards.',
      'Architected the Flutter app from the ground up, scaling it past 1.3M lines of code.',
      'Built a type-safe codegen pipeline syncing backend TypeScript contracts with Dart models.',
      'Designed a fully automated CI/CD platform for iOS and Android multi-track releases.',
    ],
  ),
  ExperienceEntry(
    company: 'Clean Simple Eats',
    role: 'Senior Software Engineer',
    period: 'Jan 2020 — Jul 2023',
    bullets: [
      'Served as the primary Flutter engineer for a large-scale meal-planning application, building and maintaining core mobile features.',
      'Partnered with product, design, and leadership teams to deliver high-quality user experiences and support business objectives.',
      'Helped coordinate cross-functional teams and drive successful releases across iOS and Android.',
    ],
  ),
];
