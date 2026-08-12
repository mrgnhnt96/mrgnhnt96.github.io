/// GitHub activity totals for the trailing 12 months.
///
/// Overwritten by `.github/workflows/deploy.yml` before each build, which
/// pulls them from the GitHub GraphQL API. The values below are only the
/// local/fallback defaults used for `jaspr serve` and when the CI fetch
/// fails.
///
/// `contributionsCollection` is a rolling one-year window, so these move on
/// their own — which is exactly why they're pulled rather than typed in.
const ghContributionsLastYear = 5516;
const ghCommitsLastYear = 3461;
const ghReviewsLastYear = 1497;

/// Public, non-fork repositories owned by the account — the ones a visitor
/// can actually go read. Deliberately excludes forks (which cost nothing to
/// create) and private repos (which nobody can verify).
const ghPublicRepos = 64;
