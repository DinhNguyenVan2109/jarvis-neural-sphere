# Waits for a user prompt submitted from the 3D J.A.R.V.I.S. UI and exits
# so Antigravity automatically wakes up and executes it with the active LLM!
$pendingPromptFile = "C:\Users\duyet.nguyenhuu\.gemini\antigravity\scratch\jarvis-neural-sphere\pending_prompt.json"
while ($true) {
  if (Test-Path $pendingPromptFile) {
    try {
      $raw = Get-Content $pendingPromptFile -Raw -Encoding UTF8
      Remove-Item $pendingPromptFile -Force -ErrorAction SilentlyContinue
      Write-Output "JARVIS_UI_PROMPT: $raw"
      exit 0
    } catch {}
  }
  Start-Sleep -Milliseconds 300
}
