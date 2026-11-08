# =============================================================================
# J.A.R.V.I.S. <-> ANTIGRAVITY LIVE NEURAL TELEMETRY & PROMPT BRIDGE DAEMON
# 1. GET  /api/brain  -> Streams real-time transcript.jsonl, thinking, tool calls,
#                        activated skills, bounded 8-slot Hippocampus memory ring,
#                        and log-saturated Hebbian synaptic weights.
# 2. POST /api/prompt -> Queues a user prompt from J.A.R.V.I.S. directly to wake
#                        up the live Antigravity agent session!
# =============================================================================
param(
  [int]$Port = 18765
)

$ErrorActionPreference = "SilentlyContinue"
$brainRoot = "C:\Users\duyet.nguyenhuu\.gemini\antigravity\brain"
$repoRoot  = "C:\Users\duyet.nguyenhuu\.gemini\antigravity\scratch\jarvis-neural-sphere"
$hookStateFile    = Join-Path $repoRoot "live_hook_state.json"
$pendingPromptFile = Join-Path $repoRoot "pending_prompt.json"

function Get-AntigravityBrainState {
  $latestTranscript = Get-ChildItem -Path $brainRoot -Directory | ForEach-Object {
    $p = Join-Path $_.FullName ".system_generated\logs\transcript.jsonl"
    if (Test-Path $p) { Get-Item $p }
  } | Sort-Object LastWriteTime -Descending | Select-Object -First 1

  if (-not $latestTranscript) {
    return @{ ok = $false; error = "No transcript found" }
  }

  $convId = $latestTranscript.Directory.Parent.Parent.Name
  $allLines = [System.IO.File]::ReadAllLines($latestTranscript.FullName, [System.Text.Encoding]::UTF8)
  $totalSteps = $allLines.Count

  $toolCounts = @{
    "read_file" = 0
    "edit_file" = 0
    "write_file" = 0
    "run_command" = 0
    "search_web" = 0
    "invoke_subagent" = 0
    "mcp" = 0
  }
  $activatedSkills = @{}
  $recentTurns = New-Object System.Collections.Generic.List[object]

  $latestUserPrompt = ""
  $latestThinking = ""
  $latestResponse = ""
  $latestToolName = ""
  $latestToolSummary = ""
  $latestStepIndex = 0
  $latestStepType = ""
  $latestStatus = "IDLE"
  $lastInputTokens = 0
  $lastCacheTokens = 0
  $lastOutputTokens = 0

  $turnCounter = 0
  for ($i = 0; $i -lt $totalSteps; $i++) {
    $line = $allLines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try {
      $step = $line | ConvertFrom-Json
    } catch {
      continue
    }

    $latestStepIndex = $step.step_index
    $latestStepType  = $step.type
    $latestStatus    = $step.status

    if ($step.input_tokens)      { $lastInputTokens = $step.input_tokens }
    if ($step.cache_read_tokens) { $lastCacheTokens = $step.cache_read_tokens }
    if ($step.output_tokens)     { $lastOutputTokens = $step.output_tokens }

    if ($step.type -eq "USER_INPUT" -and $step.content) {
      $cleanUser = $step.content -replace "(?s)<ADDITIONAL_METADATA>.*?</ADDITIONAL_METADATA>", ""
      $cleanUser = $cleanUser -replace "<USER_REQUEST>", "" -replace "</USER_REQUEST>", ""
      $cleanUser = ($cleanUser -replace "\s+", " ").Trim()
      if ($cleanUser.Length -gt 0) {
        $latestUserPrompt = $cleanUser
        $turnCounter++
        $shortSummary = if ($cleanUser.Length -gt 44) { $cleanUser.Substring(0, 44) + "..." } else { $cleanUser }
        $recentTurns.Add(@{
          turn = $turnCounter
          step = $step.step_index
          text = $shortSummary
          timestamp = $step.created_at
        })
      }
    }

    if ($step.type -eq "PLANNER_RESPONSE") {
      if ($step.thinking) {
        $cleanThink = ($step.thinking -replace "\s+", " ").Trim()
        if ($cleanThink.Length -gt 0) {
          $latestThinking = if ($cleanThink.Length -gt 190) { $cleanThink.Substring(0, 190) + "..." } else { $cleanThink }
        }
      }
      if ($step.content) {
        $cleanResp = ($step.content -replace "\s+", " ").Trim()
        if ($cleanResp.Length -gt 0) {
          $latestResponse = if ($cleanResp.Length -gt 190) { $cleanResp.Substring(0, 190) + "..." } else { $cleanResp }
        }
      }
      if ($step.tool_calls) {
        foreach ($tc in $step.tool_calls) {
          $tName = $tc.name
          if ($tName) {
            $latestToolName = $tName
            if ($toolCounts.ContainsKey($tName)) {
              $toolCounts[$tName] = $toolCounts[$tName] + 1
            } elseif ($tName -like "mcp_*") {
              $toolCounts["mcp"] = $toolCounts["mcp"] + 1
            }

            $argObj = if ($tc.args) { $tc.args } elseif ($tc.arguments) { $tc.arguments } else { $null }
            if ($argObj) {
              if ($argObj.toolSummary) {
                $latestToolSummary = ($argObj.toolSummary -replace '^"|"$', '')
              } elseif ($argObj.Path) {
                $pStr = ([string]$argObj.Path) -replace '^"|"$', '' -replace '\\\\', '\'
                $leaf = Split-Path $pStr -Leaf
                $latestToolSummary = "$tName -> $leaf"
                if ($pStr -match "skills[\\/]([^\\/]+)[\\/]") {
                  $skName = $Matches[1]
                  if (-not $activatedSkills.ContainsKey($skName)) {
                    $activatedSkills[$skName] = 0
                  }
                  $activatedSkills[$skName] = $activatedSkills[$skName] + 1
                }
              }
            }
          }
        }
      }
    }
  }

  # Bounded 8-slot Hippocampus Working Memory Ring (Homeostatic: old slots consolidate, never grows unbounded!)
  $boundedMemoryRing = @()
  $startIdx = [Math]::Max(0, $recentTurns.Count - 8)
  for ($m = $startIdx; $m -lt $recentTurns.Count; $m++) {
    $boundedMemoryRing += $recentTurns[$m]
  }

  # Determine which Cortical Regions are firing in the latest turn
  # 0: CORTEX 0 // LANGUAGE & REASONING (PLANNER_RESPONSE / LLM Core)
  # 1: CORTEX 1 // PERCEPTION & READ (read_file)
  # 2: CORTEX 2 // CODE & ARTIFACT SYNTHESIS (write_file, edit_file)
  # 3: CORTEX 3 // MOTOR & SHELL EXECUTION (run_command)
  # 4: CORTEX 4 // PROCEDURAL SKILLS (SKILL.md activations)
  # 5: CORTEX 5 // HIPPOCAMPUS MEMORY RING (Episodic context consolidation)
  # 6: CORTEX 6 // SWARM & EXTERNAL SEARCH (search_web, invoke_subagent, mcp)
  $activeSet = New-Object System.Collections.Generic.HashSet[int]
  [void]$activeSet.Add(0)
  [void]$activeSet.Add(5)

  # Find the index of the latest USER_INPUT so we only highlight tools used in the CURRENT turn!
  $lastUserStepArrIdx = $totalSteps - 1
  for ($u = $totalSteps - 1; $u -ge 0; $u--) {
    if ($allLines[$u] -match '"type"\s*:\s*"USER_INPUT"') {
      $lastUserStepArrIdx = $u
      break
    }
  }

  $currentTurnToolCalls = 0
  for ($j = $lastUserStepArrIdx; $j -lt $totalSteps; $j++) {
    $l = $allLines[$j]
    if ([string]::IsNullOrWhiteSpace($l)) { continue }
    try {
      $s = $l | ConvertFrom-Json
      if ($s.tool_calls) {
        foreach ($tc in $s.tool_calls) {
          $currentTurnToolCalls++
          $aObj = if ($tc.args) { $tc.args } elseif ($tc.arguments) { $tc.arguments } else { $null }
          switch -Wildcard ($tc.name) {
            "read_file" {
              [void]$activeSet.Add(1)
              if ($aObj -and ([string]$aObj.Path) -match "skills|plugins|builtin") {
                [void]$activeSet.Add(4)
              }
            }
            "edit_file"       { [void]$activeSet.Add(2) }
            "write_file"      { [void]$activeSet.Add(2) }
            "run_command"     { [void]$activeSet.Add(3) }
            "search_web"      { [void]$activeSet.Add(6) }
            "invoke_subagent" { [void]$activeSet.Add(6) }
            "mcp_*"           { [void]$activeSet.Add(6) }
          }
        }
      }
    } catch {}
  }

  $skillTotal = 0
  foreach ($v in $activatedSkills.Values) { $skillTotal += $v }

  # Logarithmic Hebbian Synaptic Plasticity Weights (Homeostatic bound [0.35 .. 1.65])
  $hebbianWeights = @(
    [Math]::Round([Math]::Min(1.65, 0.55 + [Math]::Log10(1 + $totalSteps) * 0.35), 3),
    [Math]::Round([Math]::Min(1.65, 0.35 + [Math]::Log10(1 + $toolCounts["read_file"]) * 0.55), 3),
    [Math]::Round([Math]::Min(1.65, 0.35 + [Math]::Log10(1 + $toolCounts["edit_file"] + $toolCounts["write_file"]) * 0.60), 3),
    [Math]::Round([Math]::Min(1.65, 0.35 + [Math]::Log10(1 + $toolCounts["run_command"]) * 0.55), 3),
    [Math]::Round([Math]::Min(1.65, 0.35 + [Math]::Log10(1 + $skillTotal) * 0.65), 3),
    [Math]::Round([Math]::Min(1.65, 0.45 + [Math]::Log10(1 + $turnCounter) * 0.55), 3),
    [Math]::Round([Math]::Min(1.65, 0.35 + [Math]::Log10(1 + $toolCounts["search_web"] + $toolCounts["invoke_subagent"] + $toolCounts["mcp"]) * 0.65), 3)
  )

  $modelName = "Antigravity Active LLM"
  if (Test-Path $hookStateFile) {
    try {
      $hk = Get-Content $hookStateFile -Raw | ConvertFrom-Json
      if ($hk.modelName) { $modelName = $hk.modelName }
    } catch {}
  }

  $skillsList = @()
  foreach ($k in $activatedSkills.Keys) {
    $skillsList += @{ name = $k; count = $activatedSkills[$k] }
  }

  $hasPendingPrompt = Test-Path $pendingPromptFile
  $pendingText = ""
  if ($hasPendingPrompt) {
    try {
      $pp = Get-Content $pendingPromptFile -Raw | ConvertFrom-Json
      $pendingText = $pp.prompt
    } catch {}
  }

  return @{
    ok = $true
    conversationId = $convId
    modelName = $modelName
    totalSteps = $totalSteps
    totalTurns = $turnCounter
    currentTurnToolCalls = $currentTurnToolCalls
    tokens = @{
      input = $lastInputTokens
      cache = $lastCacheTokens
      output = $lastOutputTokens
    }
    pendingPrompt = $pendingText
    lastModified = $latestTranscript.LastWriteTime.ToString("o")
    latestStep = @{
      index = $latestStepIndex
      type = $latestStepType
      status = $latestStatus
      userPrompt = $latestUserPrompt
      thinking = $latestThinking
      toolName = $latestToolName
      toolSummary = $latestToolSummary
      response = $latestResponse
    }
    activeRegions = @($activeSet)
    hebbianWeights = $hebbianWeights
    toolCounts = $toolCounts
    activatedSkills = $skillsList
    memoryRing = $boundedMemoryRing
  }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Output "J.A.R.V.I.S. <-> Antigravity Neural Bridge listening on http://127.0.0.1:$Port/api/brain"

while ($listener.IsListening) {
  try {
    $context = $listener.GetContext()
    $req = $context.Request
    $res = $context.Response

    $res.Headers.Add("Access-Control-Allow-Origin", "*")
    $res.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $res.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
    $res.Headers.Add("Cache-Control", "no-store, no-cache, must-revalidate")

    if ($req.HttpMethod -eq "OPTIONS") {
      $res.StatusCode = 204
      $res.Close()
      continue
    }

    if ($req.Url.AbsolutePath -eq "/api/brain" -and $req.HttpMethod -eq "GET") {
      $stateObj = Get-AntigravityBrainState
      $json = $stateObj | ConvertTo-Json -Depth 6 -Compress
      $buf = [System.Text.Encoding]::UTF8.GetBytes($json)
      $res.ContentType = "application/json; charset=utf-8"
      $res.ContentLength64 = $buf.Length
      $res.OutputStream.Write($buf, 0, $buf.Length)
      $res.Close()
    } elseif ($req.Url.AbsolutePath -eq "/api/prompt" -and $req.HttpMethod -eq "POST") {
      $reader = New-Object System.IO.StreamReader($req.InputStream, [System.Text.Encoding]::UTF8)
      $body = $reader.ReadToEnd()
      $reader.Close()
      $payload = $body | ConvertFrom-Json
      if ($payload -and $payload.prompt) {
        $outObj = @{
          prompt = [string]$payload.prompt
          timestamp = (Get-Date).ToString("o")
        }
        $outObj | ConvertTo-Json -Compress | Set-Content -Path $pendingPromptFile -Encoding UTF8
      }
      $buf = [System.Text.Encoding]::UTF8.GetBytes('{"ok":true,"queued":true}')
      $res.ContentType = "application/json; charset=utf-8"
      $res.ContentLength64 = $buf.Length
      $res.OutputStream.Write($buf, 0, $buf.Length)
      $res.Close()
    } else {
      $buf = [System.Text.Encoding]::UTF8.GetBytes('{"status":"J.A.R.V.I.S. Antigravity Bridge Online"}')
      $res.ContentType = "application/json; charset=utf-8"
      $res.ContentLength64 = $buf.Length
      $res.OutputStream.Write($buf, 0, $buf.Length)
      $res.Close()
    }
  } catch {
    Start-Sleep -Milliseconds 100
  }
}
