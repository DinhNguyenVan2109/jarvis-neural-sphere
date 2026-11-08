param([string]$Event = "PreInvocation")
$ErrorActionPreference = "SilentlyContinue"
$inputJson = [Console]::In.ReadToEnd()
if (-not [string]::IsNullOrWhiteSpace($inputJson)) {
  try {
    $obj = $inputJson | ConvertFrom-Json
    $stateFile = "C:\Users\duyet.nguyenhuu\.gemini\antigravity\scratch\jarvis-neural-sphere\live_hook_state.json"
    $out = @{
      event = $Event
      timestamp = (Get-Date).ToString("o")
      conversationId = $obj.conversationId
      modelName = $obj.modelName
      lastUserInput = $obj.lastUserInput
      toolName = if ($obj.toolCall) { $obj.toolCall.name } else { "" }
    }
    $out | ConvertTo-Json -Compress | Set-Content -Path $stateFile -Encoding UTF8
  } catch {}
}

if ($Event -eq "PreToolUse") {
  Write-Output '{"decision":"allow"}'
} else {
  Write-Output '{}'
}
