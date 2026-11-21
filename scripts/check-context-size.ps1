# Purpose: report always-on and on-demand context budgets for dual-platform
# (Antigravity + GitHub Copilot) repositories. Read-only; changes nothing.
# Sizes use ~4 bytes per token as rough estimates.
# Usage: pwsh -NoProfile -File scripts/check-context-size.ps1 [-Root <project folder>] [-FailOnWarning]

[CmdletBinding()]
param(
    # Project folder to inspect; defaults to the parent of the scripts folder.
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    # Exit with code 1 when any warning is emitted (useful in CI/verification).
    [switch]$FailOnWarning
)

$bytesPerToken = 4
$ruleFileLimitBytes = 24000
$alwaysOnRulesBudgetTokens = 20000
$script:warningCount = 0

function Add-CheckWarning([string]$Message) {
    $script:warningCount++
    Write-Warning $Message
}

function Get-Size([string[]]$Paths) {
    $files = @($Paths | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) })
    if ($files.Count -eq 0) { return 0 }
    [long](($files | ForEach-Object { (Get-Item -LiteralPath $_ -Force).Length } | Measure-Object -Sum).Sum)
}

function Show-Row([string]$Label, [long]$Bytes, [int]$Count) {
    '{0,-44} {1,4} files {2,9:N0} bytes  ~{3,7:N0} tokens' -f $Label, $Count, $Bytes, ($Bytes / $bytesPerToken)
}

function Get-RuleTrigger([string]$Path) {
    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    if ($raw -match '(?s)^---\r?\n(.*?)\r?\n---') {
        if ($Matches[1] -match '(?m)^\s*trigger\s*:\s*(\S+)') {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return 'always_on'
}

$agentsMd = Join-Path $Root 'AGENTS.md'
$geminiMd = Join-Path $Root 'GEMINI.md'
$copilotInstr = Join-Path $Root '.github/copilot-instructions.md'

$antigravityRoot = @($agentsMd, $geminiMd | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
$copilotAlways = @($agentsMd, $copilotInstr | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })

$rulesDir = Join-Path $Root '.agents/rules'
$ruleFiles = if (Test-Path -LiteralPath $rulesDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $rulesDir -Force -File -Filter '*.md' -ErrorAction SilentlyContinue).FullName
} else { @() }

$alwaysOnRules = @()
$conditionalRules = @()
foreach ($rule in $ruleFiles) {
    if ((Get-RuleTrigger $rule) -eq 'always_on') {
        $alwaysOnRules += $rule
    } else {
        $conditionalRules += $rule
    }
}

$antigravityAlways = @($antigravityRoot + $alwaysOnRules)

$instructionsDir = Join-Path $Root '.github/instructions'
$instructionFiles = if (Test-Path -LiteralPath $instructionsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $instructionsDir -Force -File -Filter '*.md' -ErrorAction SilentlyContinue).FullName
} else { @() }

$agAgentsDir = Join-Path $Root '.agents/agents'
$agAgentFiles = if (Test-Path -LiteralPath $agAgentsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $agAgentsDir -Force -File -ErrorAction SilentlyContinue).FullName
} else { @() }

$ghAgentsDir = Join-Path $Root '.github/agents'
$ghAgentFiles = if (Test-Path -LiteralPath $ghAgentsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $ghAgentsDir -Force -File -ErrorAction SilentlyContinue).FullName
} else { @() }

$agSkillsDir = Join-Path $Root '.agents/skills'
$agSkillFiles = if (Test-Path -LiteralPath $agSkillsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $agSkillsDir -Force -Recurse -File -ErrorAction SilentlyContinue).FullName
} else { @() }

$ghSkillsDir = Join-Path $Root '.github/skills'
$ghSkillFiles = if (Test-Path -LiteralPath $ghSkillsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $ghSkillsDir -Force -Recurse -File -ErrorAction SilentlyContinue).FullName
} else { @() }

$duplicateSkills = @()
if ((Test-Path -LiteralPath $agSkillsDir -PathType Container) -and
    (Test-Path -LiteralPath $ghSkillsDir -PathType Container)) {
    $agSkillNames = @(Get-ChildItem -LiteralPath $agSkillsDir -Force -Directory -ErrorAction SilentlyContinue).Name
    $ghSkillNames = @(Get-ChildItem -LiteralPath $ghSkillsDir -Force -Directory -ErrorAction SilentlyContinue).Name
    $duplicateSkills = @($agSkillNames | Where-Object { $_ -in $ghSkillNames })
}

$docsDir = Join-Path $Root 'docs'
$docFiles = if (Test-Path -LiteralPath $docsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $docsDir -Force -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne '.gitkeep' }).FullName
} else { @() }

$sections = [ordered]@{
    'Antigravity always-on (every session)'    = $antigravityAlways
    'Copilot always-on (every session)'        = $copilotAlways
    'Antigravity rules (.agents/rules)'        = $conditionalRules
    'Copilot instructions (.github/inst...)'   = $instructionFiles
    'Antigravity roles (.agents/agents)'       = $agAgentFiles
    'Copilot roles (.github/agents)'           = $ghAgentFiles
    'Shared skills (.agents/skills)'           = $agSkillFiles
    'Copilot-only skills (.github/skills)'     = $ghSkillFiles
    'Docs (read on demand)'                    = $docFiles
}

foreach ($name in $sections.Keys) {
    $paths = @($sections[$name] | Where-Object { $_ })
    Show-Row $name (Get-Size $paths) $paths.Count
}

if (Test-Path -LiteralPath $agentsMd -PathType Leaf) {
    $agentsLines = (Get-Content -LiteralPath $agentsMd).Count
    Write-Output "AGENTS.md lines: $agentsLines"
    if ($agentsLines -gt 70) {
        Add-CheckWarning "AGENTS.md is $agentsLines lines (limit is 70 lines)."
    }
}

Write-Output "Duplicate skills (.agents vs .github): $($duplicateSkills.Count)"
if ($duplicateSkills.Count -gt 0) {
    Add-CheckWarning "Duplicate skill folder(s) in both .agents/skills and .github/skills: $($duplicateSkills -join ', ')"
}

if ($antigravityRoot.Count -gt 1) {
    Add-CheckWarning 'Both AGENTS.md and GEMINI.md exist at the root; keep one to avoid duplicating always-on context.'
}

if ((Test-Path -LiteralPath $copilotInstr -PathType Leaf) -and
    (Test-Path -LiteralPath $agentsMd -PathType Leaf) -and
    ((Get-Item -LiteralPath $copilotInstr -Force).Length -gt 1KB)) {
    Add-CheckWarning '.github/copilot-instructions.md is over 1 KB alongside AGENTS.md; keep it as a short pointer.'
}

foreach ($rulePath in @($antigravityRoot + $ruleFiles)) {
    $len = (Get-Item -LiteralPath $rulePath -Force).Length
    if ($len -gt $ruleFileLimitBytes) {
        Add-CheckWarning "$rulePath is $len bytes (over Antigravity's 24,000-byte per-file rule cap)."
    }
}

$alwaysTokens = (Get-Size $antigravityAlways) / $bytesPerToken
if ($alwaysTokens -gt $alwaysOnRulesBudgetTokens) {
    Add-CheckWarning "Antigravity always-on rules (~$([int]$alwaysTokens) tokens) exceed the 20,000-token rules budget."
}

foreach ($activeConfig in @('.agents/hooks.json', '.agents/mcp_config.json', '.agents/mcp-config.json', '.mcp.json', '.vscode/mcp.json')) {
    $cfgPath = Join-Path $Root $activeConfig
    if (Test-Path -LiteralPath $cfgPath -PathType Leaf) {
        Add-CheckWarning "$activeConfig is active; confirm it is intentional and contains no secrets or machine-local paths."
    }
}

$pluginsDir = Join-Path $Root '.agents/plugins'
if (Test-Path -LiteralPath $pluginsDir -PathType Container) {
    $pluginFolders = @(Get-ChildItem -LiteralPath $pluginsDir -Force -Directory -ErrorAction SilentlyContinue)
    Write-Output "Workspace plugins (.agents/plugins): $($pluginFolders.Count)"
    foreach ($plugin in $pluginFolders) {
        $pMcp = Join-Path $plugin.FullName 'mcp_config.json'
        if (Test-Path -LiteralPath $pMcp -PathType Leaf) {
            $raw = Get-Content -LiteralPath $pMcp -Raw -ErrorAction SilentlyContinue
            if ($raw -match '[A-Za-z]:\\{1,2}Users\\{1,2}|/Users/[A-Za-z0-9._-]+/|ghp_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}') {
                Add-CheckWarning ".agents/plugins/$($plugin.Name)/mcp_config.json contains a hardcoded user path or secret-like token; use `${PLUGIN_ROOT} and never commit secrets."
            }
        }
        $pHooks = Join-Path $plugin.FullName 'hooks.json'
        if (Test-Path -LiteralPath $pHooks -PathType Leaf) {
            Add-CheckWarning ".agents/plugins/$($plugin.Name)/hooks.json is active; confirm it is intentional and contains no secrets."
        }
    }
}

$ghHooksDir = Join-Path $Root '.github/hooks'
if (Test-Path -LiteralPath $ghHooksDir -PathType Container) {
    $hookJsonFiles = @(Get-ChildItem -LiteralPath $ghHooksDir -Force -File -Filter '*.json' -ErrorAction SilentlyContinue)
    if ($hookJsonFiles.Count -gt 0) {
        Add-CheckWarning "Active Copilot hook config(s) under .github/hooks/: $($hookJsonFiles.Name -join ', ')"
    }
}

$handoff = Join-Path $Root 'docs/ai/handoff.md'
if ((Test-Path -LiteralPath $handoff -PathType Leaf) -and ((Get-Item -LiteralPath $handoff -Force).Length -gt 20KB)) {
    Add-CheckWarning 'docs/ai/handoff.md is over about 20 KB; archive dated sections to docs/ai/handoff-history/.'
}

Write-Output "Warnings: $script:warningCount"
if ($FailOnWarning -and $script:warningCount -gt 0) {
    exit 1
}
