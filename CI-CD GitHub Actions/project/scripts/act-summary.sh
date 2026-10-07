#!/usr/bin/env bash
# actsum.sh LOG [extra-grep-regex]: job/step result lines from an act log, emoji normalised
sed 's/\x1b\[[0-9;]*m//g' "$1" | grep -E "🏁|❌|✅  Success - Main|${2:-^\$NEVER}" \
 | grep -v 'Success - Main actions/\(setup-python\|checkout\)' \
 | sed -e 's/🏁  Job succeeded/==> JOB SUCCEEDED/' -e 's/🏁  Job failed/==> JOB FAILED/' -e 's/✅  Success - Main/  ✓/' -e 's/❌  Failure - Main/  ✗ FAILED/' -e 's/   | /   /' -e 's/ \[[0-9.]*m\?s\]$//' -e 's/  *\]/]/'
