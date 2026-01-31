#!/usr/bin/env bash
set -euo pipefail

echo "=== Github ACtions Runner Bootstrap ==="

: "${RUNNER_URL:?RUNNER_URL not set}"
: "${RUNNER_TOKEN:?RUNNER_TOKEN not set}"
: "${RUNNER_NAME:?RUNNER_NAME not set}"

echo "Configuring runner..."
./config.sh \
  --unattended \
  --url "$RUNNER_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME"

echo "Starting runner..."
exec ./run.sh
