# hermes-kanban-fleet

A ready-to-install **Hermes multi-agent Kanban fleet**:

| Profile | Role | Suggested model backend |
|---------|------|-------------------------|
| `orchestrator` | Analyze requests, split Kanban work, review, final report | Nous Portal |
| `generalist` | Routine / medium tasks | Cursor ACP (`copilot-acp`) |
| `coder` | Hard coding / deep implementation | Claude Code ACP |

Orchestrator assigns child tasks **directly** to `generalist` or `coder`. Workers run as Kanban dispatcher spawns (`HERMES_KANBAN_TASK`), call `kanban_*` tools, and finish with `kanban_complete` / `kanban_block`. The board is the source of truth.

## Requirements

- [Hermes Agent](https://hermes-agent.nousresearch.com/) `>= 0.19`
- Git
- (Optional) Cursor Agent CLI for `generalist`
- (Optional) Claude Code + `@agentclientprotocol/claude-agent-acp` for `coder`
- (Optional) Nous Portal login for `orchestrator`

## Quick install

```bash
git clone https://github.com/keepConcentration/hermes-kanban-fleet.git
cd hermes-kanban-fleet
```

**Windows (PowerShell):**

```powershell
.\install.ps1
```

**macOS / Linux:**

```bash
chmod +x install.sh && ./install.sh
```

This runs `hermes profile install` for each profile under `./profiles/*` with `--alias`.

Then copy env templates and fill secrets:

```bash
# after install, profiles live under your Hermes home, e.g.:
#   %LOCALAPPDATA%\hermes\profiles\<name>\   (Windows)
#   ~/.hermes/profiles\<name>/               (Unix)

cp profiles/orchestrator/.env.EXAMPLE  "$HERMES_HOME/profiles/orchestrator/.env"   # adjust path
cp profiles/generalist/.env.EXAMPLE    "$HERMES_HOME/profiles/generalist/.env"
cp profiles/coder/.env.EXAMPLE         "$HERMES_HOME/profiles/coder/.env"
```

Auth / models:

```bash
hermes -p orchestrator model          # Nous Portal
# configure Cursor ACP paths in generalist .env
# npm i -g @agentclientprotocol/claude-agent-acp && claude auth
hermes kanban init
hermes -p orchestrator gateway start # owns Kanban dispatch
```

Worker gateways are optional (only needed if those profiles also chat on messaging platforms). Kanban workers are spawned by the orchestrator gateway's dispatcher.

## Workflow (summary)

1. User asks **orchestrator** (CLI / gateway chat).
2. Orchestrator creates a parent task (`assignee=orchestrator`) + child tasks.
3. Hard work ? `coder`, else ? `generalist` (direct assignees — no relay profile).
4. Dispatcher spawns workers; they `kanban_show` ? work ? `kanban_complete` / `kanban_block`.
5. Orchestrator reviews board handoffs, closes parent, reports to the user.

See [docs/workflow.md](docs/workflow.md).

## Repo layout

```text
profiles/
  orchestrator/   # distribution.yaml, SOUL.md, config.yaml, .env.EXAMPLE
  generalist/
  coder/
docs/workflow.md
install.ps1 / install.sh
```

Each profile folder is a valid [Hermes profile distribution](https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions).

Install one profile only:

```bash
hermes profile install ./profiles/coder --alias -y
# or from GitHub after push:
hermes profile install github.com/keepConcentration/hermes-kanban-fleet --name coder
```

For sparse install from the monorepo, prefer cloning and pointing `hermes profile install` at the subdirectory (local path), or publishing each profile as its own repo later.

## Security

Never commit real `.env`, `auth.json`, bot tokens, or API keys. Templates use `.env.EXAMPLE` only.

## License

MIT
