# Docs build & publish

`fianchettochess.app` is served by **GitHub Pages "Deploy from a branch"** (this
repo is private, so Pages-from-Actions isn't available on the current plan). The
site's own HTML/CSS is committed directly. The package docs under `docs/` are
built from each package's `docs-site/` (the source of truth) and committed here;
branch-serving then publishes them.

Five doc sets are aggregated: ChessCore, BoardKit, SwiftStockfish, SwiftReckless
— each its own repo with `docs-site/` at the root — and **FianchettoKit**, which
is *not* its own repo. It is a package inside the `fianchetto` app repo, so its
docs live at `FianchettoKit/docs-site`; `build-docs.sh` entries take an optional
third field for that nested path.

## Keeping the docs current

- **Automated** — `.github/workflows/rebuild-docs.yml` checks out the package
  repos, runs `build-docs.sh`, and **commits the rebuilt `docs/` back**.
  It runs daily, on a manual **Run workflow**, and on a `repository_dispatch` of
  type `docs-updated`. (Not on push — a source-only push doesn't change the
  package docs.) After changing a package's docs, click **Run workflow** here (or
  wait for the daily run).
- **Manual / local** —
  ```sh
  pip install mkdocs-material
  MKDOCS="$(command -v mkdocs)" ./build-docs.sh    # → docs/<package>/
  git add docs/ && git commit -m "docs: rebuild" && git push
  ```

## Setup

1. **`DOCS_PACKAGES_TOKEN`** — the workflow reads the *private* package repos,
   so it needs a token: a fine-grained PAT with **Contents: Read-only** covering
   `fianchettochess/{ChessCore,BoardKit,SwiftStockfish,SwiftReckless,fianchetto}`.
   The live token is scoped to **all repositories** in the org, which satisfies
   this.

   The `fianchetto` grant is what lets FianchettoKit's docs be aggregated. Note
   that the app repo's `docs/CI_RUNBOOK.md` §4d still describes the older
   "Only select repositories" over the four sibling packages — that text is
   stale and should be updated to match the all-repositories scope.

   If that checkout ever does fail (expiry, re-scoping), the rebuild degrades
   rather than collapsing: the other four packages still build and commit, the
   job summary says what was skipped, and a final `Require FianchettoKit` step
   fails the job so it is loud.

   It lives as an **org-level** secret at
   github.com/organizations/fianchettochess/settings/secrets/actions (not a repo
   secret here) so it is shared with the Fianchetto app CI without duplication —
   both the app's sibling checkout and this docs rebuild use the same
   `DOCS_PACKAGES_TOKEN`. The workflow pushes the commit-back with the default
   `GITHUB_TOKEN` (`contents: write`).
2. **Pages source** — Settings → Pages → **Deploy from a branch** (the default).
   If you switched it to "GitHub Actions" earlier, switch it back — that mode
   can't deploy from a private repo on this plan.

## If you later make this repo public

Pages-from-Actions becomes available. At that point a build-and-deploy workflow
(no commit-back) is cleaner: build the site + `docs/` into an artifact and
`actions/deploy-pages` it, so no built output is committed. Ask and I'll switch
to that model.
