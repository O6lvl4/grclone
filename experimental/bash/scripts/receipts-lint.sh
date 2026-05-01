#!/usr/bin/env bash
set -euo pipefail
DIR="${1:-$HOME/Downloads/経理/領収書}"

if [ ! -d "$DIR" ]; then
  echo "no such dir: $DIR" >&2
  exit 1
fi

cd "$DIR"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }

bold "▶ ${DIR}"
total=$(find . -maxdepth 1 -type f ! -name '.*' | wc -l | tr -d ' ')
echo "  total: ${total}"
echo

bold "[1] 日付プレフィックス無し"
out=$(find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | grep -vE '^[0-9]{8}_' || true)
[ -n "$out" ] && echo "$out" | sed 's/^/  /' || echo "  (none)"
echo

bold "[2] 冗長な二重日付（期間/IDを除く）"
out=$(find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | awk '{
  s = $0
  gsub(/[0-9]{8}-[0-9]{8}/, "", s)        # 期間: YYYYMMDD-YYYYMMDD
  gsub(/[0-9]{8}_to_[0-9]{8}/, "", s)     # 期間: YYYYMMDD_to_YYYYMMDD
  gsub(/[0-9]{4}-[0-9]{2}-[0-9]{2}/, "", s)  # 単独 YYYY-MM-DD
  gsub(/#[0-9]+-[0-9]+/, "", s)           # Paddle Order ID
  n = gsub(/[0-9]{8}/, "", s)
  if (n >= 2) print
}' || true)
[ -n "$out" ] && echo "$out" | sed 's/^/  /' || echo "  (none)"
echo

bold "[3] コピー痕跡（のコピー / [N] / (N)）"
out=$(find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | grep -E 'のコピー|\[[0-9]+\]| \([0-9]+\)' || true)
[ -n "$out" ] && echo "$out" | sed 's/^/  /' || echo "  (none)"
echo

bold "[4] 装飾・揺れ文字（｜ － – /  半角空白囲み）"
out=$(find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | grep -E '｜|－|–| _ ' || true)
[ -n "$out" ] && echo "$out" | sed 's/^/  /' || echo "  (none)"
echo

bold "[5] 拡張子分布"
find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | awk -F. 'NF>1{print $NF}' | sort | uniq -c | sed 's/^/  /'
echo

bold "[6] 月別件数（YYYYMM）"
find . -maxdepth 1 -type f ! -name '.*' | sed 's|^\./||' | grep -oE '^[0-9]{6}' | sort | uniq -c | sed 's/^/  /'
