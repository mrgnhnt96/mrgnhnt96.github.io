import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'pages/home.dart';
import 'pages/resume.dart';

/// The root component. Only built on the server during pre-rendering
/// (multi-page routing) — [Home] is the sole `@client` island; [ResumePage]
/// stays fully static.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(path: '/', title: 'Morgan Hunt', builder: (context, state) => const Home()),
        Route(path: '/resume', title: 'Morgan Hunt — Résumé', builder: (context, state) => const ResumePage()),
      ],
    );
  }
}
