#!/usr/bin/env bash
set -euo pipefail

DIR="${RECEIPTS_DIR:-$HOME/Downloads/経理/領収書}"
PLAN="${RECEIPTS_PLAN:-/tmp/receipts-rename-plan.tsv}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENDORS="${RECEIPTS_VENDORS:-$SCRIPT_DIR/vendors.tsv}"

[ -d "$DIR" ] || { echo "no such dir: $DIR" >&2; exit 1; }
cd "$DIR"
: > "$PLAN"

normalize() {
  local n="$1"
  n="${n//のコピー/}"
  n="${n// _ /_}"
  n="${n//｜/_}"
  n="${n//－/-}"
  n="${n//–/-}"
  n="${n//（/_}"
  n="${n//）/_}"
  n=$(printf '%s' "$n" | sed -E 's/\[[0-9]+\]//g')
  n=$(printf '%s' "$n" | sed -E 's/ \(([0-9]+)\)/_v\1/g')
  n="${n// /_}"
  n=$(printf '%s' "$n" | sed -E 's/_+/_/g; s/_\././g; s/^_//; s/_$//')
  printf '%s' "$n"
}

extract_date() {
  local f="$1"
  if [[ "$f" =~ ^([0-9]{8}) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    stat -f '%Sm' -t '%Y%m%d' "$f"
  fi
}

strip_noise_words() {
  local n="$1"
  local i
  for i in 1 2 3; do
    # receipt/Receipt は _ 区切りのみ（Receipt-XXXX は識別子）
    n=$(printf '%s' "$n" | sed -E 's/(^|_)(receipt|Receipt)(_|$)/\1\3/g')
    # その他は _ も - も区切りとして扱う
    n=$(printf '%s' "$n" | sed -E 's/(^|[_-])(領収書|Your|your|Order|order)([_-]|$)/\1\3/g')
  done
  n=$(printf '%s' "$n" | sed -E 's/_+/_/g; s/^_//; s/_$//')
  printf '%s' "$n"
}

cleanup_seps() {
  local n="$1"
  n=$(printf '%s' "$n" | sed -E 's/_-_/_/g; s/_-/_/g; s/-_/-/g; s/_+/_/g; s/^[_-]+//; s/[_-]+$//; s/_\./\./g')
  printf '%s' "$n"
}

vendor_match=""
vendor_canon=""
lookup_vendor() {
  local s="$1"
  vendor_match=""
  vendor_canon=""
  [ -f "$VENDORS" ] || return 1
  while IFS=$'\t' read -r pat canon; do
    [ -z "${pat:-}" ] && continue
    [[ "$pat" =~ ^# ]] && continue
    if [[ "$s" == *"$pat"* ]]; then
      vendor_match="$pat"
      vendor_canon="$canon"
      return 0
    fi
  done < "$VENDORS"
  return 1
}

while IFS= read -r f; do
  f="${f#./}"
  [ -z "$f" ] && continue
  case "$f" in .*) continue;; esac
  ext="${f##*.}"
  base="${f%.*}"
  norm=$(normalize "$base")
  date_p=$(extract_date "$f")

  rest="$norm"
  rest=$(printf '%s' "$rest" | sed -E 's/^[0-9]{8}_?//')
  rest=$(cleanup_seps "$rest")

  if lookup_vendor "$rest"; then
    rest="${rest//"$vendor_match"/}"
    rest=$(strip_noise_words "$rest")
    rest=$(cleanup_seps "$rest")
    if [ -n "$rest" ]; then
      new="${date_p}_${vendor_canon}_${rest}.${ext}"
    else
      new="${date_p}_${vendor_canon}.${ext}"
    fi
  else
    rest=$(strip_noise_words "$rest")
    rest=$(cleanup_seps "$rest")
    new="${date_p}_${rest}.${ext}"
  fi

  new=$(cleanup_seps "$new")

  if [ "$f" != "$new" ]; then
    printf '%s\t%s\n' "$f" "$new" >> "$PLAN"
  fi
done < <(find . -maxdepth 1 -type f ! -name '.*' | sort)

count=$(wc -l < "$PLAN" | tr -d ' ')
printf '\033[1m▶ plan:\033[0m %s (%s changes)\n\n' "$PLAN" "$count"
if [ "$count" -gt 0 ]; then
  awk -F'\t' '{printf "  %s\n    → %s\n", $1, $2}' "$PLAN" | head -120
  if [ "$count" -gt 60 ]; then
    echo "  ..."
  fi
fi
