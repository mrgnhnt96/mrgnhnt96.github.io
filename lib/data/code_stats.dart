/// Lines of code written, counted rather than estimated.
///
/// Measured with `scc` over shallow clones of all 94 non-fork repositories
/// on the account. The count is deliberately conservative — it is
/// hand-written source only, and excludes:
///
///  - generated Dart (`.g.dart`, `.freezed.dart`, `.mocks.dart`, …)
///  - built output (doc-site HTML, compiled `.dart.js`, `build/`, `dist/`)
///  - vendored code (`node_modules/`, `vendor/`, `Pods/`, editor plugins)
///  - lock files, search indexes, and data blobs
///  - config and prose (YAML, JSON, Markdown, licenses)
///
/// Counting everything would have yielded ~2.58M. The point of the number
/// is that it holds up when somebody asks how it was derived, so the
/// generated 1.03M is left out.
///
/// Not auto-pulled like [pub_stats] or [github_stats]: recounting means
/// cloning ~0.7GB of repositories, which is far too much work to do on
/// every deploy for a figure that moves this slowly. Re-run the count by
/// hand when it drifts enough to matter.
library;

/// Hand-written source across every non-fork repo on the account.
/// 459,792 of these are Dart.
const personalCodeLines = 554324;

/// The Couchsurfing Flutter app, architected from an empty repo.
const couchsurfingCodeLines = 1300000;

/// Everything above, which is what the headline figure reports.
const totalCodeLines = personalCodeLines + couchsurfingCodeLines;
