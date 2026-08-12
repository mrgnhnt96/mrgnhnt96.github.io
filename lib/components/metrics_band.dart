import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/metrics.dart';
import '../data/profile.dart';
import '../theme.dart';

/// The always-visible proof bar above the terminal.
///
/// The terminal is the right first impression for the engineers who'll
/// appreciate it, but it hides everything behind a command prompt — a
/// recruiter who doesn't type anything sees no evidence at all. This puts
/// the four load-bearing numbers on screen unconditionally, before any
/// interaction, in both modes.
class MetricsBand extends StatelessComponent {
  const MetricsBand({super.key});

  @override
  Component build(BuildContext context) {
    return header(classes: 'band', [
      div(classes: 'band__identity', [
        span(classes: 'band__name', [.text(Profile.name)]),
        span(classes: 'band__role', [.text('${Profile.role} · ${Profile.location}')]),
      ]),
      dl(classes: 'band__metrics', [
        for (final metric in headlineMetrics)
          div(classes: 'band__metric', [
            dt(classes: 'band__value', [.text(metric.value)]),
            dd(classes: 'band__label', [.text(metric.label)]),
          ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.band', [
      css('&').styles(
        display: .flex,
        width: 100.percent,
        maxWidth: 720.px,
        padding: .symmetric(horizontal: 1.25.rem, vertical: 1.rem),
        margin: .only(bottom: 1.rem),
        boxSizing: .borderBox,
        border: .all(color: .rgba(167, 139, 250, 0.28), width: 1.px),
        radius: .all(.circular(14.px)),
        backdropFilter: .blur(18.px),
        flexWrap: .wrap,
        justifyContent: .spaceBetween,
        alignItems: .center,
        gap: Gap(row: 0.9.rem, column: 1.25.rem),
        fontFamily: fontStack,
        backgroundColor: bgPanel,
        raw: {
          'background-image': 'linear-gradient(140deg, rgba(94, 234, 212, 0.07), rgba(167, 139, 250, 0.09))',
          '-webkit-backdrop-filter': 'blur(18px)',
        },
      ),
      css('&__identity').styles(
        display: .flex,
        flexDirection: .column,
        gap: Gap(row: 0.2.rem),
      ),
      css('&__name').styles(
        color: textPrimary,
        fontSize: 1.05.rem,
        fontWeight: .bold,
        letterSpacing: 0.5.px,
      ),
      css('&__role').styles(color: textMuted, fontSize: 0.78.rem),
      css('&__metrics').styles(
        display: .flex,
        margin: .zero,
        flexWrap: .wrap,
        gap: Gap(row: 0.75.rem, column: 1.6.rem),
      ),
      css('&__metric').styles(
        display: .flex,
        flexDirection: .column,
        gap: Gap(row: 0.1.rem),
      ),
      // <dt>/<dd> carry the semantics (these really are term/definition
      // pairs), but the number is the thing to read first — so the visual
      // hierarchy is inverted relative to the default styling.
      css('&__value').styles(
        color: accentCyan,
        fontSize: 1.3.rem,
        fontWeight: .bold,
        lineHeight: 1.1.em,
      ),
      css('&__label').styles(
        margin: .zero,
        color: textDim,
        fontSize: 0.68.rem,
        textTransform: .upperCase,
        letterSpacing: 0.5.px,
      ),
    ]),
    // The band sits above a terminal that wants the whole screen on mobile,
    // so it gets meaningfully tighter rather than eating a third of the
    // viewport. The identity block drops out entirely — 'whoami' is the
    // first thing the terminal prints anyway, so it's pure duplication at
    // exactly the width where space is scarcest.
    css.media(MediaQuery.screen(maxWidth: 640.px), [
      css('.band').styles(
        padding: .symmetric(horizontal: 0.75.rem, vertical: 0.6.rem),
        // Clears the mode toggle, which is 'position: fixed' at the top
        // right and would otherwise sit on top of the metrics. On desktop
        // the band is narrow enough that they never meet.
        margin: .only(top: 2.4.rem, bottom: 0.5.rem),
        radius: .all(.circular(10.px)),
      ),
      css('.band__identity').styles(display: .none),
      // A 2x2 grid rather than a wrapping flex row: 'minmax(0, 1fr)' lets
      // the columns shrink below their content width, so a long label like
      // 'PACKAGE DOWNLOADS' wraps inside its cell instead of pushing the
      // last metric off the side of the screen.
      css('.band__metrics').styles(
        display: .grid,
        width: 100.percent,
        gap: Gap(row: 0.5.rem, column: 0.6.rem),
        raw: {'grid-template-columns': 'repeat(2, minmax(0, 1fr))'},
      ),
      css('.band__metric').styles(minWidth: 0.px),
      css('.band__value').styles(fontSize: 1.05.rem),
      css('.band__label').styles(fontSize: 0.58.rem, letterSpacing: 0.px),
    ]),
  ];
}
