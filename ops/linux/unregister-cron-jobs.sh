#!/usr/bin/env bash

set -euo pipefail

BLOCK_BEGIN="# >>> LIBREBOOKING_JOBS_BEGIN >>>"
BLOCK_END="# <<< LIBREBOOKING_JOBS_END <<<"
CURRENT_CRON="$(crontab -l 2>/dev/null || true)"

CLEANED_CRON="$(printf '%s\n' "$CURRENT_CRON" | awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  skip != 1 {print}
')"

if [ -n "$(printf '%s' "$CLEANED_CRON" | tr -d '[:space:]')" ]; then
  printf '%s\n' "$CLEANED_CRON" | crontab -
else
  crontab -r 2>/dev/null || true
fi

echo '[OK] LibreBooking の cron ジョブを削除しました。'
