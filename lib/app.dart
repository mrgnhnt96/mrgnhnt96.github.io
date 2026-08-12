import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

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
          title: 'Morgan Hunt',
          builder: (context, state) => Component.fragment([_canonical('/'), const Home()]),
        ),
        Route(
          path: '/resume',
          title: 'Morgan Hunt — Résumé',
          // Pre-rendering writes this route to `resume/index.html`, which
          // GitHub Pages serves at `/resume/` and redirects `/resume` to — so
          // the canonical URL carries the trailing slash.
          builder: (context, state) => Component.fragment([_canonical('/resume/'), const ResumePage()]),
        ),
      ],
    );
  }
}

/// The two head tags that have to differ per page: the canonical URL search
/// engines should index, and the `og:url` scrapers show in link previews. The
/// rest of the head is shared and lives in `main.server.dart`.
Component _canonical(String path) => Document.head(
  children: [
    link(rel: 'canonical', href: '$_origin$path'),
    meta(attributes: {'property': 'og:url'}, content: '$_origin$path'),
  ],
);
