/// An app that shipped to the public App Store and Google Play.
///
/// Deliberately separate from `ProjectEntry`: those are things I built and
/// published myself, so their proof is a repo or a pub.dev listing. These
/// are products built for an employer — the code isn't mine to link, so the
/// store listing *is* the receipt. A visitor who wants to check the claims
/// in the experience section can go install the thing.
class ShippedApp {
  const ShippedApp({
    required this.name,
    required this.storeName,
    required this.icon,
    required this.period,
    required this.headline,
    required this.description,
    required this.appStoreUrl,
    required this.playStoreUrl,
  });

  /// The short name, as it's referred to everywhere else on the site.
  final String name;

  /// The full title on the store listings, which is longer and
  /// keyword-stuffed in the way store titles always are.
  final String storeName;

  /// Path to the app icon under `web/`, pulled from the iTunes artwork API
  /// at 256px so it stays crisp on retina at its 64px render size.
  final String icon;

  final String period;

  /// The scale of the thing in one scannable line — same job as
  /// `ExperienceEntry.headline`, and kept consistent with it on purpose.
  final String headline;

  final String description;

  final String appStoreUrl;
  final String playStoreUrl;
}

/// Ratings are quoted rather than pulled at build time, unlike the pub.dev
/// and GitHub numbers. Both were verified against the iTunes lookup API when
/// this list was written (Couchsurfing 4.50 across 9,252 ratings; Clean
/// Simple Eats 4.82 across 5,753) and both are stated as floors, so they age
/// gracefully rather than going wrong the moment a rating lands.
const shippedApps = <ShippedApp>[
  ShippedApp(
    name: 'Couchsurfing',
    storeName: 'Couchsurfing: Stay, Meet, Host',
    icon: '/apps/couchsurfing.png',
    period: 'Nov 2023 — Present',
    headline: '25M+ members · 1.3M lines · iOS & Android',
    description:
        'The travel app I architected from an empty repo to 1.3M lines of production Flutter, and the one '
        'I lead a team of 9 engineers on today. Members use it to find hosts, meet locals, and plan stays '
        'around the world.',
    appStoreUrl: 'https://apps.apple.com/us/app/couchsurfing-stay-meet-host/id525642917',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.couchsurfing.mobile.android',
  ),
  ShippedApp(
    name: 'Clean Simple Eats',
    storeName: 'Clean Simple Eats +',
    icon: '/apps/clean-simple-eats.png',
    period: 'Jan 2020 — Jul 2023',
    headline: r'4.8★ · 5,700+ ratings · $1M+ annual revenue',
    description:
        'A meal-planning and nutrition app I owned end to end as its sole developer for most of 3.5 years — '
        'grown 5× to 10K+ monthly active users, shipped to both platforms on a two-week release cadence.',
    appStoreUrl: 'https://apps.apple.com/us/app/clean-simple-eats/id1449960712',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.cleansimpleeats.cseplus',
  ),
];

/// Lookup used by the terminal's `open` command, so `open couchsurfing`
/// works the same way `open sip` does.
///
/// Matches on a squashed form rather than the literal name because one of
/// these is three words: `clean simple eats`, `cleansimpleeats`, and
/// `clean-simple-eats` should all land on the same card.
ShippedApp? findShippedApp(String name) {
  final target = _squash(name);
  for (final app in shippedApps) {
    if (_squash(app.name) == target) return app;
  }
  return null;
}

String _squash(String value) => value.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
