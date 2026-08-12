/// GitHub activity totals for the trailing 12 months.
///
/// Split by what CI can actually see. `.github/workflows/deploy.yml` runs as
/// `github-actions[bot]`, and the GraphQL contribution fields answer
/// differently depending on who is asking:
///
///  - `contributionCalendar.totalContributions` honours the account's
///    "include private contributions on my profile" setting, so the bot
///    reads the same figure the owner does. Safe to auto-pull.
///  - `totalCommitContributions` and `totalPullRequestReviewContributions`
///    only count contributions the *requesting token* can see. To the bot,
///    private-repo work is invisible: reviews collapse from 1,497 to 18.
///    Auto-pulling those would publish a number an order of magnitude too
///    small, so they are maintained by hand instead.
library;

/// Auto-pulled — rewritten by CI on every build. A rolling one-year window,
/// so it moves on its own even on days with no commits here.
const ghContributionsLastYear = 5531;

/// Auto-pulled — public, non-fork repositories owned by the account. These
/// are the ones a visitor can actually go read, so forks (which cost nothing
/// to create) and private repos (which nobody can verify) are excluded.
const ghPublicRepos = 64;

/// Hand-maintained — see the library doc above for why CI can't pull these.
/// Read with an authenticated token on 2026-08-12. Refresh with:
///
/// ```sh
/// gh api graphql -f query='{ user(login:"mrgnhnt96") { contributionsCollection {
///   totalCommitContributions totalPullRequestReviewContributions } } }'
/// ```
const ghCommitsLastYear = 3473;
const ghReviewsLastYear = 1497;
