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
#
# FianchettoKit joined this list on 2026-08-22. It always had a docs-site/, but
# it was a directory inside the application monorepo rather than a repository,
# so it could never be checked out as a sibling and its documentation was not
# served. The four-way split made it a package like the others.
#
# FianchettoKit is SUPPRESSED as of 2026-09-07 and is the one package here whose
# repository is still private, so its docs describe a package a reader cannot
# obtain. Restore it by uncommenting the line below AND the matching checkout
# step in .github/workflows/rebuild-docs.yml — the two must move together, since
# a listed package that is not checked out is a hard build failure by design.
PACKAGES=(
  "ChessCore:chesscore"
  "BoardKit:boardkit"
# "FianchettoKit:fianchettokit"   # suppressed — see the note above
  "SwiftStockfish:swiftstockfish"
  "SwiftReckless:swiftreckless"
)

command -v "$MKDOCS" >/dev/null 2>&1 || { echo "error: mkdocs not found (set MKDOCS=...)" >&2; exit 1; }

for entry in "${PACKAGES[@]}"; do
  pkg="${entry%%:*}"
  sub="${entry##*:}"
  src="$SIBLINGS/$pkg/docs-site"
  # A LISTED PACKAGE MUST BUILD. This used to warn and `continue`, which meant
  # a missing checkout dropped an entire documentation section from the site
  # while the build still reported success and published the result — the
  # visible symptom being a 404 nobody goes looking for. The list above IS the
  # declaration of what this site serves, so an entry that cannot be built is a
  # failure; to stop serving a package, delete its line.
  if [[ ! -f "$src/mkdocs.yml" ]]; then
    echo "error: $pkg is listed in PACKAGES but has no docs-site/mkdocs.yml at $src" >&2
    echo "       Check the sibling checkout, or remove the entry if it should no longer be served." >&2
    exit 1
  fi
  echo "→ building $pkg → docs/$sub/"
  ( cd "$src" && "$MKDOCS" build --clean -d "$HERE/docs/$sub" )
done

echo "✓ docs aggregated under $HERE/docs/"
