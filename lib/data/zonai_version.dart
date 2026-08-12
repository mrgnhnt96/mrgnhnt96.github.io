/// The latest zonai release tag.
///
/// Overwritten by `.github/workflows/deploy.yml` before each build, which
/// pulls the current value from the GitHub releases API. The value below is
/// only the local/fallback default used for `jaspr serve` and when the CI
/// fetch fails.
const zonaiVersion = 'v0.6.0';
