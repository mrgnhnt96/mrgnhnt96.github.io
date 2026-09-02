import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/apps.dart';
import '../data/experience.dart';
import '../data/metrics.dart';
import '../data/profile.dart';
import '../data/projects.dart';
import '../theme.dart';

/// The grid of headline [Metric] cards.
Component _metricGrid(List<Metric> metrics) {
  return div(classes: 'resume__metrics', [
    for (final metric in metrics)
      div(classes: 'resume__metric', [
        span(classes: 'resume__metric-value', [.text(metric.value)]),
        span(classes: 'resume__metric-label', [.text(metric.label)]),
        if (metric.detail != null) span(classes: 'resume__metric-detail', [.text(metric.detail!)]),
      ]),
  ]);
}

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
    // Featured first, matching the terminal's ordering — the frameworks lead
    // the list, the one-liners follow.
    final allProjects = [
      ...featuredProjects,
      ...projectsByCategory(ProjectCategory.project).where((entry) => !entry.featured),
    ];

    return div(classes: 'resume', [
      if (standalone) a(href: '/', classes: 'resume__back', [.text('← back to the terminal')]),
      header(classes: 'resume__hero', [
        h1([.text(Profile.name)]),
        p(classes: 'resume__role', [.text('${Profile.role} · ${Profile.location}')]),
        p(classes: 'resume__tagline', [.text(Profile.tagline)]),
        div(classes: 'resume__links', [
          a(href: Profile.github, target: .blank, [.text('GitHub')]),
          a(href: Profile.linkedin, target: .blank, [.text('LinkedIn')]),
          a(href: Profile.twitter, target: .blank, [.text('Twitter')]),
          a(href: 'mailto:${Profile.email}', [.text('Email')]),
          a(href: '/resume.pdf', download: 'Morgan-Hunt-Resume.pdf', [.text('Résumé (PDF)')]),
        ]),
      ]),
      // The numbers come before the prose deliberately — they're the part
      // that survives a ten-second skim.
      section(classes: 'resume__section', [
        h2([.text('// by the numbers')]),
        _metricGrid(headlineMetrics),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// summary')]),
        p([.text(Profile.summary)]),
      ]),
      // Sits between the summary and the jobs on purpose: the summary makes
      // the claims, this section is the part a reader can go tap and verify,
      // and the experience bullets below explain what it took.
      section(classes: 'resume__section', [
        h2([.text('// shipped apps')]),
        div(classes: 'resume__cards', [
          for (final app in shippedApps)
            article(classes: 'resume__card resume__app', [
              div(classes: 'resume__app-head', [
                img(src: app.icon, alt: '${app.name} app icon', classes: 'resume__app-icon'),
                div(classes: 'resume__app-title', [
                  h3([.text(app.name)]),
                  span(classes: 'resume__app-store-name', [.text(app.storeName)]),
                ]),
                span(classes: 'resume__period', [.text(app.period)]),
              ]),
              p(classes: 'resume__card-headline', [.text(app.headline)]),
              p([.text(app.description)]),
              div(classes: 'resume__project-links', [
                a(href: app.appStoreUrl, target: .blank, classes: 'resume__store-link', [.text('App Store ↗')]),
                a(href: app.playStoreUrl, target: .blank, classes: 'resume__store-link', [.text('Google Play ↗')]),
              ]),
            ]),
        ]),
      ]),
      // The jobs lead the body — the shipped-at-work record is what a hiring
      // manager is here for, and the projects read as supporting evidence.
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
              p(classes: 'resume__card-headline', [.text(job.headline)]),
              ul([
                for (final bullet in job.bullets) li([.text(bullet)]),
              ]),
            ]),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// projects')]),
        div(classes: 'resume__cards', [
          for (final project in allProjects)
            // The two frameworks get the full write-up — status, highlights,
            // a docs link — while everything else stays a one-liner.
            article(
              classes: project.featured ? 'resume__card resume__card--featured' : 'resume__card',
              [
                div(classes: 'resume__card-head', [
                  h3([.text(project.name)]),
                  if (project.stars != null) span(classes: 'resume__stars', [.text('★ ${project.stars}')]),
                ]),
                if (project.status != null) p(classes: 'resume__status', [.text(project.status!)]),
                p([.text(project.description)]),
                if (project.highlights.isNotEmpty)
                  ul([
                    for (final highlight in project.highlights) li([.text(highlight)]),
                  ]),
                if (project.featured)
                  div(classes: 'resume__project-links', [
                    if (project.docsUrl != null)
                      a(href: project.docsUrl!, target: .blank, classes: 'resume__project-link', [.text('docs')]),
                    if (project.link != null)
                      a(href: project.link!, target: .blank, classes: 'resume__project-link', [.text('source')]),
                  ])
                else if (project.link != null)
                  a(href: project.link!, target: .blank, classes: 'resume__project-link', [.text(project.link!)]),
              ],
            ),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// core skills')]),
        div(classes: 'resume__core-skills', [
          for (final skill in coreSkills)
            div(classes: 'resume__core-skill', [
              span(classes: 'resume__core-skill-name', [.text(skill.name)]),
              span(classes: 'resume__core-skill-proof', [.text(skill.proof)]),
            ]),
        ]),
      ]),
      section(classes: 'resume__section', [
        h2([.text('// full stack')]),
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
          .text(' on GitHub or '),
          a(href: Profile.twitter, target: .blank, [.text('@${Profile.twitterHandle}')]),
          .text(' on Twitter.'),
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
        // Unlike the terminal, this had no backing panel — it sat straight
        // on the raw ambient background. Fine when the aurora was subtle,
        // but low-contrast tokens like textDim disappear into it now that
        // the aurora's more vivid on mobile. bgPanel (not the more
        // translucent bgPanelSoft) because this page leans on textDim for
        // meaningful labels, not just decoration, so it needs a reliably
        // dark backdrop rather than an especially transparent one.
        backgroundColor: bgPanel,
        backdropFilter: .blur(18.px),
        raw: {'-webkit-backdrop-filter': 'blur(18px)'},
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
      css('&__role').styles(
        margin: .only(top: 0.5.rem),
        color: textMuted,
        fontSize: 1.1.rem,
      ),
      css('&__tagline').styles(
        margin: .only(top: 0.75.rem),
        color: accentCyan,
        fontStyle: .italic,
      ),
      css('&__links', [
        css('&').styles(
          display: .flex,
          margin: .only(top: 1.25.rem),
          gap: Gap(column: 1.25.rem),
        ),
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
      css('&__cards').styles(
        display: .flex,
        flexDirection: .column,
        gap: Gap(row: 1.rem),
      ),
      // auto-fit rather than a fixed column count so the four metrics
      // reflow from two-up to one-up on their own. The 260px floor lands on
      // two columns inside this page's 760px measure — wide enough that
      // each card's detail sentence gets a readable line length instead of
      // wrapping every three words.
      css('&__metrics').styles(
        display: .grid,
        gap: Gap(row: 0.75.rem, column: 0.75.rem),
        raw: {'grid-template-columns': 'repeat(auto-fit, minmax(260px, 1fr))'},
      ),
      // These are the only numbers on the page now, so they all carry the
      // accent treatment that used to separate the headline four from the
      // supporting grids below them.
      css('&__metric').styles(
        display: .flex,
        padding: .all(0.9.rem),
        border: .all(color: .rgba(94, 234, 212, 0.3), width: 1.px),
        radius: .all(.circular(10.px)),
        flexDirection: .column,
        gap: Gap(row: 0.15.rem),
        backgroundColor: bgPanelSoft,
        raw: {'background-image': 'linear-gradient(150deg, rgba(94, 234, 212, 0.08), rgba(167, 139, 250, 0.06))'},
      ),
      css('&__metric-value').styles(
        color: accentCyan,
        fontSize: 1.55.rem,
        fontWeight: .bold,
        lineHeight: 1.1.em,
      ),
      css('&__metric-label').styles(
        color: textPrimary,
        fontSize: 0.75.rem,
        textTransform: .upperCase,
        letterSpacing: 0.5.px,
      ),
      css('&__metric-detail').styles(
        margin: .only(top: 0.3.rem),
        color: textMuted,
        fontSize: 0.75.rem,
        lineHeight: 1.45.em,
      ),
      css('&__core-skills').styles(
        display: .flex,
        flexDirection: .column,
        gap: Gap(row: 0.5.rem),
      ),
      css('&__core-skill').styles(
        display: .flex,
        padding: .symmetric(horizontal: 0.9.rem, vertical: 0.7.rem),
        border: .only(
          left: BorderSide.solid(color: accentViolet, width: 2.px),
        ),
        radius: .all(.circular(6.px)),
        flexWrap: .wrap,
        justifyContent: .spaceBetween,
        alignItems: .baseline,
        gap: Gap(row: 0.15.rem, column: 1.rem),
        backgroundColor: bgPanelSoft,
      ),
      css('&__core-skill-name').styles(color: textPrimary, fontSize: 0.95.rem),
      // The receipt for the claim to its left — muted, because the skill
      // name is what's being scanned for and the proof is what's read once
      // the scan stops.
      css('&__core-skill-proof').styles(color: accentCyan, fontSize: 0.8.rem),
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
        css('p').styles(
          margin: .only(top: 0.5.rem),
          color: textMuted,
        ),
        css('ul').styles(
          padding: .only(left: 1.1.rem),
          margin: .only(top: 0.75.rem),
          color: textMuted,
        ),
        css('li').styles(
          margin: .only(bottom: 0.35.rem),
          lineHeight: 1.5.em,
        ),
      ]),
      // Revali and Zonai are the work everything else orbits, so their cards
      // get the violet aurora treatment — a tinted border, a wash of the two
      // accent colors, and a larger title — to separate them from the
      // one-liner cards below without needing a "featured" badge to say so.
      css('&__card--featured', [
        css('&').styles(
          border: .all(color: .rgba(167, 139, 250, 0.35), width: 1.px),
          radius: .all(.circular(12.px)),
          raw: {
            'background-image': 'linear-gradient(160deg, rgba(94, 234, 212, 0.07), rgba(167, 139, 250, 0.07))',
            'box-shadow': '0 14px 40px rgba(167, 139, 250, 0.08)',
          },
        ),
        css('&:hover').styles(
          border: .all(color: .rgba(167, 139, 250, 0.6), width: 1.px),
        ),
        css('h3').styles(fontSize: 1.35.rem),
      ]),
      // Written out in full ('p.resume__status') rather than as '&__status'
      // on purpose. '&__card' above sets '.resume__card p { color: muted }'
      // at specificity (0,1,1), which outranks a lone class at (0,1,0) — so
      // the short form lost and these rendered grey. Nested here the full
      // form compiles to '.resume p.resume__status' at (0,2,1), which wins.
      // '&' can't do this: jaspr only substitutes it at the start of a
      // selector, so 'p&__status' emits a literal '&' and breaks the rule.
      // Same for the two rules below.
      css('p.resume__status').styles(
        margin: .only(top: 0.4.rem),
        color: accentAmber,
        fontSize: 0.8.rem,
        letterSpacing: 0.5.px,
      ),
      css('&__project-links', [
        css('&').styles(
          display: .flex,
          margin: .only(top: 0.9.rem),
          flexWrap: .wrap,
          gap: Gap(column: 1.rem),
        ),
        // The standalone link on a plain card spaces itself; inside this row
        // the row owns the spacing.
        css('a').styles(margin: .zero),
      ]),
      // The store listing is the proof these cards exist to offer, so they
      // get the same cyan-tinted lift the featured project cards get — just
      // in cyan rather than violet, to keep "shipped at work" visually
      // distinct from "flagship open source" further down the page.
      css('&__app', [
        css('&').styles(
          border: .all(color: .rgba(94, 234, 212, 0.3), width: 1.px),
          raw: {'background-image': 'linear-gradient(160deg, rgba(94, 234, 212, 0.07), rgba(167, 139, 250, 0.05))'},
        ),
        css('&:hover').styles(
          border: .all(color: .rgba(94, 234, 212, 0.6), width: 1.px),
        ),
      ]),
      css('&__app-head').styles(
        display: .flex,
        flexWrap: .wrap,
        alignItems: .center,
        gap: Gap(row: 0.5.rem, column: 0.9.rem),
      ),
      // Fixed rather than max-width so the two cards' titles line up at the
      // same x even though the icons are different aspect-ratio sources.
      css('&__app-icon').styles(
        width: 56.px,
        height: 56.px,
        border: .all(color: borderSubtle, width: 1.px),
        radius: .all(.circular(13.px)),
      ),
      // Takes the slack so the period stays pinned to the right edge, and
      // wraps under the icon rather than squeezing on narrow screens.
      css('&__app-title').styles(
        display: .flex,
        minWidth: 10.rem,
        flexDirection: .column,
        gap: Gap(row: 0.15.rem),
        flex: Flex(grow: 1, shrink: 1, basis: .auto),
      ),
      css('&__app-store-name').styles(color: textDim, fontSize: 0.8.rem),
      // Reads as a button, unlike the plain text links on project cards —
      // these are the one thing on the card a visitor is meant to tap.
      css('&__store-link', [
        css('&').styles(
          padding: .symmetric(horizontal: 0.9.rem, vertical: 0.45.rem),
          border: .all(color: .rgba(94, 234, 212, 0.35), width: 1.px),
          radius: .all(.circular(999.px)),
          transition: Transition.combine([
            Transition('border-color', duration: durFast),
            Transition('background-color', duration: durFast),
          ]),
          color: accentCyan,
          fontSize: 0.85.rem,
          textDecoration: TextDecoration(line: .none),
          backgroundColor: bgPanelSoft,
        ),
        css('&:hover').styles(
          border: .all(color: accentCyan, width: 1.px),
          backgroundColor: .rgba(94, 234, 212, 0.12),
        ),
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
      css('p.resume__card-role').styles(
        margin: .only(top: 0.35.rem),
        color: accentCyan,
        fontSize: 0.9.rem,
      ),
      // The scope-in-one-line under each job title. Amber (not the card's
      // cyan role text) so the numbers separate from the job title rather
      // than reading as a second line of it.
      css('p.resume__card-headline').styles(
        margin: .only(top: 0.3.rem),
        color: accentAmber,
        fontSize: 0.82.rem,
        letterSpacing: 0.3.px,
      ),
      css('&__project-link').styles(
        display: .inlineBlock,
        margin: .only(top: 0.75.rem),
        color: accentCyan,
        fontSize: 0.85.rem,
        textDecoration: TextDecoration(line: .none),
      ),
      css('&__skills').styles(
        display: .flex,
        flexDirection: .column,
        gap: Gap(row: 1.rem),
      ),
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
      css('&__skill-items').styles(
        display: .flex,
        flexWrap: .wrap,
        gap: Gap(row: 0.5.rem, column: 0.5.rem),
      ),
      css('&__pill').styles(
        padding: .symmetric(horizontal: 0.75.rem, vertical: 0.3.rem),
        border: .all(color: borderSubtle, width: 1.px),
        radius: .all(.circular(999.px)),
        color: textPrimary,
        fontSize: 0.85.rem,
      ),
    ]),
    // Makes "print to PDF" produce an actual resume.
    //
    // web/resume.pdf is a Figma export maintained by hand, so it goes stale
    // every time the data files here change. This doesn't replace it — it
    // gives the site a version that can't go stale, because it's rendered
    // from the same data as the page.
    //
    // Everything below is undoing the screen design rather than decorating:
    // the dark glass panel, the translucent fills and the aurora accents all
    // assume a near-black backdrop, and on white they range from washed out
    // to genuinely invisible.
    css.media(const MediaQuery.print(), [
      css('.resume', [
        css('&').styles(
          maxWidth: 100.percent,
          padding: .zero,
          margin: .zero,
          backdropFilter: Filter.none,
          color: printInk,
          backgroundColor: printPaper,
          raw: {'-webkit-backdrop-filter': 'none'},
        ),
        // A link back to a terminal is meaningless once this is on paper.
        css('&__back').styles(display: .none),
        // The h1 paints its gradient *through* the text with a transparent
        // fill, which prints as nothing at all — the name would be missing
        // from the top of the page. Put the ink back before anything else.
        css('h1').styles(
          color: printInk,
          raw: {'background': 'none', '-webkit-text-fill-color': printInkHex},
        ),
        css('&__role').styles(color: printInkSoft),
        css('&__tagline').styles(color: printAccent),
        css('&__links a').styles(color: printInk),
        css('h2').styles(color: printAccent),
        css('p').styles(color: printInkSoft),
        // Cards are the natural unit to keep whole — a job or an app split
        // across a page boundary is the one break worth spending paper to
        // avoid.
        css('&__card').styles(
          border: .all(color: printRule, width: 1.px),
          backgroundColor: printPaper,
          raw: {'background-image': 'none', 'box-shadow': 'none', 'break-inside': 'avoid'},
        ),
        css('&__card ul').styles(color: printInkSoft),
        css('&__metric').styles(
          border: .all(color: printRule, width: 1.px),
          backgroundColor: printPaper,
          raw: {'background-image': 'none'},
        ),
        css('&__metric-value').styles(color: printAccent),
        css('&__metric-label').styles(color: printInk),
        css('&__metric-detail').styles(color: printInkSoft),
        css('&__core-skill').styles(backgroundColor: printPaper),
        css('&__core-skill-name').styles(color: printInk),
        css('&__core-skill-proof').styles(color: printAccent),
        css('&__pill').styles(border: .all(color: printRule, width: 1.px), color: printInk),
        css('&__skill-label').styles(color: printInkSoft),
        css('&__app').styles(border: .all(color: printRule, width: 1.px), raw: {'background-image': 'none'}),
        css('&__app-store-name').styles(color: printInkSoft),
        css('&__store-link').styles(
          border: .all(color: printRule, width: 1.px),
          color: printAccent,
          backgroundColor: printPaper,
        ),
        css('&__project-link').styles(color: printAccent),
        css('p.resume__status').styles(color: printAccentWarm),
        css('p.resume__card-role').styles(color: printAccent),
        css('p.resume__card-headline').styles(color: printAccentWarm),
        css('&__period').styles(color: printInkSoft),
        css('&__stars').styles(color: printAccentWarm),
      ]),
    ]),
  ];
}

const accentCyanHex = '#5eead4';
const accentVioletHex = '#a78bfa';

// -- Print ink ------------------------------------------------------------
//
// The screen palette is built for a near-black backdrop and none of it
// survives on white: accentCyan (#5eead4) is barely visible, textMuted
// (#8b93a7) drops below readable contrast, and textDim is worse. These are
// the same hues taken far enough down in lightness to hold up in ink.
const printPaper = Color('#ffffff');
const printInkHex = '#111827';
const printInk = Color(printInkHex);
const printInkSoft = Color('#374151');
const printRule = Color('#d1d5db');
const printAccent = Color('#0f766e');
const printAccentWarm = Color('#92400e');
