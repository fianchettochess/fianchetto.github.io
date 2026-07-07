# Docs deploy (GitHub Actions)

`fianchettochess.app` is deployed by `.github/workflows/deploy-docs.yml`. On each
push (plus a daily schedule and a manual **Run workflow** button), it:

1. Checks out this repo **and** the four package repos (ChessCore, BoardKit,
   SwiftStockfish, SwiftReckless).
2. Installs `mkdocs-material` and runs `build-docs.sh`, which builds each
   package's `docs-site/` into `docs/<package>/`.
3. Deploys the assembled site (the hand-written HTML/CSS + the aggregated
   `docs/`) to GitHub Pages.

Each package owns its own `docs-site/` (the source of truth). To publish a docs
change, push it to that package repo — the daily run (or a manual **Run
workflow**) picks it up. For an immediate rebuild, either click **Run workflow**
here, or have the package repo POST a `repository_dispatch` of type
`docs-updated` to this repo.

## One-time setup

1. **Token for the private package repos.** The workflow reads the four package
   repos, which are private, so it needs a token:
   - Create a **fine-grained personal access token** with **Contents: Read-only**
     on `jaredbrewer/ChessCore`, `BoardKit`, `SwiftStockfish`, `SwiftReckless`.
   - Add it as a repository secret named **`DOCS_PACKAGES_TOKEN`**
     (Settings → Secrets and variables → Actions).
   - *When those repos become public,* delete the `token:` lines from the four
     checkout steps and remove the secret — the default checkout can read public
     repos.

2. **Point Pages at Actions.** Settings → Pages → **Source: GitHub Actions**
   (instead of "Deploy from a branch").

Once both are done, the next push deploys via CI. The built `docs/<package>/`
directories currently committed to this repo become redundant (CI regenerates
them each deploy) and can be removed + git-ignored.

## Rebuilding locally

```sh
pip install mkdocs-material
MKDOCS="$(command -v mkdocs)" ./build-docs.sh   # → docs/<package>/
```
