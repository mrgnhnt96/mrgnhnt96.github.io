/// Aggregate pub.dev download stats across every published package.
///
/// Overwritten by `.github/workflows/deploy.yml` before each build, which
/// sums `downloadCount30Days` across every package under the mrgnhnt.com,
/// revali.dev, and zonai.dev publishers. The workflow derives that list from
/// pub.dev rather than hard-coding it, so publishing a new package needs no
/// change here. The values below are only the local/fallback defaults used
/// for `jaspr serve` and when the CI fetch fails.
///
/// These are load-bearing numbers — they're the headline proof on the site —
/// so they're pulled fresh rather than hand-maintained and left to rot.
const pubDownloads30Days = 267675;
const pubPackageCount = 36;

/// Rounds [n] to a compact, honest display form: 208,903 -> '208K'.
///
/// Always rounds *down* to the displayed unit, so the number on screen is
/// never larger than the real one — a claim that drifts upward between
/// builds is the one kind of drift that actually matters here.
String compactCount(int n) {
  if (n >= 1000000) {
    final millions = n / 1000000;
    return '${millions.floor()}${_tenth(millions)}M';
  }
  if (n >= 1000) return '${n ~/ 1000}K';
  return '$n';
}

/// The `.x` in `1.3M`, dropped entirely when it would render as `.0`.
String _tenth(double value) {
  final tenth = ((value - value.floor()) * 10).floor();
  return tenth == 0 ? '' : '.$tenth';
}
