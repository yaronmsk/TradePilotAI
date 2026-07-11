$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path "$ScriptDir\.."

Set-Location $ProjectRoot

Write-Host ""
Write-Host "====================================="
Write-Host " TradePilot AI - Session Close"
Write-Host "====================================="
Write-Host ""

Write-Host "Step 1: Checking Git branch..."
git branch --show-current

Write-Host ""
Write-Host "Step 2: Checking Git status..."
git status

Write-Host ""
Write-Host "Step 3: Checking Flutter project..."
Set-Location "$ProjectRoot\mobile"
flutter analyze

Write-Host ""
Write-Host "Step 4: Returning to project root..."
Set-Location $ProjectRoot

Write-Host ""
Write-Host "Checklist:"
Write-Host "[ ] PROJECT_STATE.md updated"
Write-Host "[ ] PROJECT_JOURNAL updated if milestone completed"
Write-Host "[ ] App tested"
Write-Host "[ ] Git status reviewed"
Write-Host "[ ] Commit created if needed"
Write-Host "[ ] Push completed"
Write-Host ""

Write-Host "Recommended commands if changes are ready:"
Write-Host "git add ."
Write-Host "git commit -m `"your commit message`""
Write-Host "git push"
Write-Host ""

Write-Host "Session close check complete."