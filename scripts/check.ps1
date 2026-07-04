param()

$ErrorActionPreference = "Stop"

$ProjectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$SkillRoot = Join-Path $ProjectRoot "loop-engineering"
$BootstrapScript = Join-Path $SkillRoot "scripts\bootstrap_loop_engineering.ps1"

if (-not (Test-Path -LiteralPath (Join-Path $SkillRoot "SKILL.md"))) {
    throw "Missing loop-engineering/SKILL.md"
}

if (-not (Test-Path -LiteralPath $BootstrapScript)) {
    throw "Missing bootstrap script: $BootstrapScript"
}

$CodexHome = $env:CODEX_HOME
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $HOME ".codex"
}

$Validator = Join-Path $CodexHome "skills\.system\skill-creator\scripts\quick_validate.py"
if (-not (Test-Path -LiteralPath $Validator)) {
    throw "Missing skill validator: $Validator"
}

$oldPythonUtf8 = $env:PYTHONUTF8
$env:PYTHONUTF8 = "1"
try {
    python $Validator $SkillRoot
} finally {
    $env:PYTHONUTF8 = $oldPythonUtf8
}

$TmpRoot = Join-Path $ProjectRoot ".tmp\check-bootstrap"
if (Test-Path -LiteralPath $TmpRoot) {
    $resolvedTmp = (Resolve-Path -LiteralPath $TmpRoot).Path
    if (-not $resolvedTmp.StartsWith($ProjectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refuse to delete temp path outside project: $resolvedTmp"
    }
    Remove-Item -LiteralPath $resolvedTmp -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $TmpRoot | Out-Null
Set-Content -LiteralPath (Join-Path $TmpRoot "AGENTS.md") -Value "# Temp Project`n" -Encoding UTF8

powershell -NoProfile -ExecutionPolicy Bypass -File $BootstrapScript -ProjectRoot $TmpRoot | Out-Null

$Profile = Join-Path $TmpRoot ".ai\loops\LOOP_PROFILE.md"
$State = Join-Path $TmpRoot ".ai\loops\state.json"

if (-not (Test-Path -LiteralPath $Profile)) {
    throw "Bootstrap did not create LOOP_PROFILE.md"
}
if (-not (Test-Path -LiteralPath $State)) {
    throw "Bootstrap did not create state.json"
}

$profileText = Get-Content -LiteralPath $Profile -Raw
if ($profileText -notmatch "# Loop Profile: check-bootstrap") {
    throw "Bootstrap profile has unexpected project name"
}
foreach ($requiredSection in @("## Loop Fit", "## Trigger / Cadence", "## Budget Guard", "## Workspace Hygiene", "## Checkpoint Closure", "## Permission Boundary")) {
    if ($profileText -notmatch [regex]::Escape($requiredSection)) {
        throw "Bootstrap profile missing required section: $requiredSection"
    }
}
foreach ($requiredLine in @("repeat condition:", "default trigger: manual", "max iterations:", "loop-owned paths:", "clean completion:", "commit policy: commit-on-success", "push policy: never push unless the owner explicitly asks", "write-capable connectors:")) {
    if ($profileText -notmatch [regex]::Escape($requiredLine)) {
        throw "Bootstrap profile missing required line: $requiredLine"
    }
}
if ($profileText -match "`t ext" -or $profileText -match "``"",\s*`"") {
    throw "Bootstrap profile appears corrupted by PowerShell backtick parsing"
}

$stateJson = Get-Content -LiteralPath $State -Raw | ConvertFrom-Json
if ($stateJson.schema_version -ne "loop-engineering.state.v1") {
    throw "Unexpected state schema_version"
}
if ($stateJson.completed_loops_since_step_back -ne 0) {
    throw "Unexpected completed_loops_since_step_back"
}
if (-not ($stateJson.PSObject.Properties.Name -contains "last_report")) {
    throw "Missing last_report in state.json"
}
if (-not ($stateJson.PSObject.Properties.Name -contains "workspace")) {
    throw "Missing workspace in state.json"
}
$workspaceProps = $stateJson.workspace.PSObject.Properties.Name
foreach ($requiredWorkspaceProp in @("baseline_status", "owned_paths", "transient_paths")) {
    if (-not ($workspaceProps -contains $requiredWorkspaceProp)) {
        throw "Missing workspace.$requiredWorkspaceProp in state.json"
    }
}
if (-not ($stateJson.PSObject.Properties.Name -contains "checkpoint")) {
    throw "Missing checkpoint in state.json"
}
$checkpointProps = $stateJson.checkpoint.PSObject.Properties.Name
foreach ($requiredCheckpointProp in @("policy", "baseline_head", "last_commit")) {
    if (-not ($checkpointProps -contains $requiredCheckpointProp)) {
        throw "Missing checkpoint.$requiredCheckpointProp in state.json"
    }
}
if ($stateJson.checkpoint.policy -ne "commit-on-success") {
    throw "Unexpected checkpoint policy"
}

$resolvedTmpAfter = (Resolve-Path -LiteralPath $TmpRoot).Path
if (-not $resolvedTmpAfter.StartsWith($ProjectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refuse to delete temp path outside project: $resolvedTmpAfter"
}
Remove-Item -LiteralPath $resolvedTmpAfter -Recurse -Force

$TmpParent = Join-Path $ProjectRoot ".tmp"
if (Test-Path -LiteralPath $TmpParent) {
    $remaining = Get-ChildItem -LiteralPath $TmpParent -Force
    if ($remaining.Count -eq 0) {
        Remove-Item -LiteralPath $TmpParent -Force
    }
}

Write-Host "py-loop-engineering check passed"
