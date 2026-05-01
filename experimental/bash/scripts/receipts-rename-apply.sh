#!/usr/bin/env bash
set -euo pipefail

DIR="${RECEIPTS_DIR:-$HOME/Downloads/経理/領収書}"
PLAN="${RECEIPTS_PLAN:-/tmp/receipts-rename-plan.tsv}"

[ -d "$DIR" ] || { echo "no such dir: $DIR" >&2; exit 1; }
[ -s "$PLAN" ] || { echo "no plan or empty: $PLAN" >&2; exit 1; }

cd "$DIR"

applied=0
skipped=0
errors=0
while IFS=$'\t' read -r old new; do
  [ -z "${old:-}" ] && continue
  if [ ! -e "$old" ]; then
    printf '  src missing: %s\n' "$old"
    skipped=$((skipped + 1))
    continue
  fi
  if [ -e "$new" ]; then
    printf '  dst exists: %s\n' "$new"
    skipped=$((skipped + 1))
    continue
  fi
  if mv -- "$old" "$new" 2>/dev/null; then
    printf '  → %s\n' "$new"
    applied=$((applied + 1))
  else
    printf '  mv failed: %s → %s\n' "$old" "$new"
    errors=$((errors + 1))
  fi
done < "$PLAN"

echo
printf 'applied: %d, skipped: %d, errors: %d\n' "$applied" "$skipped" "$errors"
