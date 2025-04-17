Write-Host "Starting 'winsetup' script (AutoHotKey install & script copy)"

$ahkInstalled = winget list --name AutoHotkey | Select-String "AutoHotkey"

if ($ahkInstalled) {
    Write-Host "AutoHotkey is already installed."
} else {
    Write-Host "AutoHotkey not found. Installing..."
    winget install --id=AutoHotkey.AutoHotkey --accept-source-agreements --accept-package-agreements
}

$sourceAhkPath = "\\wsl.localhost\Ubuntu-20.04\home\ninsy\Documents\Coding\dotfiles\autohotkey.ahk"
$targetAhkPath = "$env:USERPROFILE\autohotkey.ahk"

if (Test-Path $sourceAhkPath) {
    Write-Host "copying AHK script to win user folder..."
    Copy-Item $sourceAhkPath $targetAhkPath -Force
} else {
    Write-Host "source script not found at: $sourceAhkPath"
    exit 1
}

$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ahkLinkStartupPath = "$startup\autohotkey.lnk"

if (Test-Path $ahkLinkStartupPath) {
    Write-Host "ahk script already at startup folder, skipping..."
} else {
    Write-Host "creating shortcut to ahk script in startup folder..."
    $WshShell = New-Object -ComObject WScript.Shell
    $s = $WshShell.CreateShortcut($ahkLinkStartupPath)
    $s.TargetPath = $targetAhkPath
    $s.WorkingDirectory = [System.IO.Path]::GetDirectoryName($targetAhkPath)
    $s.Save()
    Write-Host "shortcut created: $ahkLinkStartupPath"
}
