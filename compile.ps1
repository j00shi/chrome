# Compiles the SCSS in this directory to CSS and opens the Sidebery style editor.
#
# No prior installation needed: on first run this downloads a standalone Dart Sass
# binary (a single self-contained executable, no Node/Ruby/npm) into .\.sass\.
# For Windows. macOS/Linux users: run compile.sh instead.
#
# Usage (right-click > Run with PowerShell, or):
#   powershell -ExecutionPolicy Bypass -File compile.ps1

$ErrorActionPreference = "Stop"

$SassVersion = "1.105.2"
$ExtUrl = "moz-extension://f9a9eaf3-d5c8-4e78-a9bc-8a2bb55cd97f/page.setup/setup.html#styles_editor"

# Run from the directory this script lives in, so paths are stable.
Set-Location $PSScriptRoot

$ToolsDir = ".sass"
$SassBin  = Join-Path $ToolsDir "dart-sass\sass.bat"

# --- Download Dart Sass once -----------------------------------------------
if (-not (Test-Path $SassBin)) {
	$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
	Write-Host "Downloading Dart Sass $SassVersion (windows-$arch)..."
	New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
	$url = "https://github.com/sass/dart-sass/releases/download/$SassVersion/dart-sass-$SassVersion-windows-$arch.zip"
	$zip = Join-Path $ToolsDir "dart-sass.zip"
	Invoke-WebRequest -Uri $url -OutFile $zip
	Expand-Archive -Path $zip -DestinationPath $ToolsDir -Force
	Remove-Item $zip
}

# --- Compile ---------------------------------------------------------------
Write-Host "Compiling SCSS..."
& $SassBin --style=compressed `
	userChrome.scss:userChrome.css `
	userContent.scss:userContent.css `
	styleEditor.scss:styleEditor.css
Write-Host "Done."

# --- Open the Sidebery style editor in Firefox -----------------------------
$opened = $false
try { Start-Process "firefox" $ExtUrl; $opened = $true } catch {}
if (-not $opened) {
	foreach ($p in @(
		"$env:ProgramFiles\Mozilla Firefox\firefox.exe",
		"${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe")) {
		if (Test-Path $p) { Start-Process $p $ExtUrl; $opened = $true; break }
	}
}
if (-not $opened) {
	Write-Host "Couldn't find Firefox automatically. Open this URL manually:"
	Write-Host "  $ExtUrl"
}
