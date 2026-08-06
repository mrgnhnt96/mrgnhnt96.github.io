import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/ambient_background.dart';
import '../components/human_mode_content.dart';

/// The standalone `/resume` route: fully static, server-rendered, no client
/// JS required to read it. Exists mainly so the readable version is a
/// shareable, crawlable URL on its own — not just something you get to by
/// clicking a toggle.
class ResumePage extends StatelessComponent {
  const ResumePage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'resume-page', [const AmbientBackground(), const HumanModeContent(standalone: true)]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.resume-page').styles(position: .relative(), minHeight: 100.vh),
  ];
}
