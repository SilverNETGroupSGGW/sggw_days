#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
  echo "Usage: $0 BUILD_NUMBER METADATA_PATH [FALLBACK_NOTES]" >&2
  exit 1
fi

build_number="$1"
metadata_path="$2"
fallback_notes="${3:-Release update}"
max_length="${PLAY_CHANGELOG_MAX_LENGTH:-500}"

case "$max_length" in
  ''|*[!0-9]*)
    echo "PLAY_CHANGELOG_MAX_LENGTH must be a positive integer." >&2
    exit 1
    ;;
esac

if [ "$max_length" -le 0 ]; then
  echo "PLAY_CHANGELOG_MAX_LENGTH must be greater than zero." >&2
  exit 1
fi

normalize_notes() {
  awk '
    {
      sub(/\r$/, "", $0)
      sub(/[[:space:]]+$/, "", $0)
      if ($0 == "") {
        if (printed && !pending_blank) {
          pending_blank = 1
        }
        next
      }
      if (pending_blank) {
        print ""
        pending_blank = 0
      }
      print
      printed = 1
    }
  '
}

truncate_notes() {
  awk -v max="$max_length" '
    BEGIN {
      ellipsis = "..."
      out = ""
      truncated = 0
    }
    {
      line = $0
      candidate = (out == "" ? line : out ORS line)
      if (length(candidate) <= max) {
        out = candidate
        next
      }

      truncated = 1
      if (out == "") {
        available = max - length(ellipsis)
        if (available < 0) {
          available = max
        }
        out = substr(line, 1, available)
      }

      sub(/[[:space:]\n]+$/, "", out)
      if (max > length(ellipsis) && length(out) + length(ellipsis) > max) {
        out = substr(out, 1, max - length(ellipsis))
        sub(/[[:space:]\n]+$/, "", out)
      }

      if (max <= length(ellipsis)) {
        print substr(ellipsis, 1, max)
      } else {
        print out ellipsis
      }
      exit
    }
    END {
      if (!truncated) {
        print out
      }
    }
  '
}

raw_notes=$(cat)
normalized_notes=$(printf '%s' "$raw_notes" | normalize_notes)

if [ -z "$normalized_notes" ]; then
  normalized_notes=$(printf '%s' "$fallback_notes" | normalize_notes)
fi

formatted_notes=$(printf '%s\n' "$normalized_notes" | truncate_notes)

if [ -z "$formatted_notes" ]; then
  formatted_notes=$(printf '%s\n' "$fallback_notes" | truncate_notes)
fi

changelog_dir="$metadata_path/en-US/changelogs"
mkdir -p "$changelog_dir"
printf '%s\n' "$formatted_notes" > "$changelog_dir/${build_number}.txt"
