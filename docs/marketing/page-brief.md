# Page brief

- Type and state: Personal, live. Two pages: `/` (terminal-style home) and `/resume/` (the readable
  résumé, fully static). `/resume.pdf` is the printable copy.
- Audience: hiring managers and recruiters looking at a senior Flutter/Dart hire, and Dart
  developers who know Morgan's packages. Most arrive from a name search, LinkedIn or GitHub.
- The page's one job: show who Morgan is and what he has shipped, then get the reader to the
  résumé or an email.
- Primary CTA: "Résumé" → `/resume/` (in the band on `/`, first screen at every width).
- Secondary action: "Email" → `mailto:mrgnhnt96@gmail.com`. GitHub sits beside it as a plain link.
- Search phrases: "Morgan Hunt", "Morgan Hunt Flutter", "mrgnhnt96", "staff Flutter engineer Mesa
  AZ", "Revali Dart framework".
- Objections: "I can't find the plain résumé" (answered by the Résumé link and `/resume/`); "are
  the numbers real?" (answered by the per-metric detail lines on `/resume/` and the claims below);
  "I don't want to type commands" (answered by the summary printed at boot and the mode toggle).
- Analytics and cookies: none. No analytics, tracking or cookies load on any page (checked in the
  source, the build and the live HTML on 2026-11-09). If any are added, a privacy page that
  matches them is required first.

The live site is built by `.github/workflows/deploy.yml`, which rewrites the pub.dev counts,
GitHub contribution total, public repo count and zonai version before building. A local
`jaspr build` uses the committed fallbacks, so its numbers can trail the live site.

## Claims

| Claim on the page | Evidence |
| --- | --- |
| What Morgan does: Staff Software Engineer, Dart and Flutter, Mesa, AZ | Owner's own description (`lib/data/profile.dart`) |
| N packages on pub.dev, N downloads a month | pub.dev API, summed over the mrgnhnt.com, revali.dev and zonai.dev publishers on every deploy (`deploy.yml`, `lib/data/pub_stats.dart`). Committed fallback: 36 packages, 267,675 downloads (30 days) |
| 2.3M lines written; 1M+ lines of his own code (938K Dart) | `scc` over shallow clones of the 94 non-fork repos, plus 1.3M for the Couchsurfing app (`lib/data/code_stats.dart`). Date of the count not recorded. The 1.3M part is the owner's figure |
| 64 public non-fork repositories | GitHub API on every deploy (`lib/data/github_stats.dart`) |
| 5,531 contributions in the last 12 months; 3,473 commits; 1,497 reviews | GitHub GraphQL; total auto-pulled on deploy, commits and reviews read by hand on 2026-08-12 (`lib/data/github_stats.dart`) |
| Clean Simple Eats 4.8★ across 5,700+ App Store ratings | App Store listing showed 4.8★ from 5,899 ratings on 2026-11-09 (beedle review) |
| Couchsurfing app 2023-2026, Clean Simple Eats app links | The App Store and Google Play listings linked from `/resume/` |
| Revali and Zonai: two backend frameworks | pub.dev and their docs sites, linked from the projects section |
| 25M+ users reached (Couchsurfing members) | Owner's word, no source on file. Couchsurfing's public pages don't state a member count |
| $1M+ annual revenue (Clean Simple Eats) | Owner's word, no source on file |
| 1.3M-line Couchsurfing app, architected from an empty repo | Owner's word, no source on file |
| Led a team of 9 engineers | Owner's word, no source on file |
| 5× growth, ~2K to 10K+ monthly active users | Owner's word, no source on file |
| 2,382 PRs reviewed, 947 shipped, 913 merged, 67 contributors, 13K+ PRs | Owner's word, no source on file (a query over the Couchsurfing monorepo would back it) |
| Two-week release cadence for 3.5 years | Owner's word, no source on file |
| 6 companies contracted, 52 months | Owner's word, no source on file |
| Three Flutter conference talks | Owner's word, no source on file (talk pages or recordings would back it) |
| 8+ years in Dart and Flutter | Owner's word, no source on file |

## Waiting on a person

- Morgan: give a source and date for each "Owner's word" row above (an employer statement,
  analytics or store export, a git or GitHub query, the talk pages), or drop the ones you can't
  back. Until then they stay on the page as your own statements about your own work.
- Morgan: confirm PostHog isn't meant to run here. The 2026-11-06 audit listed it, but nothing
  loads it in the source, the build or the live site.
- Morgan: decide whether the terminal look stays as is. The review counted several design tells
  (permanent dark mode with grey text, gradient H1 on `/resume/`, glows, stat row, all-caps
  labels, purple accents) and marked it as your call.
- Morgan, after deploy: verify the site in Google Search Console and Bing Webmaster Tools, submit
  `https://mrgnhnt.com/sitemap.xml`, and run the Rich Results Test on `https://mrgnhnt.com/`.
