import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme.dart';

/// A fixed, full-viewport backdrop: three slow-drifting blurred "aurora"
/// blobs over a faint dot-grid, with a vignette to keep focus centered.
///
/// Pure CSS — no JS/hydration needed, so it paints immediately and degrades
/// perfectly with no client bundle cost.
class AmbientBackground extends StatelessComponent {
  const AmbientBackground({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'ambient-bg', [
      div(classes: 'ambient-bg__grid', []),
      div(classes: 'ambient-bg__blob ambient-bg__blob--a', []),
      div(classes: 'ambient-bg__blob ambient-bg__blob--b', []),
      div(classes: 'ambient-bg__blob ambient-bg__blob--c', []),
      div(classes: 'ambient-bg__vignette', []),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.ambient-bg', [
      css('&').styles(
        position: .fixed(top: .zero, left: .zero, right: .zero, bottom: .zero),
        overflow: .hidden,
        pointerEvents: .none,
        backgroundColor: bgVoid,
      ),
      css('&__grid').styles(
        position: .absolute(top: .zero, left: .zero, right: .zero, bottom: .zero),
        opacity: 0.7,
        raw: {
          'background-image': 'radial-gradient(circle, rgba(255,255,255,0.07) 1px, transparent 1.5px)',
          'background-size': '28px 28px',
        },
      ),
      css('&__blob', [
        css('&').styles(
          position: .absolute(),
          radius: .all(.circular(50.percent)),
          filter: .blur(70.px),
        ),
        css('&--a').styles(
          position: .absolute(top: (-15).percent, left: (-10).percent),
          width: 62.vw,
          height: 62.vw,
          opacity: 0.55,
          animation: Animation(
            name: 'aurora-drift-a',
            duration: Duration(seconds: 32),
            curve: .easeInOut,
            count: loopForever,
          ),
          raw: {
            'background-image': 'radial-gradient(circle at 50% 50%, rgba(94,234,212,0.9) 0%, rgba(94,234,212,0) 70%)',
          },
        ),
        css('&--b').styles(
          position: .absolute(bottom: (-20).percent, right: (-12).percent),
          width: 56.vw,
          height: 56.vw,
          opacity: 0.5,
          animation: Animation(
            name: 'aurora-drift-b',
            duration: Duration(seconds: 40),
            curve: .easeInOut,
            count: loopForever,
          ),
          raw: {
            'background-image': 'radial-gradient(circle at 50% 50%, rgba(167,139,250,0.9) 0%, rgba(167,139,250,0) 70%)',
          },
        ),
        css('&--c').styles(
          position: .absolute(top: 28.percent, left: 58.percent),
          width: 38.vw,
          height: 38.vw,
          opacity: 0.3,
          animation: Animation(
            name: 'aurora-drift-c',
            duration: Duration(seconds: 26),
            curve: .easeInOut,
            count: loopForever,
          ),
          raw: {
            'background-image': 'radial-gradient(circle at 50% 50%, rgba(251,191,36,0.8) 0%, rgba(251,191,36,0) 70%)',
          },
        ),
      ]),
      css('&__vignette').styles(
        position: .absolute(top: .zero, left: .zero, right: .zero, bottom: .zero),
        raw: {'background-image': 'radial-gradient(ellipse at center, transparent 35%, #07080c 100%)'},
      ),
    ]),
    css.keyframes('aurora-drift-a', {
      '0%': Styles(
        transform: .combine([.translate(x: (-4).percent, y: (-8).percent), .scale(1)]),
      ),
      '50%': Styles(
        transform: .combine([.translate(x: 4.percent, y: 6.percent), .scale(1.15)]),
      ),
      '100%': Styles(
        transform: .combine([.translate(x: (-4).percent, y: (-8).percent), .scale(1)]),
      ),
    }),
    css.keyframes('aurora-drift-b', {
      '0%': Styles(
        transform: .combine([.translate(x: 6.percent, y: 4.percent), .scale(1.1)]),
      ),
      '50%': Styles(
        transform: .combine([.translate(x: (-6).percent, y: (-5).percent), .scale(0.95)]),
      ),
      '100%': Styles(
        transform: .combine([.translate(x: 6.percent, y: 4.percent), .scale(1.1)]),
      ),
    }),
    css.keyframes('aurora-drift-c', {
      '0%': Styles(
        transform: .translate(x: 0.percent, y: 0.percent),
      ),
      '50%': Styles(
        transform: .translate(x: (-6).percent, y: 8.percent),
      ),
      '100%': Styles(
        transform: .translate(x: 0.percent, y: 0.percent),
      ),
    }),
    // The terminal panel covers nearly the whole screen on mobile, leaving
    // almost no margin for the aurora to show in, so the color has to read
    // through the terminal's own glass instead — meaning the blobs need to
    // reach the center of the screen, not just the corners. 'vw' alone
    // doesn't get them there on a tall, narrow phone (it ignores height
    // entirely), so these switch to 'vmax' and go much bigger.
    css.media(MediaQuery.screen(maxWidth: 640.px), [
      css('.ambient-bg__blob--a').styles(
        width: Unit.expression('150vmax'),
        height: Unit.expression('150vmax'),
        opacity: 0.85,
      ),
      css('.ambient-bg__blob--b').styles(
        width: Unit.expression('140vmax'),
        height: Unit.expression('140vmax'),
        opacity: 0.8,
      ),
      css('.ambient-bg__blob--c').styles(
        width: Unit.expression('100vmax'),
        height: Unit.expression('100vmax'),
        opacity: 0.6,
      ),
      css('.ambient-bg__vignette').styles(
        raw: {'background-image': 'radial-gradient(ellipse at center, transparent 55%, rgba(7,8,12,0.75) 100%)'},
      ),
    ]),
  ];
}
