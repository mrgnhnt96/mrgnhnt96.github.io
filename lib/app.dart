import 'dart:convert';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'data/profile.dart';
import 'data/pub_stats.dart';
import 'pages/home.dart';
import 'pages/resume.dart';

/// Where the built site is served from — used to build absolute URLs for the
/// tags that require them.
const _origin = 'https://mrgnhnt.com';

/// The root component. Only built on the server during pre-rendering
/// (multi-page routing) — [Home] is the sole `@client` island; [ResumePage]
/// stays fully static.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(
          path: '/',
          title: 'Morgan Hunt — Staff Software Engineer, Flutter & Dart',
          builder: (context, state) => Component.fragment([
            _canonical('/', description: _homeDescription),
            _structuredData(),
            const Home(),
          ]),
        ),
        Route(
          path: '/resume',
          title: 'Morgan Hunt — Résumé',
          // Pre-rendering writes this route to `resume/index.html`, which
          // GitHub Pages serves at `/resume/` and redirects `/resume` to — so
          // the canonical URL carries the trailing slash.
          builder: (context, state) => Component.fragment([
            _canonical('/resume/', description: _resumeDescription),
            const ResumePage(),
          ]),
        ),
      ],
    );
  }
}

/// The search-result snippet for `/`. Leads with the numbers, since this is
/// often the only line a recruiter reads before deciding whether to click.
/// Past tense for the team: the Couchsurfing role ended in Aug 2026.
final _homeDescription =
    'Staff Software Engineer. Architected a 1.3M-line Flutter app serving 25M+ users, led a team '
    'of 9, and maintains $pubPackageCount Dart packages with ${compactCount(pubDownloads30Days)} downloads a month.';

const _resumeDescription =
    "Résumé of Morgan Hunt, Staff Software Engineer: Couchsurfing's Flutter app, Clean Simple Eats, "
    'and the Revali and Zonai Dart backend frameworks.';

/// The head tags that have to differ per page: the canonical URL search
/// engines should index, the `og:url` scrapers show in link previews, and the
/// search snippet. The rest of the head is shared and lives in
/// `main.server.dart`.
Component _canonical(String path, {required String description}) => Document.head(
  meta: {'description': description},
  children: [
    link(rel: 'canonical', href: '$_origin$path'),
    meta(attributes: {'property': 'og:url'}, content: '$_origin$path'),
  ],
);

/// `WebSite` and `Person` JSON-LD for the home page, so search engines can
/// tie the site to its owner and his profiles.
Component _structuredData() => Document.head(
  children: [
    script(
      attributes: {'type': 'application/ld+json'},
      content: jsonEncode({
        '@context': 'https://schema.org',
        '@graph': [
          {'@type': 'WebSite', 'name': Profile.name, 'url': '$_origin/'},
          {
            '@type': 'Person',
            'name': Profile.name,
            'url': '$_origin/',
            'jobTitle': Profile.role,
            'sameAs': [Profile.github, Profile.linkedin, Profile.twitter],
          },
        ],
      }),
    ),
  ],
);
