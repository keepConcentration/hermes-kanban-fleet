# Fleet workflow

## Roles

```text
User
  ?
  ?
orchestrator  ??kanban_create???  generalist  (Cursor ACP)
  ?                         ????  coder       (Claude Code ACP)
  ?                                    ?
  ?????? kanban_complete + Discord @report ???
  ?
User (final report)
```

## Routing heuristic

Assign to **`coder`** when the task is clearly hard engineering:

- multi-file refactors / greenfield modules
- tricky production bugs
- deep codebase analysis
- infrastructure that needs careful verification

Assign to **`generalist`** otherwise (research writeups, light edits, ops, docs, small fixes).

## Kanban shape

```text
parent  assignee=orchestrator   status tracks the whole user request
  ?? child  assignee=generalist|coder
  ?? child  …
```

When all children are `done`, the parent becomes ready again so orchestrator can review and `kanban_complete`.

## Discord one-way report

Workers:

1. `kanban_complete(...)`
2. Post once to the shared home channel mentioning the orchestrator bot ID
3. Stop (no bot reply chains)

Orchestrator:

- May process the mention
- Must not `@` workers back; use Kanban for follow-ups

## Gateway

Kanban dispatch runs inside the gateway (`kanban.dispatch_in_gateway: true` on orchestrator).

```bash
hermes -p orchestrator gateway start
```

Start worker gateways only if those bots should be online on Discord.
