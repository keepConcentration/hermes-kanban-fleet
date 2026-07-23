#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if ! command -v hermes >/dev/null 2>&1; then
  echo "hermes not found on PATH. Install Hermes Agent first:" >&2
  echo "  https://hermes-agent.nousresearch.com/" >&2
  exit 1
fi

echo "Using: $(command -v hermes)"

for name in orchestrator generalist coder; do
  src="$ROOT/profiles/$name"
  if [[ ! -f "$src/distribution.yaml" ]]; then
    echo "Missing distribution.yaml in $src" >&2
    exit 1
  fi
  echo
  echo "== Installing profile: $name =="
  hermes profile install "$src" --name "$name" --alias --force -y
done

echo
echo "== Applying profile descriptions =="
hermes profile describe orchestrator --text "Orchestrator: fleet lead. Splits Kanban work to generalist/coder, reviews handoffs, final user report."
hermes profile describe generalist --text "Generalist: Cursor ACP worker for routine/medium Kanban tasks."
hermes profile describe coder --text "Coder: Claude Code ACP worker for hard coding tasks."

echo
echo "== Kanban init =="
hermes kanban init

cat <<'EOF'

Done.

Next steps:
  1. Copy profiles/*/.env.EXAMPLE into each installed profile's .env and fill secrets.
  2. hermes -p orchestrator model
  3. Configure Cursor ACP in generalist .env
  4. npm i -g @agentclientprotocol/claude-agent-acp && claude auth
  5. hermes -p orchestrator gateway start
  6. (optional) start generalist/coder gateways for Discord bots

Profiles:
  orchestrator chat
  generalist chat
  coder chat
EOF
