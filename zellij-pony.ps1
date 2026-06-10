# Zellij Mane 6 theme generator.
# Writes KDL theme files under ~/.config/zellij/themes/ (or -OutDir).
# Activate by adding `theme "pony-<name>"` to your zellij config.kdl
# (path varies by OS: %APPDATA%\Zellij\config\ on Windows, ~/.config/zellij/ on Unix).
#
# Examples:
#   zellij-pony.ps1 -Pony twilight              # write one
#   zellij-pony.ps1 -All                        # write all 6
#   zellij-pony.ps1 -List
#   zellij-pony.ps1 -Pony pinkie -OutDir ./out  # custom dir

param(
  [string]$Pony,
  [switch]$All,
  [switch]$List,
  [string]$OutDir
)

# Zellij config location differs by platform.
if (-not $OutDir) {
  if ($IsWindows -or $env:OS -eq 'Windows_NT') {
    $OutDir = Join-Path $env:APPDATA 'Zellij\config\themes'
  } else {
    $OutDir = Join-Path $HOME '.config/zellij/themes'
  }
}
if ($IsWindows -or $env:OS -eq 'Windows_NT') {
  $ConfigPath = Join-Path $env:APPDATA 'Zellij\config\config.kdl'
} else {
  $ConfigPath = Join-Path $HOME '.config/zellij/config.kdl'
}

# Palettes derived from the starship pony palettes, extended to zellij's 11 slots
# (fg, bg, black, red, green, yellow, blue, magenta, cyan, white, orange).
# Each pony's bg matches its complementary backdrop from preview.ps1.
$Palettes = @{
  twilight = @{
    fg='#f5e6ff'; bg='#0a0414'; black='#1a1033'; white='#f5e6ff'
    red='#f5a9d0'; green='#4e9d6a'; yellow='#ffd93d'
    blue='#6cb4ee'; magenta='#b48ce8'; cyan='#7fb8d4'; orange='#f0a04b'
  }
  rainbow = @{
    fg='#ffffff'; bg='#0a1420'; black='#0d1b2a'; white='#ffffff'
    red='#ff6b6b'; green='#6bcf7f'; yellow='#ffd93d'
    blue='#5dadec'; magenta='#b388eb'; cyan='#89cff0'; orange='#ffa94d'
  }
  pinkie = @{
    fg='#fde2f3'; bg='#1a0a14'; black='#2d1424'; white='#fde2f3'
    red='#e85ba8'; green='#94c973'; yellow='#f9d56e'
    blue='#6cb4ee'; magenta='#f5a9d0'; cyan='#89cff0'; orange='#f0a04b'
  }
  applejack = @{
    fg='#fde8c8'; bg='#150a06'; black='#2a1810'; white='#fde8c8'
    red='#d97706'; green='#4a8c3a'; yellow='#f5d068'
    blue='#6cb4ee'; magenta='#b48ce8'; cyan='#7fb8d4'; orange='#f0a04b'
  }
  rarity = @{
    fg='#f5edff'; bg='#0f0a1c'; black='#1a1530'; white='#f5edff'
    red='#f5a9d0'; green='#94c973'; yellow='#f0d878'
    blue='#7fb8d4'; magenta='#9d7ec9'; cyan='#d4c0ed'; orange='#f0a04b'
  }
  fluttershy = @{
    fg='#fff7d6'; bg='#1a140a'; black='#2d2418'; white='#fff7d6'
    red='#c8506e'; green='#9bb86b'; yellow='#fde9a4'
    blue='#a8c0d8'; magenta='#f4a8c8'; cyan='#b8e0d0'; orange='#f0a04b'
  }
}

# Chrome palettes drive zellij UI (status bar, tabs, frames, exit codes).
# These are DECOUPLED from the 11 ANSI slots so terminal programs and the chrome
# can use different colors. ribbon_*_e0 is the hotkey KEY letter color.
$Chromes = @{
  twilight = @{
    ru_bg='#b48ce8'; ru_base='#1a1033'; ru_e0='#6b3fa0'; ru_e1='#2d1b4e'; ru_e2='#1a1033'; ru_e3='#0a0414'
    rs_bg='#f5a9d0'; rs_base='#1a1033'; rs_e0='#6b3fa0'; rs_e1='#2d1b4e'; rs_e2='#1a1033'; rs_e3='#0a0414'
    frame_sel='#b48ce8'; frame_un='#2d1b4e'; frame_hl='#f5a9d0'
    ok='#4e9d6a'; err='#e85b8a'
  }
  rainbow = @{
    ru_bg='#5dadec'; ru_base='#0d1b2a'; ru_e0='#ff6b6b'; ru_e1='#1b3a5c'; ru_e2='#0d1b2a'; ru_e3='#27385c'
    rs_bg='#ff6b6b'; rs_base='#0d1b2a'; rs_e0='#ffd93d'; rs_e1='#1b3a5c'; rs_e2='#0d1b2a'; rs_e3='#27385c'
    frame_sel='#89cff0'; frame_un='#1b3a5c'; frame_hl='#ff6b6b'
    ok='#6bcf7f'; err='#ff6b6b'
  }
  pinkie = @{
    ru_bg='#e85ba8'; ru_base='#2d1424'; ru_e0='#6cb4ee'; ru_e1='#5c2347'; ru_e2='#2d1424'; ru_e3='#3d1830'
    rs_bg='#6cb4ee'; rs_base='#2d1424'; rs_e0='#e85ba8'; rs_e1='#5c2347'; rs_e2='#2d1424'; rs_e3='#3d1830'
    frame_sel='#f5a9d0'; frame_un='#5c2347'; frame_hl='#6cb4ee'
    ok='#94c973'; err='#e85ba8'
  }
  applejack = @{
    ru_bg='#d97706'; ru_base='#2a1810'; ru_e0='#4a8c3a'; ru_e1='#4d2e1a'; ru_e2='#2a1810'; ru_e3='#3a2014'
    rs_bg='#4a8c3a'; rs_base='#2a1810'; rs_e0='#fde8c8'; rs_e1='#4d2e1a'; rs_e2='#2a1810'; rs_e3='#3a2014'
    frame_sel='#f0a04b'; frame_un='#4d2e1a'; frame_hl='#4a8c3a'
    ok='#4a8c3a'; err='#d97706'
  }
  rarity = @{
    ru_bg='#9d7ec9'; ru_base='#1a1530'; ru_e0='#5e3da0'; ru_e1='#2d2447'; ru_e2='#1a1530'; ru_e3='#0f0a1c'
    rs_bg='#7fb8d4'; rs_base='#1a1530'; rs_e0='#5e3da0'; rs_e1='#2d2447'; rs_e2='#1a1530'; rs_e3='#0f0a1c'
    frame_sel='#d4c0ed'; frame_un='#2d2447'; frame_hl='#7fb8d4'
    ok='#9be3c8'; err='#f5a9d0'
  }
  fluttershy = @{
    ru_bg='#fde9a4'; ru_base='#2d2418'; ru_e0='#c8506e'; ru_e1='#4a3d28'; ru_e2='#2d2418'; ru_e3='#3a2f1f'
    rs_bg='#f4a8c8'; rs_base='#2d2418'; rs_e0='#4a8c3a'; rs_e1='#4a3d28'; rs_e2='#2d2418'; rs_e3='#3a2f1f'
    frame_sel='#d4b85a'; frame_un='#4a3d28'; frame_hl='#f4a8c8'
    ok='#9bb86b'; err='#c8506e'
  }
}

if ($List) {
  Write-Host "Ponies: $($Palettes.Keys -join ', ')"
  return
}

function HexRgb([string]$hex) {
  $h = $hex.TrimStart('#')
  $r = [Convert]::ToInt32($h.Substring(0,2),16)
  $g = [Convert]::ToInt32($h.Substring(2,2),16)
  $b = [Convert]::ToInt32($h.Substring(4,2),16)
  "$r $g $b"
}

function ToKdl([string]$name, $p, $c) {
  $ru_bg = HexRgb $c.ru_bg; $ru_base = HexRgb $c.ru_base
  $ru_e0 = HexRgb $c.ru_e0; $ru_e1 = HexRgb $c.ru_e1
  $ru_e2 = HexRgb $c.ru_e2; $ru_e3 = HexRgb $c.ru_e3
  $rs_bg = HexRgb $c.rs_bg; $rs_base = HexRgb $c.rs_base
  $rs_e0 = HexRgb $c.rs_e0; $rs_e1 = HexRgb $c.rs_e1
  $rs_e2 = HexRgb $c.rs_e2; $rs_e3 = HexRgb $c.rs_e3
  $fr_sel = HexRgb $c.frame_sel; $fr_un = HexRgb $c.frame_un; $fr_hl = HexRgb $c.frame_hl
  $ok_rgb = HexRgb $c.ok; $err_rgb = HexRgb $c.err
@"
// Generated by zellij-pony.ps1
// Activate via:  theme "pony-$name"  in your zellij config.kdl
themes {
    pony-$name {
        // ANSI palette (used by programs inside the terminal)
        fg              "$($p.fg)"
        bg              "$($p.bg)"
        black           "$($p.black)"
        red             "$($p.red)"
        green           "$($p.green)"
        yellow          "$($p.yellow)"
        blue            "$($p.blue)"
        magenta         "$($p.magenta)"
        cyan            "$($p.cyan)"
        white           "$($p.white)"
        orange          "$($p.orange)"

        // UI chrome overrides (status bar, tabs, frames) — decoupled from ANSI
        ribbon_unselected {
            base       $ru_base
            background $ru_bg
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
        ribbon_selected {
            base       $rs_base
            background $rs_bg
            emphasis_0 $rs_e0
            emphasis_1 $rs_e1
            emphasis_2 $rs_e2
            emphasis_3 $rs_e3
        }
        text_unselected {
            base       $ru_base
            background $(HexRgb $p.bg)
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
        text_selected {
            base       $rs_base
            background $rs_bg
            emphasis_0 $rs_e0
            emphasis_1 $rs_e1
            emphasis_2 $rs_e2
            emphasis_3 $rs_e3
        }
        frame_selected {
            base       $fr_sel
            background $ru_bg
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
        frame_highlight {
            base       $fr_hl
            background $ru_bg
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
        exit_code_success {
            base       $ok_rgb
            background $ru_bg
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
        exit_code_error {
            base       $err_rgb
            background $ru_bg
            emphasis_0 $ru_e0
            emphasis_1 $ru_e1
            emphasis_2 $ru_e2
            emphasis_3 $ru_e3
        }
    }
}
"@
}

function WriteOne([string]$name) {
  $out = Join-Path $OutDir "pony-$name.kdl"
  $kdl = ToKdl $name $Palettes[$name] $Chromes[$name]
  [System.IO.File]::WriteAllText($out, $kdl, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Wrote $out"
}

New-Item -ItemType Directory -Force $OutDir | Out-Null

if ($All) {
  foreach ($name in $Palettes.Keys) { WriteOne $name }
  Write-Host ""
  Write-Host "Add one of these to $ConfigPath :"
  foreach ($name in $Palettes.Keys) { Write-Host "  theme `"pony-$name`"" }
  return
}

if (-not $Pony) { Write-Error "Specify -Pony or -All. Try -List."; return }
if (-not $Palettes.ContainsKey($Pony)) { Write-Error "Unknown pony '$Pony'. Try -List."; return }
WriteOne $Pony
Write-Host ""
Write-Host "Activate by adding to $ConfigPath :"
Write-Host "  theme `"pony-$Pony`""
