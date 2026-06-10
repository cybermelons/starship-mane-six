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
  [switch]$Light,
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
  # Fluttershy variants — same palette family, different role arrangements.
  'fluttershy-swap' = @{
    fg='#fff7d6'; bg='#1a140a'; black='#2d2418'; white='#fff7d6'
    red='#c8506e'; green='#9bb86b'; yellow='#fde9a4'
    blue='#a8c0d8'; magenta='#f4a8c8'; cyan='#b8e0d0'; orange='#f0a04b'
  }
  'fluttershy-pinkbg' = @{
    fg='#2d1424'; bg='#fde2f3'; black='#2d1424'; white='#fde2f3'
    red='#c8506e'; green='#5e7e3a'; yellow='#a87914'
    blue='#5e7c98'; magenta='#a8197a'; cyan='#3e7e6c'; orange='#b8541a'
  }
  'fluttershy-yellowbg' = @{
    fg='#2d2418'; bg='#fde9a4'; black='#2d2418'; white='#fde9a4'
    red='#c8506e'; green='#5e7e3a'; yellow='#a87914'
    blue='#5e7c98'; magenta='#8c2858'; cyan='#3e7e6c'; orange='#b8541a'
  }
}

# Light-mode ANSI palettes — terminal bg becomes light, accents darken for contrast.
$Palettes_Light = @{
  twilight = @{
    fg='#1a1033'; bg='#f5e6ff'; black='#1a1033'; white='#f5e6ff'
    red='#c8506e'; green='#2d8c5e'; yellow='#a87914'
    blue='#3a6e98'; magenta='#6b3fa0'; cyan='#3a7090'; orange='#b8541a'
  }
  rainbow = @{
    fg='#0d1b2a'; bg='#e8f4ff'; black='#0d1b2a'; white='#e8f4ff'
    red='#b82c2c'; green='#3a8c44'; yellow='#a87914'
    blue='#1e4a8c'; magenta='#5e2a8c'; cyan='#1e6e8c'; orange='#b8541a'
  }
  pinkie = @{
    fg='#2d1424'; bg='#fde2f3'; black='#2d1424'; white='#fde2f3'
    red='#a8197a'; green='#5e8a3a'; yellow='#a87914'
    blue='#3a6e98'; magenta='#a8197a'; cyan='#3a7090'; orange='#b8541a'
  }
  applejack = @{
    fg='#2a1810'; bg='#fde8c8'; black='#2a1810'; white='#fde8c8'
    red='#a85d04'; green='#2d6e22'; yellow='#a87914'
    blue='#3a6e98'; magenta='#7a5dc4'; cyan='#3a7090'; orange='#a85d04'
  }
  rarity = @{
    fg='#1a1530'; bg='#f5edff'; black='#1a1530'; white='#f5edff'
    red='#c8506e'; green='#3a8c5e'; yellow='#a87914'
    blue='#3a6e8c'; magenta='#5e3da0'; cyan='#3a6e8c'; orange='#b8541a'
  }
  fluttershy = @{
    fg='#2d2418'; bg='#fff7d6'; black='#2d2418'; white='#fff7d6'
    red='#c8506e'; green='#5e7e3a'; yellow='#a87914'
    blue='#5e7c98'; magenta='#8c2858'; cyan='#3e7e6c'; orange='#b8541a'
  }
}

# Chrome palettes drive zellij UI (status bar, tabs, frames, exit codes).
# These are DECOUPLED from the 11 ANSI slots so terminal programs and the chrome
# can use different colors. ribbon_*_e0 is the hotkey KEY letter color.
$Chromes = @{
  twilight = @{
    ru_bg='#b48ce8'; ru_base='#1a1033'; ru_e0='#3d1f6e'; ru_e1='#2d1b4e'; ru_e2='#1a1033'; ru_e3='#0a0414'
    rs_bg='#f5a9d0'; rs_base='#1a1033'; rs_e0='#3d1f6e'; rs_e1='#2d1b4e'; rs_e2='#1a1033'; rs_e3='#0a0414'
    frame_sel='#b48ce8'; frame_un='#2d1b4e'; frame_hl='#f5a9d0'
    ok='#4e9d6a'; err='#e85b8a'
  }
  rainbow = @{
    ru_bg='#5dadec'; ru_base='#0d1b2a'; ru_e0='#8c1a1a'; ru_e1='#5a2a8c'; ru_e2='#1a4a18'; ru_e3='#6e3a14'
    rs_bg='#ff6b6b'; rs_base='#0d1b2a'; rs_e0='#4a3a08'; rs_e1='#1a3a8c'; rs_e2='#1a4a18'; rs_e3='#3a1a5e'
    frame_sel='#89cff0'; frame_un='#1b3a5c'; frame_hl='#ff6b6b'
    ok='#6bcf7f'; err='#ff6b6b'
  }
  pinkie = @{
    ru_bg='#e85ba8'; ru_base='#2d1424'; ru_e0='#1e4070'; ru_e1='#5c2347'; ru_e2='#2d1424'; ru_e3='#3d1830'
    rs_bg='#6cb4ee'; rs_base='#2d1424'; rs_e0='#8c2858'; rs_e1='#5c2347'; rs_e2='#2d1424'; rs_e3='#3d1830'
    frame_sel='#f5a9d0'; frame_un='#5c2347'; frame_hl='#6cb4ee'
    ok='#94c973'; err='#e85ba8'
  }
  applejack = @{
    ru_bg='#d97706'; ru_base='#2a1810'; ru_e0='#1e4d18'; ru_e1='#4d2e1a'; ru_e2='#2a1810'; ru_e3='#3a2014'
    rs_bg='#4a8c3a'; rs_base='#2a1810'; rs_e0='#fde8c8'; rs_e1='#1a0c06'; rs_e2='#2a1810'; rs_e3='#3a2014'
    frame_sel='#f0a04b'; frame_un='#4d2e1a'; frame_hl='#4a8c3a'
    ok='#4a8c3a'; err='#d97706'
  }
  rarity = @{
    ru_bg='#9d7ec9'; ru_base='#1a1530'; ru_e0='#2d1f5e'; ru_e1='#2d2447'; ru_e2='#1a1530'; ru_e3='#0f0a1c'
    rs_bg='#7fb8d4'; rs_base='#1a1530'; rs_e0='#2d1f5e'; rs_e1='#2d2447'; rs_e2='#1a1530'; rs_e3='#0f0a1c'
    frame_sel='#d4c0ed'; frame_un='#2d2447'; frame_hl='#7fb8d4'
    ok='#9be3c8'; err='#f5a9d0'
  }
  fluttershy = @{
    ru_bg='#fde9a4'; ru_base='#2d2418'; ru_e0='#c8506e'; ru_e1='#4a3d28'; ru_e2='#2d2418'; ru_e3='#3a2f1f'
    rs_bg='#f4a8c8'; rs_base='#2d2418'; rs_e0='#1a4c30'; rs_e1='#4a3d28'; rs_e2='#2d2418'; rs_e3='#3a2f1f'
    frame_sel='#d4b85a'; frame_un='#4a3d28'; frame_hl='#f4a8c8'
    ok='#9bb86b'; err='#c8506e'
  }
  # Pink as primary (unselected), yellow as accent (selected). Dark terminal bg.
  'fluttershy-swap' = @{
    ru_bg='#f4a8c8'; ru_base='#2d2418'; ru_e0='#1a4c30'; ru_e1='#4a3d28'; ru_e2='#2d2418'; ru_e3='#3a2f1f'
    rs_bg='#fde9a4'; rs_base='#2d2418'; rs_e0='#c8506e'; rs_e1='#4a3d28'; rs_e2='#2d2418'; rs_e3='#3a2f1f'
    frame_sel='#f4a8c8'; frame_un='#4a3d28'; frame_hl='#fde9a4'
    ok='#9bb86b'; err='#c8506e'
  }
  # Pale pink terminal bg, dark ribbons (gold + deep pink).
  'fluttershy-pinkbg' = @{
    ru_bg='#a87914'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'
    rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4'
    frame_sel='#a87914'; frame_un='#4a3d28'; frame_hl='#8c2858'
    ok='#5e7e3a'; err='#c8506e'
  }
  # Light butter terminal bg, deep pink ribbons.
  'fluttershy-yellowbg' = @{
    ru_bg='#c8506e'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'
    rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4'
    frame_sel='#c8506e'; frame_un='#4a3d28'; frame_hl='#8c2858'
    ok='#5e7e3a'; err='#c8506e'
  }
}

# Light-mode chrome — ribbon bgs DARK (stand out against light terminal bg), text LIGHT.
# Rule: on dark ribbon bg, ALL emphasis must be light shades (mirror of dark mode's all-dark rule).
$Chromes_Light = @{
  twilight = @{
    ru_bg='#6b3fa0'; ru_base='#f5e6ff'; ru_e0='#ffd93d'; ru_e1='#f5a9d0'; ru_e2='#f5e6ff'; ru_e3='#fde2f3'
    rs_bg='#c8506e'; rs_base='#f5e6ff'; rs_e0='#ffd93d'; rs_e1='#fde2f3'; rs_e2='#f5e6ff'; rs_e3='#fde2f3'
    frame_sel='#6b3fa0'; frame_un='#9d7ec9'; frame_hl='#c8506e'
    ok='#2d8c5e'; err='#c8506e'
  }
  rainbow = @{
    ru_bg='#1e4a8c'; ru_base='#e8f4ff'; ru_e0='#ff6b6b'; ru_e1='#ffd93d'; ru_e2='#e8f4ff'; ru_e3='#89cff0'
    rs_bg='#b82c2c'; rs_base='#e8f4ff'; rs_e0='#ffd93d'; rs_e1='#e8f4ff'; rs_e2='#e8f4ff'; rs_e3='#ffffff'
    frame_sel='#1e4a8c'; frame_un='#1b3a5c'; frame_hl='#b82c2c'
    ok='#3a8c44'; err='#b82c2c'
  }
  pinkie = @{
    ru_bg='#a8197a'; ru_base='#fde2f3'; ru_e0='#ffd93d'; ru_e1='#6cb4ee'; ru_e2='#fde2f3'; ru_e3='#f5a9d0'
    rs_bg='#1e6e98'; rs_base='#fde2f3'; rs_e0='#f5a9d0'; rs_e1='#ffd93d'; rs_e2='#fde2f3'; rs_e3='#89cff0'
    frame_sel='#a8197a'; frame_un='#5c2347'; frame_hl='#1e6e98'
    ok='#5e8a3a'; err='#a8197a'
  }
  applejack = @{
    ru_bg='#a85d04'; ru_base='#fde8c8'; ru_e0='#2a1810'; ru_e1='#fde8c8'; ru_e2='#fde8c8'; ru_e3='#fdc26b'
    rs_bg='#2d6e22'; rs_base='#fde8c8'; rs_e0='#fdc26b'; rs_e1='#fde8c8'; rs_e2='#fde8c8'; rs_e3='#fdc26b'
    frame_sel='#a85d04'; frame_un='#4d2e1a'; frame_hl='#2d6e22'
    ok='#2d6e22'; err='#a85d04'
  }
  rarity = @{
    ru_bg='#5e3da0'; ru_base='#f5edff'; ru_e0='#7fb8d4'; ru_e1='#d4c0ed'; ru_e2='#f5edff'; ru_e3='#f5edff'
    rs_bg='#3a6e8c'; rs_base='#f5edff'; rs_e0='#d4c0ed'; rs_e1='#d4c0ed'; rs_e2='#f5edff'; rs_e3='#f5edff'
    frame_sel='#5e3da0'; frame_un='#2d2447'; frame_hl='#3a6e8c'
    ok='#3a8c5e'; err='#c8506e'
  }
  fluttershy = @{
    ru_bg='#a87914'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'
    rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4'
    frame_sel='#a87914'; frame_un='#4a3d28'; frame_hl='#8c2858'
    ok='#5e7e3a'; err='#c8506e'
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
            base       $(HexRgb $p.fg)
            background $(HexRgb $p.bg)
            emphasis_0 $(HexRgb $p.red)
            emphasis_1 $(HexRgb $p.yellow)
            emphasis_2 $(HexRgb $p.cyan)
            emphasis_3 $(HexRgb $p.green)
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
        frame_unselected {
            base       $fr_un
            background $(HexRgb $p.bg)
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
  $palettes = if ($Light) { $Palettes_Light } else { $Palettes }
  $chromes  = if ($Light) { $Chromes_Light  } else { $Chromes  }
  $suffix   = if ($Light) { '-light' } else { '' }
  $themeName = "$name$suffix"
  $out = Join-Path $OutDir "pony-$themeName.kdl"
  $kdl = ToKdl $themeName $palettes[$name] $chromes[$name]
  [System.IO.File]::WriteAllText($out, $kdl, [System.Text.UTF8Encoding]::new($false))
  Write-Host "Wrote $out"
}

New-Item -ItemType Directory -Force $OutDir | Out-Null

if ($All) {
  $iterKeys = if ($Light) { $Palettes_Light.Keys } else { $Palettes.Keys }
  foreach ($name in $iterKeys) { WriteOne $name }
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
