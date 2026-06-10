# WCAG contrast audit for all 6 pony zellij themes (dark variant by default).
# Pass -Light to audit the light variants instead.
# Thresholds: AA normal text 4.5:1, AA large/UI 3:1, AAA 7:1.

param([switch]$Light)

function HexToRgb([string]$hex) {
  $h = $hex.TrimStart('#')
  [int]$r = [Convert]::ToInt32($h.Substring(0,2),16)
  [int]$g = [Convert]::ToInt32($h.Substring(2,2),16)
  [int]$b = [Convert]::ToInt32($h.Substring(4,2),16)
  ,@($r,$g,$b)
}

function Luminance([int]$r, [int]$g, [int]$b) {
  function L($c) {
    $cs = $c/255.0
    if ($cs -le 0.03928) { $cs/12.92 } else { [Math]::Pow(($cs+0.055)/1.055, 2.4) }
  }
  0.2126*(L $r) + 0.7152*(L $g) + 0.0722*(L $b)
}

function Contrast([string]$hex1, [string]$hex2) {
  $rgb1 = HexToRgb $hex1
  $rgb2 = HexToRgb $hex2
  $l1 = Luminance $rgb1[0] $rgb1[1] $rgb1[2]
  $l2 = Luminance $rgb2[0] $rgb2[1] $rgb2[2]
  if ($l1 -lt $l2) { $tmp = $l1; $l1 = $l2; $l2 = $tmp }
  [Math]::Round(($l1 + 0.05) / ($l2 + 0.05), 2)
}

function Grade($ratio) {
  if ($ratio -ge 7)   { 'AAA' }
  elseif ($ratio -ge 4.5) { 'AA'  }
  elseif ($ratio -ge 3)   { 'UI'  }
  else                    { 'FAIL' }
}

function Mark($g) {
  switch ($g) {
    'AAA'  { 'AAA' }
    'AA'   { 'AA ' }
    'UI'   { 'UI ' }
    'FAIL' { '!!! ' }
  }
}

# === Data (mirrors zellij-pony.ps1) ===
$Palettes = @{
  twilight   = @{ fg='#f5e6ff'; bg='#0a0414'; red='#f5a9d0'; green='#4e9d6a'; yellow='#ffd93d'; blue='#6cb4ee'; magenta='#b48ce8'; cyan='#7fb8d4'; orange='#f0a04b' }
  rainbow    = @{ fg='#ffffff'; bg='#0a1420'; red='#ff6b6b'; green='#6bcf7f'; yellow='#ffd93d'; blue='#5dadec'; magenta='#b388eb'; cyan='#89cff0'; orange='#ffa94d' }
  pinkie     = @{ fg='#fde2f3'; bg='#1a0a14'; red='#e85ba8'; green='#94c973'; yellow='#f9d56e'; blue='#6cb4ee'; magenta='#f5a9d0'; cyan='#89cff0'; orange='#f0a04b' }
  applejack  = @{ fg='#fde8c8'; bg='#150a06'; red='#d97706'; green='#4a8c3a'; yellow='#f5d068'; blue='#6cb4ee'; magenta='#b48ce8'; cyan='#7fb8d4'; orange='#f0a04b' }
  rarity     = @{ fg='#f5edff'; bg='#0f0a1c'; red='#f5a9d0'; green='#94c973'; yellow='#f0d878'; blue='#7fb8d4'; magenta='#9d7ec9'; cyan='#d4c0ed'; orange='#f0a04b' }
  fluttershy = @{ fg='#fff7d6'; bg='#1a140a'; red='#c8506e'; green='#9bb86b'; yellow='#fde9a4'; blue='#a8c0d8'; magenta='#f4a8c8'; cyan='#b8e0d0'; orange='#f0a04b' }
  'fluttershy-swap' = @{ fg='#fff7d6'; bg='#1a140a'; red='#c8506e'; green='#9bb86b'; yellow='#fde9a4'; blue='#a8c0d8'; magenta='#f4a8c8'; cyan='#b8e0d0'; orange='#f0a04b' }
  'fluttershy-pinkbg' = @{ fg='#2d1424'; bg='#fde2f3'; red='#c8506e'; green='#5e7e3a'; yellow='#a87914'; blue='#5e7c98'; magenta='#a8197a'; cyan='#3e7e6c'; orange='#b8541a' }
  'fluttershy-yellowbg' = @{ fg='#2d2418'; bg='#fde9a4'; red='#c8506e'; green='#5e7e3a'; yellow='#a87914'; blue='#5e7c98'; magenta='#8c2858'; cyan='#3e7e6c'; orange='#b8541a' }
}
$Chromes = @{
  twilight   = @{ ru_bg='#b48ce8'; ru_base='#1a1033'; ru_e0='#3d1f6e'; ru_e1='#2d1b4e'; ru_e2='#1a1033'; ru_e3='#0a0414'; rs_bg='#f5a9d0'; rs_base='#1a1033'; rs_e0='#3d1f6e'; rs_e1='#2d1b4e'; rs_e2='#1a1033'; rs_e3='#0a0414' }
  rainbow    = @{ ru_bg='#5dadec'; ru_base='#0d1b2a'; ru_e0='#8c1a1a'; ru_e1='#5a2a8c'; ru_e2='#1a4a18'; ru_e3='#6e3a14'; rs_bg='#ff6b6b'; rs_base='#0d1b2a'; rs_e0='#4a3a08'; rs_e1='#1a3a8c'; rs_e2='#1a4a18'; rs_e3='#3a1a5e' }
  pinkie     = @{ ru_bg='#e85ba8'; ru_base='#2d1424'; ru_e0='#1e4070'; ru_e1='#5c2347'; ru_e2='#2d1424'; ru_e3='#3d1830'; rs_bg='#6cb4ee'; rs_base='#2d1424'; rs_e0='#8c2858'; rs_e1='#5c2347'; rs_e2='#2d1424'; rs_e3='#3d1830' }
  applejack  = @{ ru_bg='#d97706'; ru_base='#2a1810'; ru_e0='#1e4d18'; ru_e1='#4d2e1a'; ru_e2='#2a1810'; ru_e3='#3a2014'; rs_bg='#4a8c3a'; rs_base='#2a1810'; rs_e0='#fde8c8'; rs_e1='#1a0c06'; rs_e2='#2a1810'; rs_e3='#3a2014' }
  rarity     = @{ ru_bg='#9d7ec9'; ru_base='#1a1530'; ru_e0='#2d1f5e'; ru_e1='#2d2447'; ru_e2='#1a1530'; ru_e3='#0f0a1c'; rs_bg='#7fb8d4'; rs_base='#1a1530'; rs_e0='#2d1f5e'; rs_e1='#2d2447'; rs_e2='#1a1530'; rs_e3='#0f0a1c' }
  fluttershy = @{ ru_bg='#fde9a4'; ru_base='#2d2418'; ru_e0='#c8506e'; ru_e1='#4a3d28'; ru_e2='#2d2418'; ru_e3='#3a2f1f'; rs_bg='#f4a8c8'; rs_base='#2d2418'; rs_e0='#1a4c30'; rs_e1='#4a3d28'; rs_e2='#2d2418'; rs_e3='#3a2f1f' }
  'fluttershy-swap' = @{ ru_bg='#f4a8c8'; ru_base='#2d2418'; ru_e0='#1a4c30'; ru_e1='#4a3d28'; ru_e2='#2d2418'; ru_e3='#3a2f1f'; rs_bg='#fde9a4'; rs_base='#2d2418'; rs_e0='#c8506e'; rs_e1='#4a3d28'; rs_e2='#2d2418'; rs_e3='#3a2f1f' }
  'fluttershy-pinkbg' = @{ ru_bg='#a87914'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'; rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4' }
  'fluttershy-yellowbg' = @{ ru_bg='#c8506e'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'; rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4' }
}

$Palettes_Light = @{
  twilight   = @{ fg='#1a1033'; bg='#f5e6ff'; red='#c8506e'; green='#2d8c5e'; yellow='#a87914'; blue='#3a6e98'; magenta='#6b3fa0'; cyan='#3a7090'; orange='#b8541a' }
  rainbow    = @{ fg='#0d1b2a'; bg='#e8f4ff'; red='#b82c2c'; green='#3a8c44'; yellow='#a87914'; blue='#1e4a8c'; magenta='#5e2a8c'; cyan='#1e6e8c'; orange='#b8541a' }
  pinkie     = @{ fg='#2d1424'; bg='#fde2f3'; red='#a8197a'; green='#5e8a3a'; yellow='#a87914'; blue='#3a6e98'; magenta='#a8197a'; cyan='#3a7090'; orange='#b8541a' }
  applejack  = @{ fg='#2a1810'; bg='#fde8c8'; red='#a85d04'; green='#2d6e22'; yellow='#a87914'; blue='#3a6e98'; magenta='#7a5dc4'; cyan='#3a7090'; orange='#a85d04' }
  rarity     = @{ fg='#1a1530'; bg='#f5edff'; red='#c8506e'; green='#3a8c5e'; yellow='#a87914'; blue='#3a6e8c'; magenta='#5e3da0'; cyan='#3a6e8c'; orange='#b8541a' }
  fluttershy = @{ fg='#2d2418'; bg='#fff7d6'; red='#c8506e'; green='#5e7e3a'; yellow='#a87914'; blue='#5e7c98'; magenta='#8c2858'; cyan='#3e7e6c'; orange='#b8541a' }
}
$Chromes_Light = @{
  twilight   = @{ ru_bg='#6b3fa0'; ru_base='#f5e6ff'; ru_e0='#ffd93d'; ru_e1='#f5a9d0'; ru_e2='#f5e6ff'; ru_e3='#fde2f3'; rs_bg='#c8506e'; rs_base='#f5e6ff'; rs_e0='#ffd93d'; rs_e1='#fde2f3'; rs_e2='#f5e6ff'; rs_e3='#fde2f3' }
  rainbow    = @{ ru_bg='#1e4a8c'; ru_base='#e8f4ff'; ru_e0='#ff6b6b'; ru_e1='#ffd93d'; ru_e2='#e8f4ff'; ru_e3='#89cff0'; rs_bg='#b82c2c'; rs_base='#e8f4ff'; rs_e0='#ffd93d'; rs_e1='#e8f4ff'; rs_e2='#e8f4ff'; rs_e3='#ffffff' }
  pinkie     = @{ ru_bg='#a8197a'; ru_base='#fde2f3'; ru_e0='#ffd93d'; ru_e1='#6cb4ee'; ru_e2='#fde2f3'; ru_e3='#f5a9d0'; rs_bg='#1e6e98'; rs_base='#fde2f3'; rs_e0='#f5a9d0'; rs_e1='#ffd93d'; rs_e2='#fde2f3'; rs_e3='#89cff0' }
  applejack  = @{ ru_bg='#a85d04'; ru_base='#fde8c8'; ru_e0='#2a1810'; ru_e1='#fde8c8'; ru_e2='#fde8c8'; ru_e3='#fdc26b'; rs_bg='#2d6e22'; rs_base='#fde8c8'; rs_e0='#fdc26b'; rs_e1='#fde8c8'; rs_e2='#fde8c8'; rs_e3='#fdc26b' }
  rarity     = @{ ru_bg='#5e3da0'; ru_base='#f5edff'; ru_e0='#7fb8d4'; ru_e1='#d4c0ed'; ru_e2='#f5edff'; ru_e3='#f5edff'; rs_bg='#3a6e8c'; rs_base='#f5edff'; rs_e0='#d4c0ed'; rs_e1='#d4c0ed'; rs_e2='#f5edff'; rs_e3='#f5edff' }
  fluttershy = @{ ru_bg='#a87914'; ru_base='#fff7d6'; ru_e0='#fff7d6'; ru_e1='#fde9a4'; ru_e2='#fff7d6'; ru_e3='#fff7d6'; rs_bg='#8c2858'; rs_base='#fff7d6'; rs_e0='#fde9a4'; rs_e1='#f4a8c8'; rs_e2='#fff7d6'; rs_e3='#fde9a4' }
}

if ($Light) { $Palettes = $Palettes_Light; $Chromes = $Chromes_Light }

# === Audit ===
foreach ($name in $Palettes.Keys) {
  $p = $Palettes[$name]
  $c = $Chromes[$name]
  Write-Host ""
  Write-Host "===== $name =====" -ForegroundColor Cyan

  Write-Host "  ribbon_unselected (bg $($c.ru_bg))" -ForegroundColor Yellow
  $checks = @(
    @{ slot='base'; fg=$c.ru_base }
    @{ slot='e0 (hotkey letter)'; fg=$c.ru_e0 }
    @{ slot='e1'; fg=$c.ru_e1 }
    @{ slot='e2'; fg=$c.ru_e2 }
    @{ slot='e3'; fg=$c.ru_e3 }
  )
  foreach ($ch in $checks) {
    $r = Contrast $ch.fg $c.ru_bg
    Write-Host ("    {0,-20} {1} on {2}  =  {3}:1  [{4}]" -f $ch.slot, $ch.fg, $c.ru_bg, $r, (Mark (Grade $r)))
  }

  Write-Host "  ribbon_selected (bg $($c.rs_bg))" -ForegroundColor Yellow
  $checks = @(
    @{ slot='base'; fg=$c.rs_base }
    @{ slot='e0 (hotkey letter)'; fg=$c.rs_e0 }
    @{ slot='e1'; fg=$c.rs_e1 }
    @{ slot='e2'; fg=$c.rs_e2 }
    @{ slot='e3'; fg=$c.rs_e3 }
  )
  foreach ($ch in $checks) {
    $r = Contrast $ch.fg $c.rs_bg
    Write-Host ("    {0,-20} {1} on {2}  =  {3}:1  [{4}]" -f $ch.slot, $ch.fg, $c.rs_bg, $r, (Mark (Grade $r)))
  }

  Write-Host "  text_unselected (bg $($p.bg) - terminal)" -ForegroundColor Yellow
  $checks = @(
    @{ slot='base (fg)'; fg=$p.fg }
    @{ slot='e0 (red)'; fg=$p.red }
    @{ slot='e1 (yellow)'; fg=$p.yellow }
    @{ slot='e2 (cyan)'; fg=$p.cyan }
    @{ slot='e3 (green)'; fg=$p.green }
  )
  foreach ($ch in $checks) {
    $r = Contrast $ch.fg $p.bg
    Write-Host ("    {0,-20} {1} on {2}  =  {3}:1  [{4}]" -f $ch.slot, $ch.fg, $p.bg, $r, (Mark (Grade $r)))
  }
}
Write-Host ""
Write-Host "Thresholds: AAA >=7  /  AA >=4.5  /  UI >=3  /  FAIL <3" -ForegroundColor DarkGray
