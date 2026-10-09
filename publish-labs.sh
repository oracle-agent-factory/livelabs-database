#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: bash publish-labs.sh <content-ref>" >&2
  exit 1
fi

publication_root="$(git rev-parse --show-toplevel)"
cd "$publication_root"
publication_branch="$(git branch --show-current)"
case "$publication_branch" in
  gh-pages|kvlocal/pages-update-*) ;;
  *) echo "Run this only on gh-pages or a kvlocal/pages-update-* branch." >&2; exit 1 ;;
esac
if [ -n "$(git status --porcelain)" ]; then
  echo "Commit or save existing changes before updating the publication." >&2
  exit 1
fi

content_commit="$(git rev-parse --verify "${1}^{commit}")"
for folder in agent-factory appgen; do
  if [ "$(git cat-file -t "${content_commit}:${folder}")" != tree ]; then
    echo "The content ref must contain both agent-factory and appgen folders." >&2
    exit 1
  fi
done

publication_snapshot="$(mktemp -d)"
trap 'rm -rf "$publication_snapshot"' EXIT
git archive "$content_commit" agent-factory appgen | tar -x -C "$publication_snapshot"
git rm -r --quiet -- agent-factory appgen
cp -R "$publication_snapshot/agent-factory" "$publication_snapshot/appgen" .
git add -- agent-factory appgen
echo "Updated all labs from $content_commit. Review, commit, and push this publishing branch."
