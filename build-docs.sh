#!/usr/bin/env bash
#
# build-docs.sh — aggregate the constituent packages' MkDocs docs into
# ./docs/<package>/ so they're served under fianchettochess.app/docs/.
#
# Each package owns its own docs-site/ (MkDocs Material, the source of truth);
# this script builds each into a subdirectory of this repo. The built HTML uses
# relative links, so it serves correctly under the /docs/<package>/ subpath.
#
# Usage (run from the repo root, with the sibling package repos checked out):
#   ./build-docs.sh
#
# Requirements: mkdocs + mkdocs-material. Point MKDOCS at your install, e.g.:
#   MKDOCS=/path/to/venv/bin/mkdocs ./build-docs.sh
# Override the sibling-repos root (default: the parent of this repo) with SIBLINGS.
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
MKDOCS="${MKDOCS:-mkdocs}"
SIBLINGS="${SIBLINGS:-$(cd "$HERE/.." && pwd)}"

# checkout-dir : /docs/<subpath> [: docs-site path within the checkout [: optional]]
#
# Field 3 defaults to "docs-site" (a standalone package repo whose docs-site
# sits at its root).  FianchettoKit is not its own repo — it is a package
# inside the Fianchetto app repo — so it states its nested path.
#
# Field 4 = "optional" means an ABSENT checkout is tolerated (warn and skip,
# script still succeeds).  FianchettoKit is optional because reading the app
# repo needs a DOCS_PACKAGES_TOKEN grant that CI_RUNBOOK §4d does not yet
# include; until it lands, its checkout fails and the other four must still
# publish.  A package that IS present but fails to BUILD is never tolerated,
# optional or not.
PACKAGES=(
  "ChessCore:chesscore"
  "BoardKit:boardkit"
  "SwiftStockfish:swiftstockfish"
  "SwiftReckless:swiftreckless"
  "Fianchetto:fianchettokit:FianchettoKit/docs-site:optional"
)

command -v "$MKDOCS" >/dev/null 2>&1 || { echo "error: mkdocs not found (set MKDOCS=...)" >&2; exit 1; }

# Each package builds into a staging directory and is swapped into docs/ only
# on success.  Two reasons: `mkdocs build --clean` wipes its destination before
# writing, so building straight into docs/<pkg>/ turns any mid-build failure
# into a half-published (or empty) doc set; and under `set -e` a failing build
# would abort the whole loop, so one bad package would discard every package
# built after it.  Here a failure leaves the previous good output untouched,
# the remaining packages still build, and the script exits non-zero at the end
# so the failure is loud rather than silent.
STAGE="$HERE/.build-tmp"
rm -rf "$STAGE"
mkdir -p "$STAGE"
trap 'rm -rf "$STAGE"' EXIT

failed=""
built=""
skipped=""

for entry in "${PACKAGES[@]}"; do
  IFS=':' read -r pkg sub docs_rel opt <<<"$entry"
  docs_rel="${docs_rel:-docs-site}"
  opt="${opt:-}"
  src="$SIBLINGS/$pkg/$docs_rel"
  if [[ ! -f "$src/mkdocs.yml" ]]; then
    if [[ "$opt" == "optional" ]]; then
      echo "⚠ skip $pkg (optional) — not checked out; no mkdocs.yml at $src" >&2
      skipped="$skipped $pkg"
    else
      echo "⚠ $pkg — no mkdocs.yml at $src" >&2
      failed="$failed $pkg(missing)"
    fi
    continue
  fi
  echo "→ building $pkg → docs/$sub/"
  if ( cd "$src" && "$MKDOCS" build --clean -d "$STAGE/$sub" ); then
    rm -rf "${HERE:?}/docs/$sub"
    mv "$STAGE/$sub" "$HERE/docs/$sub"
    built="$built $sub"
  else
    echo "⚠ $pkg — mkdocs build FAILED; keeping the previous docs/$sub/" >&2
    rm -rf "$STAGE/$sub"
    failed="$failed $pkg(build)"
  fi
done

echo "✓ built:${built:- none}"
if [[ -n "${skipped// /}" ]]; then
  echo "⚠ skipped (optional, not checked out):$skipped" >&2
fi
if [[ -n "${failed// /}" ]]; then
  echo "✗ FAILED:$failed" >&2
  exit 1
fi
echo "✓ docs aggregated under $HERE/docs/"
