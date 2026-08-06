import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/experience.dart';
import '../data/profile.dart';
import '../data/projects.dart';
import '../theme.dart';

/// The conventional, readable resume-style layout — "Human Mode".
///
/// Reused both as the in-terminal toggle target and as the standalone
/// `/resume` route (which needs no JS at all to be fully readable).
class HumanModeContent extends StatelessComponent {
  const HumanModeContent({this.standalone = false, super.key});

  /// Whether this is rendered as its own page (adds a link back to `/`)
  /// vs. embedded inside the terminal's mode toggle.
  final bool standalone;

  @override
  Component build(BuildContext context) {
    final flagship = projectsByCategory(ProjectCategory.flagship);

    return div(classes: 'resume', [
      if (standalone)
        a(href: '/', classes: 'resume__back', [.text('← back to the terminal')]),
      header(classes: 'resume__hero', [
        h1([.text(Profile.name)]),
        p(classes: 'resume__role', [.text('${Profile.role} · ${Profile.location}')]),
        p(classes: 'resume__tagline', [.text(Profile.tagline)]),
        div(classes: 'resume__links', [
          a(href: Profile.github, target: .blank, [.text('GitHub')]),
          a(href: Profile.linkedin, target: .blank, [.text('LinkedIn')]),
          a(href: 'mailto:${Profile.email}', [.text('Email')]),
          a(href: '/resume.pdf', download: 'Morgan-Hunt-Resume.pdf', [.text('Résumé (PDF)')]),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// summary')]),
        p([.text(Profile.summary)]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// experience')]),
        div(classes: 'resume__cards', [
          for (final job in experience)
            article(classes: 'resume__card', [
              div(classes: 'resume__card-head', [
                h3([.text(job.company)]),
                span(classes: 'resume__period', [.text(job.period)]),
              ]),
              p(classes: 'resume__card-role', [.text(job.role)]),
              ul([for (final bullet in job.bullets) li([.text(bullet)])]),
            ]),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// projects')]),
        div(classes: 'resume__cards', [
          for (final project in flagship)
            article(classes: 'resume__card', [
              div(classes: 'resume__card-head', [
                h3([.text(project.name)]),
                if (project.stars != null) span(classes: 'resume__stars', [.text('★ ${project.stars}')]),
              ]),
              p([.text(project.description)]),
              if (project.url != null)
                a(href: project.url!, target: .blank, classes: 'resume__project-link', [.text(project.url!)]),
            ]),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// skills')]),
        div(classes: 'resume__skills', [
          for (final group in skillGroups)
            div(classes: 'resume__skill-group', [
              span(classes: 'resume__skill-label', [.text(group.label)]),
              div(classes: 'resume__skill-items', [
                for (final item in group.items) span(classes: 'resume__pill', [.text(item)]),
              ]),
            ]),
        ]),
      ]),
      section(classes: 'resume__section resume__section--contact', [
        h2([.text('// contact')]),
        p([
          .text('Reach out at '),
          a(href: 'mailto:${Profile.email}', [.text(Profile.email)]),
          .text(', or find me as '),
          a(href: Profile.github, target: .blank, [.text('@${Profile.githubHandle}')]),
          .text(' pretty much everywhere.'),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.resume', [
      css('&').styles(
        position: .relative(),
        maxWidth: 760.px,
        padding: .symmetric(horizontal: 1.5.rem, vertical: 3.rem),
        margin: .symmetric(horizontal: .auto),
        boxSizing: .borderBox,
        color: textPrimary,
        fontFamily: fontStack,
      ),
      css('&__back').styles(
        display: .block,
        margin: .only(bottom: 2.rem),
        color: accentCyan,
        textDecoration: TextDecoration(line: .none),
      ),
      css('&__hero', [
        css('&').styles(margin: .only(bottom: 2.5.rem)),
        css('h1').styles(
          margin: .zero,
          color: textPrimary,
          fontSize: 2.5.rem,
          raw: {
            'background': 'linear-gradient(90deg, $accentCyanHex, $accentVioletHex)',
            'background-clip': 'text',
            '-webkit-background-clip': 'text',
            '-webkit-text-fill-color': 'transparent',
          },
        ),
      ]),
      css('&__role').styles(margin: .only(top: 0.5.rem), color: textMuted, fontSize: 1.1.rem),
      css('&__tagline').styles(margin: .only(top: 0.75.rem), color: accentCyan, fontStyle: .italic),
      css('&__links', [
        css('&').styles(display: .flex, margin: .only(top: 1.25.rem), gap: Gap(column: 1.25.rem)),
        css('a').styles(
          transition: Transition('color', duration: durFast),
          color: textPrimary,
          textDecoration: TextDecoration(line: .underline, color: borderStrong),
        ),
        css('a:hover').styles(color: accentCyan),
      ]),
      css('&__section', [
        css('&').styles(margin: .only(bottom: 2.5.rem)),
        css('h2').styles(
          margin: .only(bottom: 1.rem),
          color: accentViolet,
          fontSize: 0.95.rem,
          textTransform: .lowerCase,
          letterSpacing: 1.px,
        ),
        css('p').styles(color: textMuted, lineHeight: 1.6.em),
      ]),
      css('&__cards').styles(display: .flex, flexDirection: .column, gap: Gap(row: 1.rem)),
      css('&__card', [
        css('&').styles(
          padding: .all(1.25.rem),
          border: .all(color: borderSubtle, width: 1.px),
          radius: .all(.circular(10.px)),
          transition: Transition.combine([
            Transition('border-color', duration: durFast),
            Transition('transform', duration: durFast),
          ]),
          backgroundColor: bgPanelSoft,
        ),
        css('&:hover').styles(
          border: .all(color: borderStrong, width: 1.px),
          transform: .translate(y: (-2).px),
        ),
        css('h3').styles(margin: .zero, color: textPrimary, fontSize: 1.05.rem),
        css('p').styles(margin: .only(top: 0.5.rem), color: textMuted),
        css('ul').styles(padding: .only(left: 1.1.rem), margin: .only(top: 0.75.rem), color: textMuted),
        css('li').styles(margin: .only(bottom: 0.35.rem), lineHeight: 1.5.em),
      ]),
      css('&__card-head').styles(
        display: .flex,
        flexWrap: .wrap,
        justifyContent: .spaceBetween,
        alignItems: .center,
        gap: Gap(column: 0.75.rem),
      ),
      css('&__period').styles(color: textDim, fontSize: 0.85.rem, whiteSpace: .noWrap),
      css('&__stars').styles(color: accentAmber, fontSize: 0.85.rem),
      css('&__card-role').styles(margin: .only(top: 0.35.rem), color: accentCyan, fontSize: 0.9.rem),
      css('&__project-link').styles(
        display: .inlineBlock,
        margin: .only(top: 0.75.rem),
        color: accentCyan,
        fontSize: 0.85.rem,
        textDecoration: TextDecoration(line: .none),
      ),
      css('&__skills').styles(display: .flex, flexDirection: .column, gap: Gap(row: 1.rem)),
      css('&__skill-group').styles(
        display: .flex,
        flexWrap: .wrap,
        alignItems: .start,
        gap: Gap(column: 1.rem),
      ),
      css('&__skill-label').styles(
        minWidth: 7.rem,
        margin: .only(top: 0.4.rem),
        color: textDim,
        fontSize: 0.85.rem,
        textTransform: .upperCase,
        letterSpacing: 1.px,
      ),
      css('&__skill-items').styles(display: .flex, flexWrap: .wrap, gap: Gap(row: 0.5.rem, column: 0.5.rem)),
      css('&__pill').styles(
        padding: .symmetric(horizontal: 0.75.rem, vertical: 0.3.rem),
        border: .all(color: borderSubtle, width: 1.px),
        radius: .all(.circular(999.px)),
        color: textPrimary,
        fontSize: 0.85.rem,
      ),
    ]),
  ];
}

const accentCyanHex = '#5eead4';
const accentVioletHex = '#a78bfa';
