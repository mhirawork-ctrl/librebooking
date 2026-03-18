#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RUN_JOB="$PROJECT_ROOT/ops/macos/run-job.sh"
LOG_DIR="$PROJECT_ROOT/output/tasklogs"

if [ ! -x "$RUN_JOB" ]; then
  echo "[ERROR] run-job.sh が見つかりません: $RUN_JOB" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

BLOCK_BEGIN="# >>> LIBREBOOKING_JOBS_BEGIN >>>"
BLOCK_END="# <<< LIBREBOOKING_JOBS_END <<<"
CURRENT_CRON="$(crontab -l 2>/dev/null || true)"

CLEANED_CRON="$(printf '%s\n' "$CURRENT_CRON" | awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  skip != 1 {print}
')"

NEW_BLOCK="$(cat <<EOF
$BLOCK_BEGIN
* * * * * /bin/bash "$RUN_JOB" autorelease.php >> "$LOG_DIR/autorelease.log" 2>&1
* * * * * /bin/bash "$RUN_JOB" sendreminders.php >> "$LOG_DIR/sendreminders.log" 2>&1
* * * * * /bin/bash "$RUN_JOB" sendmissedcheckin.php >> "$LOG_DIR/sendmissedcheckin.log" 2>&1
* * * * * /bin/bash "$RUN_JOB" sendwaitlist.php >> "$LOG_DIR/sendwaitlist.log" 2>&1
0 0 * * * /bin/bash "$RUN_JOB" sendseriesend.php >> "$LOG_DIR/sendseriesend.log" 2>&1
0 0 * * * /bin/bash "$RUN_JOB" sessioncleanup.php >> "$LOG_DIR/sessioncleanup.log" 2>&1
0 1 * * * /bin/bash "$RUN_JOB" deleteolddata.php >> "$LOG_DIR/deleteolddata.log" 2>&1
$BLOCK_END
EOF
)"

{
  printf '%s\n' "$CLEANED_CRON" | sed '/^[[:space:]]*$/d'
  printf '%s\n' "$NEW_BLOCK"
} | crontab -

echo '[OK] cron ジョブを登録しました。'
