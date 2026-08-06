import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Wraps a single terminal history entry with a fade + slide entrance.
///
/// Pure CSS animation baked into the inline style, so it plays on first
/// paint whether or not JS has hydrated yet — and, since each instance
/// keeps a stable [key], already-settled entries never replay when new
/// ones are appended above/below them.
class OutputLine extends StatelessComponent {
  const OutputLine({required this.child, required this.delayMs, super.key});

  final Component child;
  final int delayMs;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'term-line',
      styles: Styles(
        animation: Animation(
          name: 'term-line-in',
          duration: Duration(milliseconds: 260),
          curve: .easeOut,
          delay: Duration(milliseconds: delayMs),
          fillMode: .both,
        ),
      ),
      [child],
    );
  }
}

@css
List<StyleRule> get outputLineStyles => [
  css.keyframes('term-line-in', {
    '0%': Styles(opacity: 0, transform: .translate(y: 6.px)),
    '100%': Styles(opacity: 1, transform: .translate(y: 0.px)),
  }),
];
