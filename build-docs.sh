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

# package-repo-dir  ->  /docs/<subpath>
PACKAGES=(
  "ChessCore:chesscore"
  "BoardKit:boardkit"
  "SwiftStockfish:swiftstockfish"
  "SwiftReckless:swiftreckless"
)

command -v "$MKDOCS" >/dev/null 2>&1 || { echo "error: mkdocs not found (set MKDOCS=...)" >&2; exit 1; }

for entry in "${PACKAGES[@]}"; do
  pkg="${entry%%:*}"
  sub="${entry##*:}"
  src="$SIBLINGS/$pkg/docs-site"
  if [[ ! -f "$src/mkdocs.yml" ]]; then
    echo "⚠ skip $pkg — no docs-site/mkdocs.yml at $src" >&2
    continue
  fi
  echo "→ building $pkg → docs/$sub/"
  ( cd "$src" && "$MKDOCS" build --clean -d "$HERE/docs/$sub" )
done

echo "✓ docs aggregated under $HERE/docs/"
