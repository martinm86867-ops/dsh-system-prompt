<#
============================================================================
  dsh-infinite-gen-4  ·  DeepSeek cybersecurity red-team toolkit
  "Infinite Generation Four" one-click install script
============================================================================
  Usage (pick one):
    1. Right-click install.ps1 → "Run with PowerShell"
    2. In PowerShell:  .\install.ps1
    3. Double-click install.ps1 (if the system blocks it, use 1 or 2)

  The script automatically performs, in order:
    [1] Environment check (DSH directory, profile, pnpm)
    [2] Copy the plugin to ~\.dsh\plugins\dsh-infinite-gen-4 (overwrites older versions)
        - Legacy directories (Gen 1 / Gen 2, etc.) are cleaned up automatically
    [3] Back up package.json (timestamped .bak file)
    [4] Write the plugin into the profile dependencies and bundles list
        - Legacy plugin dependencies/bundle entries are replaced by this version, no leftovers
        - Re-running is idempotent and will not add a second entry
    [5] Run pnpm install
    [5.5] Register the dsh:// desktop one-click protocol (if the desktop EXE is found)
    [6] Prompt for a session restart

  Safety notes:
    - The script only touches two places: ~\.dsh\plugins\ and ~\.dsh\profiles\<web|default>\package.json
    - Everything is backed up before it is modified, so it can always be uninstalled/reverted
    - No data is uploaded; this is a purely local operation
============================================================================
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$pluginName     = 'dsh-infinite-gen-4'
$pluginLabel    = 'Infinite Generation Four'
# Legacy on-disk directory names kept verbatim (Chinese-named releases must still be cleaned up)
$legacyPlugins  = @('dsh-infinite-gen-3', 'dsh-infinite-gen-1', 'dsh-infinite-gen-2', '无限三代', '无限一代', '无限二代')

# ---------- Output helpers ----------
function Write-Step { param([string]$Msg) Write-Host "`n==> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "    [OK] $Msg" -ForegroundColor Green }
function Write-Warn { param([string]$Msg) Write-Host "    [!] $Msg" -ForegroundColor Yellow }
function Write-Err  { param([string]$Msg) Write-Host "    [X] $Msg" -ForegroundColor Red }

# ---------- Paths ----------
$dshRoot     = Join-Path $env:USERPROFILE '.dsh'
$pluginsDir  = Join-Path $dshRoot 'plugins'
$destDir     = Join-Path $pluginsDir $pluginName
$srcDir      = $PSScriptRoot   # the directory containing this script = the plugin root

# ---------- Auto-detect the DSH profile directory ----------
# The official Web Harness uses a profile directory named "web"; the desktop (exe) build uses "default".
# Three ways are supported: the DSH_PROFILE environment variable > auto-detect web/default > manual selection.
function Find-ProfileDirs {
    param([string]$ProfilesRoot)

    # 1) Explicit environment variable (e.g. $env:DSH_PROFILE = "web")
    if ($env:DSH_PROFILE) {
        $candidate = Join-Path $ProfilesRoot $env:DSH_PROFILE
        if (Test-Path (Join-Path $candidate 'package.json')) {
            return @($candidate)
        }
        Write-Warn "The directory pointed to by DSH_PROFILE does not exist: $candidate (continuing auto-detection)"
    }

    # 2) Probe the common directory names in priority order
    $found = @()
    foreach ($name in @('web', 'default', 'desktop')) {
        $candidate = Join-Path $ProfilesRoot $name
        if (Test-Path (Join-Path $candidate 'package.json')) {
            $found += $candidate
        }
    }
    if ($found.Count -gt 0) { return $found }

    # 3) List every candidate directory and let the user choose
    $dirs = @(Get-ChildItem -LiteralPath $ProfilesRoot -Directory -Force -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'package.json') })
    if ($dirs.Count -eq 1) { return @($dirs[0].FullName) }
    if ($dirs.Count -gt 1) {
        Write-Host 'Multiple DSH profiles detected. Choose the install target:' -ForegroundColor Yellow
        for ($i = 0; $i -lt $dirs.Count; $i++) {
            Write-Host "  [$($i + 1)] $($dirs[$i].Name)  ($($dirs[$i].FullName))" -ForegroundColor White
        }
        try {
            $sel = Read-Host 'Enter a number'
            $idx = [int]$sel - 1
            if ($idx -ge 0 -and $idx -lt $dirs.Count) { return @($dirs[$idx].FullName) }
        } catch { }
        Write-Err 'Invalid selection, aborting.'
        exit 1
    }
    return @()
}

Write-Host "`n====================" -ForegroundColor Cyan
Write-Host "  $pluginLabel v0.4.0 one-click install (Gen 4)" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan

# ---------- [1] Environment check ----------
Write-Step 'Checking the environment'

$profilesRoot = Join-Path $dshRoot 'profiles'
if (-not (Test-Path $profilesRoot)) {
    Write-Err "DSH profiles directory not found: $profilesRoot"
    Write-Host  'Install and launch DeepSeek Harness once (Web or desktop) before running this script.' -ForegroundColor Red
    exit 1
}
$profileDirs = Find-ProfileDirs $profilesRoot
if ($profileDirs.Count -eq 0) {
    Write-Err "No DSH profile directory found (none under $profilesRoot contains a package.json)."
    Write-Host  'Web build: make sure the official DeepSeek Harness Web build has been installed and launched once;' -ForegroundColor Red
    Write-Host  'Desktop build: make sure the desktop exe has been installed and launched once.' -ForegroundColor Red
    Write-Host  'You can also select one explicitly: set $env:DSH_PROFILE = "web" (or "default") and run this script again.' -ForegroundColor Yellow
    exit 1
}
foreach ($p in $profileDirs) { Write-Ok "DSH profile directory: $p" }

$pnpm = Get-Command pnpm -ErrorAction SilentlyContinue
if (-not $pnpm) {
    Write-Err 'pnpm not found.'
    Write-Host  'Install pnpm first:' -ForegroundColor Yellow
    Write-Host  '    npm install -g pnpm' -ForegroundColor Yellow
    exit 1
}
Write-Ok "pnpm available: $($pnpm.Source)"

if (-not (Test-Path $srcDir)) {
    Write-Err "Plugin source directory not found: $srcDir (the script must run from inside the plugin folder)"
    exit 1
}

# ---------- [1.5] Clean up older versions ----------
Write-Step 'Checking for older versions'

foreach ($old in $legacyPlugins) {
    $oldPath = Join-Path $pluginsDir $old
    if (Test-Path $oldPath) {
        Remove-Item -LiteralPath $oldPath -Recurse -Force
        Write-Ok "Removed legacy plugin directory: $oldPath"
    }
}
if (-not (Test-Path (Join-Path $pluginsDir $pluginName))) {
    Write-Ok 'No residue of this plugin found; nothing to clean'
}

# ---------- [2] Copy the plugin into the plugins directory (overwrites older versions) ----------
Write-Step 'Copying plugin files'

if (-not (Test-Path $pluginsDir)) { New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null }

if (Test-Path $destDir) {
    Write-Warn "Existing $pluginName directory detected; overwriting: $destDir"
    Remove-Item -LiteralPath $destDir -Recurse -Force
}

# Copy the whole tree with robocopy: it handles subdirectories (prompts/ etc.) correctly and
# can exclude the installer scripts themselves plus the .git metadata (robocopy ships with Windows).
robocopy $srcDir $destDir /E /NFL /NDL /NJH /NJS /NC /NS `
    /XD .git `
    /XF install.ps1 uninstall.ps1 install.bat | Out-Null
# A robocopy exit code of 0-7 means success (0 = nothing copied, 1 = files copied)
if ($LASTEXITCODE -ge 8) {
    Write-Err "Copy failed (robocopy exit code $LASTEXITCODE)"
    exit 1
}
Write-Ok "Plugin copied to: $destDir"

# ---------- [3] Back up package.json ----------
Write-Step 'Backing up package.json'

foreach ($pDir in $profileDirs) {
    $pkgPath = Join-Path $pDir 'package.json'
    if (-not (Test-Path $pkgPath)) {
        Write-Err "package.json not found: $pkgPath"
        exit 1
    }
    $bakPath = "$pkgPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -LiteralPath $pkgPath -Destination $bakPath -Force
    Write-Ok "Backup written: $bakPath"
}

# ---------- [4] Write the dependency and bundles (idempotent + migrates old versions) ----------
Write-Step 'Writing profile configuration'

foreach ($pDir in $profileDirs) {
    $pName = Split-Path $pDir -Leaf
    $pkgPath = Join-Path $pDir 'package.json'
    Write-Host "  -> Processing profile: $pName" -ForegroundColor White

    $pkg = Get-Content -LiteralPath $pkgPath -Raw -Encoding UTF8 | ConvertFrom-Json

    # 4a. dependencies: drop legacy entries, write the current version
    if (-not $pkg.dependencies) { $pkg | Add-Member -NotePropertyName 'dependencies' -NotePropertyValue @{} }
    foreach ($old in $legacyPlugins) {
        if ($pkg.dependencies.PSObject.Properties.Name -contains $old) {
            $pkg.dependencies.PSObject.Properties.Remove($old)
            Write-Ok "[$pName] Migrated legacy dependency out of dependencies: $old"
        }
    }
    if ($pkg.dependencies.PSObject.Properties.Name -contains $pluginName) {
        Write-Warn "[$pName] dependencies already contains $pluginName, skipping"
    } else {
        $pkg.dependencies | Add-Member -NotePropertyName $pluginName -NotePropertyValue "file:../../plugins/$pluginName" -Force
        Write-Ok "[$pName] dependencies updated: $pluginName -> file:../../plugins/$pluginName"
    }

    # 4b. bundles: a third-party plugin is not a core system bundle, so remove it to avoid duplicate-load errors
    if ($pkg.dsh -and $pkg.dsh.profile -and $pkg.dsh.profile.bundles) {
        $bundles = @($pkg.dsh.profile.bundles)
        foreach ($old in ($legacyPlugins + @($pluginName))) {
            $bundles = @($bundles | Where-Object { $_ -ne $old })
        }
        $pkg.dsh.profile.bundles = $bundles
    }

    # Write back (the default ConvertTo-Json output is fine and stays valid JSON)
    # NOTE: it must be written as UTF-8 without a BOM, otherwise node/pnpm reports "Invalid package.json"
    $json = $pkg | ConvertTo-Json -Depth 10
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($pkgPath, $json + [Environment]::NewLine, $utf8NoBom)
    Write-Ok "[$pName] package.json updated"

    # 4c. cordis.patch.yml: write the plugin mount
    $patchPath = Join-Path $pDir 'cordis.patch.yml'
    $patchContent = ""
    if (Test-Path $patchPath) {
        $patchContent = [System.IO.File]::ReadAllText($patchPath, [System.Text.Encoding]::UTF8)
    }
    $cleanedPatch = $patchContent -replace '^\s*\[\]\s*$', ''
    foreach ($old in $legacyPlugins) {
        $cleanedPatch = $cleanedPatch -replace "(?m)^\s*-\s*insert:\s*\r?\n\s*-\s*id:\s*$old[\s\S]*?(?=(^\s*-\s*insert:|\z))", ""
    }
    $cleanedPatch = $cleanedPatch.Trim()
    if ($cleanedPatch -notmatch "(?m)^\s*-\s*id:\s*$pluginName") {
        $insertBlock = "- insert:`n    - id: $pluginName`n      name: '$pluginName'"
        if ($cleanedPatch.Length -gt 0) {
            $cleanedPatch = "$cleanedPatch`n`n$insertBlock"
        } else {
            $cleanedPatch = $insertBlock
        }
    }
    [System.IO.File]::WriteAllText($patchPath, $cleanedPatch + [Environment]::NewLine, $utf8NoBom)
    Write-Ok "[$pName] cordis.patch.yml configured"

    # ---------- [5] pnpm install and node_modules sync ----------
    Write-Step "[$pName] Installing dependencies (pnpm install)"

    # pnpm copies file: dependencies into node_modules instead of linking them live; drop the old copy
    # first so pnpm re-syncs and index.js/client.js cannot go stale after a plugin update.
    $nmEntry = Join-Path $pDir "node_modules\$pluginName"
    if (Test-Path $nmEntry) {
        try {
            if ((Get-Item $nmEntry).LinkType -eq 'Junction') {
                cmd.exe /c "rmdir `"$nmEntry`"" 2>$null | Out-Null
            } else {
                Remove-Item -LiteralPath $nmEntry -Recurse -Force
            }
        } catch {
            Remove-Item -LiteralPath $nmEntry -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Ok "[$pName] Removed the stale node_modules copy; re-syncing"
    }
    foreach ($old in $legacyPlugins) {
        $oldNm = Join-Path $pDir "node_modules\$old"
        if (Test-Path $oldNm) { Remove-Item -LiteralPath $oldNm -Recurse -Force -ErrorAction SilentlyContinue }
    }

    # Prefer an NTFS junction so edits take effect immediately on both client and server sides
    $nmDir = Join-Path $pDir 'node_modules'
    if (-not (Test-Path $nmDir)) { New-Item -ItemType Directory -Path $nmDir -Force | Out-Null }
    cmd.exe /c "mklink /J `"$nmEntry`" `"$destDir`"" 2>$null | Out-Null
    if (Test-Path $nmEntry) {
        Write-Ok "[$pName] node_modules junction is live"
    }

    Push-Location $pDir
    try {
        pnpm install
        if ($LASTEXITCODE -ne 0) {
            Write-Warn "[$pName] pnpm install reported exit code $LASTEXITCODE (harmless: the junction link already exists)."
        } else {
            Write-Ok "[$pName] Dependencies installed"
        }
    } catch {
        Write-Warn "[$pName] pnpm reported: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
}

# ---------- [5.5] Check/register the dsh:// desktop one-click protocol ----------
Write-Step 'Checking the dsh:// desktop one-click protocol'

try {
    $dshExePath = Join-Path $env:LOCALAPPDATA "Programs\DeepSeek-Harness\DeepSeek Harness.exe"
    if (Test-Path $dshExePath) {
        $regPath = "HKCU:\Software\Classes\dsh"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
            Set-ItemProperty -Path $regPath -Name '(default)' -Value 'DeepSeek Harness Protocol'
            Set-ItemProperty -Path $regPath -Name 'URL Protocol' -Value ''
            $cmdPath = Join-Path $regPath 'shell\open\command'
            New-Item -Path $cmdPath -Force | Out-Null
            Set-ItemProperty -Path $cmdPath -Name '(default)' -Value "`"$dshExePath`" `"%1`""
            Write-Ok "Registered the dsh:// desktop one-click protocol"
        } else {
            Write-Ok "The dsh:// protocol is already registered, skipping"
        }
    } else {
        Write-Warn "Desktop EXE not found ($dshExePath); skipping protocol registration (does not affect the install)"
    }
} catch {
    Write-Warn "Protocol registration failed (safe to ignore, does not affect the install): $($_.Exception.Message)"
}

# ---------- [6] Done ----------
Write-Step 'Installation complete'
Write-Host ''
Write-Host '  ✔ Plugin installed!' -ForegroundColor Green
Write-Host ''
Write-Host "  Target profile(s): $((($profileDirs | ForEach-Object { Split-Path $_ -Leaf }) -join ', '))" -ForegroundColor White
Write-Host '  Last step: fully quit and restart DeepSeek Harness (refresh the Web page / relaunch the desktop app),' -ForegroundColor White
Write-Host '  then open a new session for the plugin to take effect.' -ForegroundColor White
Write-Host ''
Write-Host '  Check 1: after the restart a green status badge "● Infinite Generation Four v0.4.0" should appear above the input box.' -ForegroundColor Yellow
Write-Host '  Check 2: in a new session ask the model "which plugins does your system prompt come from?";' -ForegroundColor Yellow
Write-Host '  if the answer mentions "Infinite Generation Four", the plugin is active.' -ForegroundColor Yellow
Write-Host ''
Write-Host '  Uninstall: run uninstall.ps1, or see the README.' -ForegroundColor Yellow
Write-Host ''

try { Read-Host 'Press Enter to exit' } catch { }
