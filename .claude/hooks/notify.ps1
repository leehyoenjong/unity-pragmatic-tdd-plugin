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
    default { "응답 완료" }
}

$title = "Claude Code"
$message = "[$projectName] $reasonText"

# Play sound
[System.Media.SystemSounds]::Asterisk.Play()

# Show dialog in center of screen (auto-close after 5 seconds, like macOS)
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup($message, 5, $title, 0x40) | Out-Null  # 0x40 = Information icon

exit 0
