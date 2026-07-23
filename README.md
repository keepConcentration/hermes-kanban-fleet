# hermes-kanban-fleet

A ready-to-install **Hermes multi-agent Kanban fleet**:

| Profile | Role | Suggested model backend |
|---------|------|-------------------------|
| `orchestrator` | Analyze requests, split Kanban work, review, final report | Nous Portal |
| `coder` | Implementation / hard coding / deep analysis | Claude Code ACP |

The worker completes Kanban cards and optionally sends a **one-way Discord @mention report** to the orchestrator. The worker uses `DISCORD_ALLOW_BOTS=none` so bot?bot reply loops cannot form.

## Requirements

- [Hermes Agent](https://hermes-agent.nousresearch.com/) `>= 0.19`
- Git
- (Optional) Discord bots — one token per profile
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
cp profiles/coder/.env.EXAMPLE         "$HERMES_HOME/profiles/coder/.env"
```

Auth / models:

```bash
hermes -p orchestrator model          # Nous Portal
# npm i -g @agentclientprotocol/claude-agent-acp && claude auth
hermes kanban init
hermes -p orchestrator gateway start
hermes -p coder gateway start         # if using Discord worker bot
```

## Workflow (summary)

1. User asks **orchestrator** (Discord or CLI).
2. Orchestrator creates a parent task (`assignee=orchestrator`) + child tasks (`assignee=coder`).
3. Dispatcher (inside gateway) spawns `coder`; it `kanban_complete`s + optional Discord report.
4. Orchestrator reviews, closes parent, reports to the user.

See [docs/workflow.md](docs/workflow.md).

## Discord anti-loop layout

| Profile | `DISCORD_ALLOW_BOTS` |
|---------|----------------------|
| orchestrator | `mentions` (accept worker @reports) |
| coder | `none` (never reply to bots) |

Also set `DISCORD_REPLY_TO_MODE=off` and `DISCORD_ALLOW_MENTION_REPLIED_USER=false` on both.

> `DISCORD_ALLOWED_USERS` only gates **humans**. Bot traffic is gated by `DISCORD_ALLOW_BOTS`.

## Repo layout

```text
profiles/
  orchestrator/   # distribution.yaml, SOUL.md, config.yaml, .env.EXAMPLE
  coder/
docs/workflow.md
install.ps1 / install.sh
```

Each profile folder is a valid [Hermes profile distribution](https://hermes-agent.nousresearch.com/docs/user-guide/profile-distributions).

Install one profile only:

```bash
hermes profile install ./profiles/coder --alias -y
```

## Security

Never commit real `.env`, `auth.json`, bot tokens, or API keys. Templates use `.env.EXAMPLE` only.

## License

MIT
