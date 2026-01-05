# Windows notification script for Claude Code
# 사용법: powershell -ExecutionPolicy Bypass -File notify.ps1

param()

# Read JSON from stdin
$input_json = $input | Out-String

# Get project name
$projectDir = $env:CLAUDE_PROJECT_DIR
if (-not $projectDir) { $projectDir = Get-Location }
$projectName = Split-Path -Leaf $projectDir

# Parse stop reason from JSON
$reason = "completed"
try {
    if ($input_json) {
        $json = $input_json | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($json.reason) { $reason = $json.reason }
    }
} catch {}

# Map reasons to Korean
$reasonText = switch ($reason) {
    "end_turn" { "응답 완료" }
    "max_tokens" { "토큰 한도 도달" }
    "tool_use" { "도구 사용 완료" }
    "interrupt" { "사용자 중단" }
    default { "작업 완료" }
}

$title = "Claude Code"
$message = "[$projectName] $reasonText"

# Show notification
Add-Type -AssemblyName System.Windows.Forms
[System.Media.SystemSounds]::Asterisk.Play()
[System.Windows.Forms.MessageBox]::Show($message, $title, 'OK', 'Information') | Out-Null

exit 0
