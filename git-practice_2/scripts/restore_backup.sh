#!/usr/bin/env bash
set -euo pipefail

ZIP_PATH="${1:-}"

if [[ -z "$ZIP_PATH" ]]; then
  echo "Usage: $0 /path/to/backups.zip"
  exit 1
fi

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Error: File not found: $ZIP_PATH"
  exit 1
fi

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo "Unzipping: $ZIP_PATH"
unzip -q "$ZIP_PATH" -d "$WORKDIR"

# Expecting backups/backup-<timestamp>.txt
LATEST_FILE="$(ls -1t "$WORKDIR"/backups/backup-*.txt | head -n1 || true)"
if [[ -z "${LATEST_FILE:-}" ]]; then
  echo "Error: No backup files found inside the zip."
  exit 1
fi

echo "Restoring from: $LATEST_FILE"
cp "$LATEST_FILE" backup-data.txt

echo "✅ Restored backup to ./backup-data.txt"
echo "Preview:"
head -n 2 backup-data.txt || true
