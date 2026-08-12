/// Lines of code written, counted rather than estimated.
///
/// Measured with `scc` over shallow clones of all 94 non-fork repositories
/// on the account. Counts real source authored in this account's projects,
/// including generated Dart (`.g.dart`, `.freezed.dart`) — that code is
/// produced by builders configured and largely written here, so it's part
/// of the body of work rather than someone else's.
///
/// Still excluded, because none of it was authored here at all:
///
///  - built output (doc-site HTML, compiled `.dart.js`, `build/`, `dist/`)
///  - vendored third-party code (`node_modules/`, `vendor/`, `Pods/`,
///    editor plugins, a checked-in copy of Vue)
///  - lock files, search indexes, and data blobs
///  - config and prose (YAML, JSON, Markdown, licenses)
///
/// Counting those too would reach ~2.58M, but the number needs to hold up
/// when somebody asks how it was derived.
///
/// Not auto-pulled like [pub_stats] or [github_stats]: recounting means
/// cloning ~0.7GB of repositories, which is far too much work to do on
/// every deploy for a figure that moves this slowly. Re-run the count by
/// hand when it drifts enough to matter.
library;

/// Source across every non-fork repo on the account.
/// 938,142 of these are Dart.
const personalCodeLines = 1032674;

/// The Couchsurfing Flutter app, architected from an empty repo.
const couchsurfingCodeLines = 1300000;

/// Everything above, which is what the headline figure reports.
const totalCodeLines = personalCodeLines + couchsurfingCodeLines;
