#!/usr/bin/env bash
set -euo pipefail

echo "=== GitHub Actions Runner Bootstrap ==="

: "${RUNNER_URL:?RUNNER_URL not set}"
: "${RUNNER_TOKEN:?RUNNER_TOKEN not set}"
: "${RUNNER_NAME:?RUNNER_NAME not set}"

# Only configure if not already configured
if [ ! -f ".runner" ]; then
  echo "Configuring runner..."
  ./config.sh \
    --unattended \
    --url "$RUNNER_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --replace
else
  echo "Runner already configured, skipping registration."
fi

echo "Starting runner..."
exec ./run.sh
