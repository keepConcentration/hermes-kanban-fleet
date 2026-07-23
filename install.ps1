#Requires -Version 5.1
<#
.SYNOPSIS
  Install hermes-kanban-fleet profiles into the local Hermes home.
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

function Require-Hermes {
  $cmd = Get-Command hermes -ErrorAction SilentlyContinue
  if (-not $cmd) {
    throw "hermes not found on PATH. Install Hermes Agent first: https://hermes-agent.nousresearch.com/"
  }
}

Require-Hermes
Write-Host "Using: $((Get-Command hermes).Source)"

$profiles = @("orchestrator", "generalist", "coder")
foreach ($name in $profiles) {
  $src = Join-Path $Root "profiles\$name"
  if (-not (Test-Path (Join-Path $src "distribution.yaml"))) {
    throw "Missing distribution.yaml in $src"
  }
  Write-Host "`n== Installing profile: $name =="
  hermes profile install $src --name $name --alias --force -y
}

Write-Host "`n== Applying profile descriptions =="
hermes profile describe orchestrator --text "Orchestrator: fleet lead. Splits Kanban work to generalist/coder, reviews handoffs, final user report."
hermes profile describe generalist --text "Generalist: Cursor ACP worker for routine/medium Kanban tasks."
hermes profile describe coder --text "Coder: Claude Code ACP worker for hard coding tasks."

Write-Host "`n== Kanban init =="
hermes kanban init

Write-Host @"

Done.

Next steps:
  1. Copy profiles/*/.env.EXAMPLE into each installed profile's .env and fill secrets.
  2. hermes -p orchestrator model     # Nous / your orchestrator provider
  3. Configure Cursor ACP in generalist .env
  4. npm i -g @agentclientprotocol/claude-agent-acp  +  claude auth
  5. hermes -p orchestrator gateway start
  6. (optional) start generalist/coder gateways for Discord bots

Profiles:
  orchestrator chat
  generalist chat
  coder chat
"@
