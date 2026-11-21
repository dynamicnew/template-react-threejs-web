<#
.SYNOPSIS
    Reports always-on and on-demand context budgets and configuration hygiene
    for dual-platform (Antigravity + GitHub Copilot) repositories.
.DESCRIPTION
    Read-only checker that measures always-on files, conditional rules and
    instructions, custom agents, skills, and docs (~4 bytes/token estimate),
    and validates rule caps, skill deduplication, active MCP/hook hygiene, and
    handoff file size. Changes nothing on disk.
.PARAMETER Root
    Project folder to inspect; defaults to the parent of the scripts folder.
.PARAMETER FailOnWarning
    Exit with code 1 when any warning is emitted (useful in CI/verification).
.EXAMPLE
    pwsh -NoProfile -File scripts/check-context-size.ps1 -FailOnWarning
#>

[CmdletBinding()]
param(
    # Project folder to inspect; defaults to the parent of the scripts folder.
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    # Exit with code 1 when any warning is emitted (useful in CI/verification).
    [switch]$FailOnWarning
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Error "Project root does not exist: $Root"
    exit 1
}
$Root = (Resolve-Path -LiteralPath $Root).Path

$bytesPerToken = 4
$ruleFileLimitBytes = 24000
$alwaysOnRulesBudgetTokens = 20000
$validRuleTriggers = @('always_on', 'model_decision', 'glob', 'manual')
$secretOrLocalPathPattern = '[A-Za-z]:(?:\\{1,2}|/)Users(?:\\{1,2}|/)|/Users/[A-Za-z0-9._-]+/|/home/[A-Za-z0-9._-]+/|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----'
$script:warningCount = 0

# Records and prints a warning message while incrementing the warning counter.
function Add-CheckWarning([string]$Message) {
    $script:warningCount++
    Write-Warning $Message
}

# Returns the total byte length of all existing leaf files in Paths.
function Get-Size([string[]]$Paths) {
    $files = @($Paths | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) })
    if ($files.Count -eq 0) { return 0 }
    [long](($files | ForEach-Object { (Get-Item -LiteralPath $_ -Force).Length } | Measure-Object -Sum).Sum)
}

# Converts a byte count to a ceiling token estimate (~4 bytes per token).
function Get-TokenEstimate([long]$Bytes) {
    if ($Bytes -le 0) { return [long]0 }
    [long][Math]::Ceiling($Bytes / $bytesPerToken)
}

# Formats a summary row with file count, byte length, and token estimate.
function Show-Row([string]$Label, [long]$Bytes, [int]$Count) {
    '{0,-44} {1,4} files {2,9:N0} bytes  ~{3,7:N0} tokens' -f $Label, $Count, $Bytes, (Get-TokenEstimate $Bytes)
}

# Reads the Antigravity YAML frontmatter trigger key for a rule file.
function Get-RuleTrigger([string]$Path) {
    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    if ($raw -match '(?s)^\uFEFF?---\r?\n(.*?)\r?\n---(?:\r?\n|$)') {
        if ($Matches[1] -match '(?m)^\s*trigger\s*:\s*(.*)$') {
            $val = ($Matches[1] -replace '\s+#.*$', '').Trim().Trim('"').Trim("'")
            if ($val -cnotin $validRuleTriggers) {
                Add-CheckWarning "$Path has unrecognized trigger '$val' (expected one of: $($validRuleTriggers -join ', '))."
            }
            return $val
        }
    }
    return 'always_on'
}

# Reads the Copilot YAML frontmatter applyTo value for an instruction file.
function Get-InstructionApplyTo([string]$Path) {
    $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
    if ($raw -match '(?s)^\uFEFF?---\r?\n(.*?)\r?\n---(?:\r?\n|$)') {
        if ($Matches[1] -match '(?m)^\s*applyTo\s*:\s*(.*)$') {
            return ($Matches[1] -replace '\s+#.*$', '').Trim().Trim('"').Trim("'")
        }
    }
    return ''
}

# Validates JSON syntax (optional) and scans a file for hardcoded paths or secrets.
function Test-ConfigHygiene([string]$FilePath, [string]$DisplayPath, [bool]$CheckJson = $true) {
    $raw = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue
    if ($CheckJson) {
        try {
            $null = $raw | ConvertFrom-Json -ErrorAction Stop
        } catch {
            Add-CheckWarning "$DisplayPath is not valid JSON: $_"
        }
    }
    if ($raw -and $raw -match $secretOrLocalPathPattern) {
        Add-CheckWarning "$DisplayPath contains a hardcoded user path or secret-like token; remove secrets and machine-local paths."
        return $false
    }
    return $true
}

$agentsMd = Join-Path $Root 'AGENTS.md'
$geminiMd = Join-Path $Root 'GEMINI.md'
$copilotInstr = Join-Path $Root '.github/copilot-instructions.md'

$antigravityRoot = @($agentsMd, $geminiMd | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })

$rulesDir = Join-Path $Root '.agents/rules'
$ruleFiles = if (Test-Path -LiteralPath $rulesDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $rulesDir -Force -File -Filter '*.md' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$alwaysOnRules = @()
$conditionalRules = @()
foreach ($rule in $ruleFiles) {
    if ((Get-RuleTrigger $rule) -ceq 'always_on') {
        $alwaysOnRules += $rule
    } else {
        $conditionalRules += $rule
    }
}

$antigravityAlways = @($antigravityRoot + $alwaysOnRules | Where-Object { $_ })

$instructionsDir = Join-Path $Root '.github/instructions'
$instructionFiles = if (Test-Path -LiteralPath $instructionsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $instructionsDir -Force -File -Filter '*.instructions.md' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$alwaysOnInstructions = @()
$conditionalInstructions = @()
foreach ($instr in $instructionFiles) {
    $applyTo = Get-InstructionApplyTo $instr
    if ($applyTo -eq '**' -or $applyTo -eq '**/*') {
        $alwaysOnInstructions += $instr
    } else {
        $conditionalInstructions += $instr
    }
}

$copilotBase = @($agentsMd, $copilotInstr | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
$copilotAlways = @($copilotBase + $alwaysOnInstructions | Where-Object { $_ })

$agAgentsDir = Join-Path $Root '.agents/agents'
$agAgentFiles = if (Test-Path -LiteralPath $agAgentsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $agAgentsDir -Force -File -Filter '*.md' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$ghAgentsDir = Join-Path $Root '.github/agents'
$ghAgentFiles = if (Test-Path -LiteralPath $ghAgentsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $ghAgentsDir -Force -File -Filter '*.agent.md' -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$agSkillsDir = Join-Path $Root '.agents/skills'
$agSkillFiles = if (Test-Path -LiteralPath $agSkillsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $agSkillsDir -Force -Recurse -File -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$ghSkillsDir = Join-Path $Root '.github/skills'
$ghSkillFiles = if (Test-Path -LiteralPath $ghSkillsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $ghSkillsDir -Force -Recurse -File -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName)
} else { @() }

$duplicateSkills = @()
if ((Test-Path -LiteralPath $agSkillsDir -PathType Container) -and
    (Test-Path -LiteralPath $ghSkillsDir -PathType Container)) {
    $agSkillNames = @(Get-ChildItem -LiteralPath $agSkillsDir -Force -Directory -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name)
    $ghSkillNames = @(Get-ChildItem -LiteralPath $ghSkillsDir -Force -Directory -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Name)
    $duplicateSkills = @($agSkillNames | Where-Object { $_ -in $ghSkillNames })
}

$docsDir = Join-Path $Root 'docs'
$docFiles = if (Test-Path -LiteralPath $docsDir -PathType Container) {
    @(Get-ChildItem -LiteralPath $docsDir -Force -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne '.gitkeep' } |
        Select-Object -ExpandProperty FullName)
} else { @() }

$sections = [ordered]@{
    'Antigravity always-on (every session)'    = $antigravityAlways
    'Copilot always-on (every session)'        = $copilotAlways
    'Antigravity rules (.agents/rules)'        = $conditionalRules
    'Copilot instructions (.github/inst...)'   = $conditionalInstructions
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
    $agentsLines = @(Get-Content -LiteralPath $agentsMd).Count
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

foreach ($rulePath in @($antigravityRoot + $ruleFiles | Where-Object { $_ })) {
    $len = (Get-Item -LiteralPath $rulePath -Force).Length
    if ($len -gt $ruleFileLimitBytes) {
        Add-CheckWarning "$rulePath is $len bytes (over Antigravity's 24,000-byte per-file rule cap)."
    }
}

$alwaysTokens = Get-TokenEstimate (Get-Size $antigravityAlways)
if ($alwaysTokens -gt $alwaysOnRulesBudgetTokens) {
    Add-CheckWarning "Antigravity always-on rules (~$alwaysTokens tokens) exceed the 20,000-token rules budget."
}

# Validate active workspace MCP configs for valid JSON and secret/path hygiene.
$activeMcpConfigs = @()
foreach ($mcpCfg in @('.agents/mcp_config.json', '.mcp.json', '.vscode/mcp.json')) {
    $cfgPath = Join-Path $Root $mcpCfg
    if (Test-Path -LiteralPath $cfgPath -PathType Leaf) {
        $activeMcpConfigs += $mcpCfg
        [void](Test-ConfigHygiene $cfgPath $mcpCfg $true)
    }
}
if ($activeMcpConfigs.Count -gt 0) {
    Write-Output "Active workspace MCP configs: $($activeMcpConfigs -join ', ')"
}

# Flag misnamed Antigravity MCP config (hyphen instead of required underscore).
$misnamedMcp = Join-Path $Root '.agents/mcp-config.json'
if (Test-Path -LiteralPath $misnamedMcp -PathType Leaf) {
    Add-CheckWarning '.agents/mcp-config.json uses a hyphen; Antigravity loads .agents/mcp_config.json (underscore).'
}

# Warn on active automatic hooks (shell commands execute without per-call prompts).
$agHooks = Join-Path $Root '.agents/hooks.json'
if (Test-Path -LiteralPath $agHooks -PathType Leaf) {
    Add-CheckWarning '.agents/hooks.json is active; confirm it is intentional and contains no secrets or machine-local paths.'
    [void](Test-ConfigHygiene $agHooks '.agents/hooks.json' $true)
}

$pluginsDir = Join-Path $Root '.agents/plugins'
if (Test-Path -LiteralPath $pluginsDir -PathType Container) {
    $pluginFolders = @(Get-ChildItem -LiteralPath $pluginsDir -Force -Directory -ErrorAction SilentlyContinue)
    Write-Output "Workspace plugins (.agents/plugins): $($pluginFolders.Count)"
    foreach ($plugin in $pluginFolders) {
        $pMcp = Join-Path $plugin.FullName 'mcp_config.json'
        if (Test-Path -LiteralPath $pMcp -PathType Leaf) {
            [void](Test-ConfigHygiene $pMcp ".agents/plugins/$($plugin.Name)/mcp_config.json" $true)
        }
        $pMisnamedMcp = Join-Path $plugin.FullName 'mcp-config.json'
        if (Test-Path -LiteralPath $pMisnamedMcp -PathType Leaf) {
            Add-CheckWarning ".agents/plugins/$($plugin.Name)/mcp-config.json uses a hyphen; Antigravity plugins expect mcp_config.json (underscore)."
            [void](Test-ConfigHygiene $pMisnamedMcp ".agents/plugins/$($plugin.Name)/mcp-config.json" $true)
        }
        $pManifest = Join-Path $plugin.FullName 'plugin.json'
        if (Test-Path -LiteralPath $pManifest -PathType Leaf) {
            [void](Test-ConfigHygiene $pManifest ".agents/plugins/$($plugin.Name)/plugin.json" $true)
        }
        $pHooks = Join-Path $plugin.FullName 'hooks.json'
        if (Test-Path -LiteralPath $pHooks -PathType Leaf) {
            Add-CheckWarning ".agents/plugins/$($plugin.Name)/hooks.json is active; confirm it is intentional and contains no secrets."
            [void](Test-ConfigHygiene $pHooks ".agents/plugins/$($plugin.Name)/hooks.json" $true)
        }
    }
}

$extensionsDir = Join-Path $Root '.github/extensions'
if (Test-Path -LiteralPath $extensionsDir -PathType Container) {
    $extensionFolders = @(Get-ChildItem -LiteralPath $extensionsDir -Force -Directory -ErrorAction SilentlyContinue)
    Write-Output "Workspace Copilot extensions (.github/extensions): $($extensionFolders.Count)"
    foreach ($ext in $extensionFolders) {
        foreach ($ef in Get-ChildItem -LiteralPath $ext.FullName -Force -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in @('.mjs', '.js', '.json') }) {
            [void](Test-ConfigHygiene $ef.FullName ".github/extensions/$($ext.Name)/$($ef.Name)" ($ef.Extension -eq '.json'))
        }
    }
}

$ghHooksDir = Join-Path $Root '.github/hooks'
if (Test-Path -LiteralPath $ghHooksDir -PathType Container) {
    $hookJsonFiles = @(Get-ChildItem -LiteralPath $ghHooksDir -Force -File -Filter '*.json' -ErrorAction SilentlyContinue)
    if ($hookJsonFiles.Count -gt 0) {
        Add-CheckWarning "Active Copilot hook config(s) under .github/hooks/: $($hookJsonFiles.Name -join ', ')"
        foreach ($hf in $hookJsonFiles) {
            [void](Test-ConfigHygiene $hf.FullName ".github/hooks/$($hf.Name)" $true)
        }
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
exit 0
