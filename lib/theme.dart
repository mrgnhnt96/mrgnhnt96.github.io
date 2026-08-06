/// Design tokens for the site. Dark, glassy, "premium terminal" — not retro
/// green-phosphor CRT. Cyan + violet aurora accents on near-black.
library;

import 'package:jaspr/dom.dart';

// -- Colors -------------------------------------------------------------

const bgVoid = Color('#07080c');
const Color bgPanel = .rgba(15, 17, 26, 0.8);
const Color bgPanelSoft = .rgba(15, 17, 26, 0.5);

const Color borderSubtle = .rgba(255, 255, 255, 0.08);
const Color borderStrong = .rgba(255, 255, 255, 0.16);

const accentCyan = Color('#5eead4');
const accentViolet = Color('#a78bfa');
const accentAmber = Color('#fbbf24');
const accentDanger = Color('#f87171');

const textPrimary = Color('#e6e9f0');
const textMuted = Color('#8b93a7');
const textDim = Color('#4b5468');

// -- Typography -----------------------------------------------------------

const monoFont = FontFamily('JetBrains Mono');

const FontFamily fontStack = .list([monoFont, FontFamilies.monospace]);

// -- Motion -----------------------------------------------------------------

const durFast = Duration(milliseconds: 150);
const durBase = Duration(milliseconds: 300);
const durSlow = Duration(milliseconds: 600);

/// Snappy "ease-out-expo"-ish curve for UI transitions (panels, mode switch).
const curveSnappy = Curve.cubicBezier(0.16, 1, 0.3, 1);

/// A count large enough to read as "infinite" looping without hitting the
/// `animation-iteration-count: infinite` keyword (Jaspr's `Animation.count`
/// renders `double.infinity` as the literal string "infinity", which CSS
/// does not recognize — so we loop a very large but finite number of times).
const double loopForever = 999999;
