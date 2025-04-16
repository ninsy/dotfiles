Write-Host "Starting 'winsetup' script (AutoHotKey install & script copy)"

$ahkInstalled = winget list --name AutoHotkey | Select-String "AutoHotkey"

if ($ahkInstalled) {
    Write-Host "AutoHotkey is already installed."
} else {
    Write-Host "AutoHotkey not found. Installing..."
    winget install --id=AutoHotkey.AutoHotkey --accept-source-agreements --accept-package-agreements
}

$ahkScriptPath = "\\wsl.localhost\Ubuntu-20.04\home\ninsy\Documents\Coding\dotfiles\autohotkey.ahk"
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ahkStartupPath = "$startup\autohotkey.lnk"

if (Test-Path $ahkStartupPath) {
    Write-Host "ahk script already at startup folder, skipping..."
} else {
    Write-Host "copying ahk script to startup folder..."
    $WshShell = New-Object -ComObject WScript.Shell
    $s = $WshShell.CreateShortcut($ahkStartupPath)
    $s.TargetPath = $ahkScriptPath
    $s.WorkingDirectory = $PSScriptRoot
    $s.Save()
}
