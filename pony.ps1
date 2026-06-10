# Starship Mane 6 theme generator.
# Examples:
#   pony.ps1 -Pony twilight -Shape round
#   pony.ps1 -Pony pinkie -Shape bubble
#   pony.ps1 -List
#   pony.ps1 -Restore
#
# All glyphs are expressed as [char] codepoints so file encoding can't mangle them.

param(
  [string]$Pony,
  [string]$Shape = 'sharp',
  [switch]$List,
  [switch]$Restore,
  [string]$OutPath = "$HOME\.config\starship.toml"
)

# --- glyph constants (universal Nerd Font codepoints in Powerline / FA / DevIcons) ---
$G_BRANCH   = [char]0xE0A0   # powerline branch
$G_NODE     = [char]0xE718   # devicons nodejs_small
$G_RUST     = [char]0xE7A8   # devicons rust
$G_GO       = [char]0xE626   # devicons go
$G_PHP      = [char]0xE73D   # devicons php
$G_PYTHON   = [char]0xE73C   # devicons python
$G_CLOCK    = [char]0xF017   # FontAwesome clock
$G_DOCS     = [char]0xF02D   # FontAwesome book (Documents)
$G_DOWN     = [char]0xF019   # FontAwesome download
$G_SHADE1   = [char]0x2591   # light shade
$G_SHADE2   = [char]0x2592   # medium shade
$G_SHADE3   = [char]0x2593   # dark shade
$SHADES     = "$G_SHADE1$G_SHADE2$G_SHADE3"

# --- palettes (cutie = each pony's signature glyph) ---
$Palettes = @{
  twilight   = @{ cap='#b48ce8'; capFg='#1a1033'; dir='#6b3fa0'; dirFg='#f5e6ff'; git='#2d1b4e'; gitFg='#f5a9d0'; lang='#1a1033'; langFg='#b48ce8'; time='#0f0820'; timeFg='#d4b8f0'; cutie=[char]0xF005 }
  rainbow    = @{ cap='#89cff0'; capFg='#0d1b2a'; dir='#5dadec'; dirFg='#ffffff'; git='#ff6b6b'; gitFg='#0d1b2a'; lang='#ffd93d'; langFg='#0d1b2a'; time='#1b3a5c'; timeFg='#89cff0'; cutie=[char]0xF0E7 }
  pinkie     = @{ cap='#f5a9d0'; capFg='#2d1424'; dir='#e85ba8'; dirFg='#2d1424'; git='#5c2347'; gitFg='#6cb4ee'; lang='#3d1830'; langFg='#f5a9d0'; time='#2d1424'; timeFg='#f5a9d0'; cutie=[char]0xF004 }
  applejack  = @{ cap='#f0a04b'; capFg='#2a1810'; dir='#d97706'; dirFg='#fde8c8'; git='#4a8c3a'; gitFg='#fde8c8'; lang='#4d2e1a'; langFg='#f0a04b'; time='#2a1810'; timeFg='#f0a04b'; cutie=[char]0xF4D8 }
  rarity     = @{ cap='#d4c0ed'; capFg='#1a1530'; dir='#9d7ec9'; dirFg='#f5edff'; git='#2d2447'; gitFg='#7fb8d4'; lang='#1f1a38'; langFg='#d4c0ed'; time='#1a1530'; timeFg='#d4c0ed'; cutie=[char]0xF219 }
  fluttershy = @{ cap='#fde9a4'; capFg='#2d2418'; dir='#d4b85a'; dirFg='#3a2f1f'; git='#4a3d28'; gitFg='#f4a8c8'; lang='#3a2f1f'; langFg='#fde9a4'; time='#2d2418'; timeFg='#f4a8c8'; cutie='ʚɞ' }
}

# --- shapes ---
$Shapes = @{
  sharp     = @{ kind='cont'; div=[char]0xE0B0 }
  round     = @{ kind='cont'; div=[char]0xE0B4 }
  slant     = @{ kind='cont'; div=[char]0xE0B8 }
  backslant = @{ kind='cont'; div=[char]0xE0BC }
  bubble    = @{ kind='pill'; lcap=[char]0xE0B6; rcap=[char]0xE0B4 }
  capsule   = @{ kind='pill'; lcap=[char]0xE0B7; rcap=[char]0xE0B5 }
  thin      = @{ kind='thin'; div=[char]0xE0B1 }
  block     = @{ kind='block' }
  bracketed = @{ kind='brackets' }
}

if ($List) {
  Write-Host "Ponies: $($Palettes.Keys -join ', ')"
  Write-Host "Shapes: $($Shapes.Keys -join ', ')"
  return
}
if ($Restore) {
  if (Test-Path "$OutPath.bak") { Copy-Item "$OutPath.bak" $OutPath -Force; Write-Host "Restored from $OutPath.bak" }
  else { Write-Host "No backup at $OutPath.bak" }
  return
}
if (-not $Pony) { Write-Error "Specify -Pony. Try -List."; return }
if (-not $Palettes.ContainsKey($Pony))  { Write-Error "Unknown pony '$Pony'. Try -List."; return }
if (-not $Shapes.ContainsKey($Shape))   { Write-Error "Unknown shape '$Shape'. Try -List."; return }

$p = $Palettes[$Pony]
$s = $Shapes[$Shape]

function LangModules($langFg, $langBg) {
  $bgPart = if ($langBg) { " bg:$langBg" } else { '' }
@"

[nodejs]
symbol = "$G_NODE"
format = '[ `$symbol (`$version) ](fg:$langFg$bgPart)'

[rust]
symbol = "$G_RUST"
format = '[ `$symbol (`$version) ](fg:$langFg$bgPart)'

[golang]
symbol = "$G_GO"
format = '[ `$symbol (`$version) ](fg:$langFg$bgPart)'

[php]
symbol = "$G_PHP"
format = '[ `$symbol (`$version) ](fg:$langFg$bgPart)'

[python]
symbol = "$G_PYTHON"
format = '[ `$symbol (`$version )(\(`$virtualenv\) )](fg:$langFg$bgPart)'
python_binary = ["python", "python3"]
"@
}

function DirSubs() {
@"
[directory.substitutions]
"Documents" = "$G_DOCS "
"Downloads" = "$G_DOWN "
"@
}

function HeaderToml($shape, $pony) {
@"
# Generated: pony=$pony shape=$shape (regenerate via pony.ps1)
"`$schema" = 'https://starship.rs/config-schema.json'

"@
}

# --- shape renderers ---
function Continuous($p, $s) {
  $d = $s.div
  $subs = DirSubs
  $header = HeaderToml $Shape $Pony
@"
$header
format = """
[$SHADES]($($p.cap))\
[ $($p.cutie) ](bg:$($p.cap) fg:$($p.capFg))\
`$hostname\
[$d](bg:$($p.dir) fg:$($p.cap))\
`$directory\
[$d](fg:$($p.dir) bg:$($p.git))\
`$git_branch`$git_status\
[$d](fg:$($p.git) bg:$($p.lang))\
`$nodejs`$rust`$golang`$php`$python\
[$d](fg:$($p.lang) bg:$($p.time))\
`$time\
[$d](fg:$($p.time))\
\n`$character"""

[directory]
style = "fg:$($p.dirFg) bg:$($p.dir)"
format = "[ `$path ](`$style)"
truncation_length = 3
truncation_symbol = "…/"

$subs

[git_branch]
symbol = "$G_BRANCH"
format = '[ `$symbol `$branch ](fg:$($p.gitFg) bg:$($p.git))'

[git_status]
format = '[(`$all_status`$ahead_behind )](fg:$($p.gitFg) bg:$($p.git))'
$(LangModules $p.langFg $p.lang)

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK `$time ](fg:$($p.timeFg) bg:$($p.time))'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[`$hostname ](bg:$($p.cap) fg:$($p.capFg))'

[character]
success_symbol = '[$($p.cutie)]($($p.cap))'
error_symbol = '[$($p.cutie)]($($p.git))'
"@
}

function Pills($p, $s) {
  $lc = $s.lcap; $rc = $s.rcap
  $subs = DirSubs
  $header = HeaderToml $Shape $Pony
@"
$header
format = """
[$lc]($($p.cap))[ $($p.cutie) ](bg:$($p.cap) fg:$($p.capFg))`$hostname[$rc](fg:$($p.cap))\
 [$lc]($($p.dir))`$directory[$rc](fg:$($p.dir))\
 [$lc]($($p.git))`$git_branch`$git_status[$rc](fg:$($p.git))\
 [$lc]($($p.lang))`$nodejs`$rust`$golang`$php`$python[$rc](fg:$($p.lang))\
 [$lc]($($p.time))`$time[$rc](fg:$($p.time))\
\n`$character"""

[directory]
style = "fg:$($p.dirFg) bg:$($p.dir)"
format = "[ `$path ](`$style)"
truncation_length = 3
truncation_symbol = "…/"

$subs

[git_branch]
symbol = "$G_BRANCH"
format = '[ `$symbol `$branch ](fg:$($p.gitFg) bg:$($p.git))'

[git_status]
format = '[(`$all_status`$ahead_behind )](fg:$($p.gitFg) bg:$($p.git))'
$(LangModules $p.langFg $p.lang)

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK `$time ](fg:$($p.timeFg) bg:$($p.time))'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[`$hostname ](bg:$($p.cap) fg:$($p.capFg))'

[character]
success_symbol = '[$($p.cutie)]($($p.cap))'
error_symbol = '[$($p.cutie)]($($p.git))'
"@
}

function Thin($p, $s) {
  $d = $s.div
  $subs = DirSubs
  $header = HeaderToml $Shape $Pony
@"
$header
format = """
[$($p.cutie) ](fg:$($p.cap))\
`$hostname\
`$directory\
[$d ](fg:$($p.cap))\
`$git_branch`$git_status\
[$d ](fg:$($p.cap))\
`$nodejs`$rust`$golang`$php`$python\
[$d ](fg:$($p.cap))\
`$time\
\n`$character"""

[directory]
style = "fg:$($p.dir)"
format = "[`$path](`$style) "
truncation_length = 3
truncation_symbol = "…/"

$subs

[git_branch]
symbol = "$G_BRANCH"
format = '[`$symbol `$branch](fg:$($p.gitFg)) '

[git_status]
format = '[(`$all_status`$ahead_behind)](fg:$($p.gitFg))'
$(LangModules $p.langFg $null)

[time]
disabled = false
time_format = "%R"
format = '[$G_CLOCK `$time](fg:$($p.timeFg))'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[`$hostname ](fg:$($p.cap))'

[character]
success_symbol = '[$($p.cutie)](fg:$($p.cap))'
error_symbol = '[$($p.cutie)](fg:$($p.gitFg))'
"@
}

function Block($p, $s) {
  $subs = DirSubs
  $header = HeaderToml $Shape $Pony
@"
$header
format = """
[ $($p.cutie) ](bg:$($p.cap) fg:$($p.capFg))`$hostname \
`$directory \
`$git_branch`$git_status \
`$nodejs`$rust`$golang`$php`$python \
`$time\
\n`$character"""

[directory]
style = "fg:$($p.dirFg) bg:$($p.dir)"
format = "[ `$path ](`$style)"
truncation_length = 3
truncation_symbol = "…/"

$subs

[git_branch]
symbol = "$G_BRANCH"
format = '[ `$symbol `$branch ](fg:$($p.gitFg) bg:$($p.git))'

[git_status]
format = '[(`$all_status`$ahead_behind )](fg:$($p.gitFg) bg:$($p.git))'
$(LangModules $p.langFg $p.lang)

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK `$time ](fg:$($p.timeFg) bg:$($p.time))'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[`$hostname ](bg:$($p.cap) fg:$($p.capFg))'

[character]
success_symbol = '[$($p.cutie)]($($p.cap))'
error_symbol = '[$($p.cutie)]($($p.git))'
"@
}

function Brackets($p, $s) {
  $subs = DirSubs
  $header = HeaderToml $Shape $Pony
@"
$header
format = """
[$($p.cutie) ](fg:$($p.cap))\
`$hostname\
[\[ ](fg:$($p.dir))`$directory[ \]](fg:$($p.dir)) \
[\[ ](fg:$($p.gitFg))`$git_branch`$git_status[ \]](fg:$($p.gitFg)) \
[\[ ](fg:$($p.langFg))`$nodejs`$rust`$golang`$php`$python[ \]](fg:$($p.langFg)) \
[\[ ](fg:$($p.timeFg))`$time[ \]](fg:$($p.timeFg))\
\n`$character"""

[directory]
style = "fg:$($p.dirFg)"
format = "[`$path](`$style)"
truncation_length = 3
truncation_symbol = "…/"

$subs

[git_branch]
symbol = "$G_BRANCH"
format = '[`$symbol `$branch](fg:$($p.gitFg))'

[git_status]
format = '[(`$all_status`$ahead_behind)](fg:$($p.gitFg))'
$(LangModules $p.langFg $null)

[time]
disabled = false
time_format = "%R"
format = '[$G_CLOCK `$time](fg:$($p.timeFg))'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[`$hostname ](fg:$($p.cap))'

[character]
success_symbol = '[$($p.cutie)](fg:$($p.cap))'
error_symbol = '[$($p.cutie)](fg:$($p.gitFg))'
"@
}

# --- dispatch ---
$toml = switch ($s.kind) {
  'cont'     { Continuous $p $s }
  'pill'     { Pills      $p $s }
  'thin'     { Thin       $p $s }
  'block'    { Block      $p $s }
  'brackets' { Brackets   $p $s }
}

if (Test-Path $OutPath) { Copy-Item $OutPath "$OutPath.bak" -Force }
[System.IO.File]::WriteAllText($OutPath, $toml, [System.Text.UTF8Encoding]::new($false))
Write-Host "Wrote $Pony / $Shape to $OutPath (backup: $OutPath.bak)"
Write-Host "Open a new shell to see it."
