# Docs build & publish

`fianchettochess.app` is served by **GitHub Pages "Deploy from a branch"** (this
repo is private, so Pages-from-Actions isn't available on the current plan). The
site's own HTML/CSS is committed directly. The four package docs under `docs/`
are built from each package's `docs-site/` (the source of truth) and committed
here; branch-serving then publishes them.

## Keeping the docs current

- **Automated** — `.github/workflows/rebuild-docs.yml` checks out the four
  package repos, runs `build-docs.sh`, and **commits the rebuilt `docs/` back**.
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

1. **`DOCS_PACKAGES_TOKEN`** — the workflow reads the four *private* package
   repos, so it needs a token: a fine-grained PAT with **Contents: Read-only** on
   `fianchettochess/{ChessCore,BoardKit,SwiftStockfish,SwiftReckless}`, added as a
   repository secret (Settings → Secrets and variables → Actions). The workflow
   pushes the commit-back with the default `GITHUB_TOKEN` (`contents: write`).
2. **Pages source** — Settings → Pages → **Deploy from a branch** (the default).
   If you switched it to "GitHub Actions" earlier, switch it back — that mode
   can't deploy from a private repo on this plan.

## If you later make this repo public

Pages-from-Actions becomes available. At that point a build-and-deploy workflow
(no commit-back) is cleaner: build the site + `docs/` into an artifact and
`actions/deploy-pages` it, so no built output is committed. Ask and I'll switch
to that model.
