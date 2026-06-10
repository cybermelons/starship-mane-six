# Live truecolor preview of all Mane 6 themes, each on its own complementary
# terminal backdrop, with the full prompt including cutie cap + glyph.
# Usage:
#   preview.ps1                              # each pony on its own backdrop
#   preview.ps1 -Backdrop '#1e1e2e'          # override: same backdrop for all
#   preview.ps1 -Pony fluttershy             # show only one pony

param(
  [string]$Backdrop,
  [string]$Pony
)

$ESC     = [char]27
$ARR     = [char]0xE0B0  # sharp arrow (shape used in preview)
$GIT     = [char]0xE0A0  # powerline branch
$NODE    = [char]0xE718  # devicons nodejs_small
$RUST    = [char]0xE7A8
$GO      = [char]0xE626
$PYTHON  = [char]0xE73C
$CLOCK   = [char]0xF017
$SHADES  = "$([char]0x2591)$([char]0x2592)$([char]0x2593)"

# Cutie glyphs
$STAR      = [char]0xF005
$BOLT      = [char]0xF0E7
$HEART     = [char]0xF004
$SEEDLING  = [char]0xF4D8
$GEM       = [char]0xF219
$BUTTERFLY = 'ʚɞ'

function HexRgb([string]$hex) {
  $h = $hex.TrimStart('#')
  $r = [Convert]::ToInt32($h.Substring(0,2),16)
  $g = [Convert]::ToInt32($h.Substring(2,2),16)
  $b = [Convert]::ToInt32($h.Substring(4,2),16)
  return @($r, $g, $b)
}
function Seg($bg, $fg, $text) {
  "$ESC[48;2;$($bg[0]);$($bg[1]);$($bg[2])m$ESC[38;2;$($fg[0]);$($fg[1]);$($fg[2])m$text$ESC[0m"
}
function Arrow($from, $to) {
  "$ESC[48;2;$($to[0]);$($to[1]);$($to[2])m$ESC[38;2;$($from[0]);$($from[1]);$($from[2])m$ARR$ESC[0m"
}
function Tail($c) { "$ESC[38;2;$($c[0]);$($c[1]);$($c[2])m$ARR$ESC[0m" }
function Bar($bg, $w=78) {
  "$ESC[48;2;$($bg[0]);$($bg[1]);$($bg[2])m$(' ' * $w)$ESC[0m"
}
function PadOn($bg, $w) {
  "$ESC[48;2;$($bg[0]);$($bg[1]);$($bg[2])m$(' ' * $w)$ESC[0m"
}

function ShowPony($pony, $bdHex) {
  $bd  = HexRgb $bdHex
  $cap = $pony.cap
  $capFg = $pony.capFg
  Write-Host ""
  Write-Host "  $($pony.name)  (backdrop $bdHex)" -ForegroundColor White
  Write-Host "  $(Bar $bd)"

  # opening cap: shaded blocks in cap color on backdrop, then cutie on cap bg
  $line  = (PadOn $bd 2)
  $line += (Seg $bd $cap $SHADES)
  $line += (Seg $cap $capFg " $($pony.cutie) ")
  $line += (Arrow $cap $pony.segs[0].bg)
  # segments + arrows between
  for ($i = 0; $i -lt $pony.segs.Count; $i++) {
    $s = $pony.segs[$i]
    $line += (Seg $s.bg $s.fg " $($s.text) ")
    if ($i -lt $pony.segs.Count - 1) {
      $line += (Arrow $s.bg $pony.segs[$i+1].bg)
    } else {
      $line += (Tail $s.bg)
    }
  }
  $line += (PadOn $bd 24)
  Write-Host "  $line"
  Write-Host "  $(Bar $bd)"
}

# Per-pony palette: backdrop + cap + cutie + 4 segments
$ponies = @(
  @{ name='Twilight Sparkle'; backdrop='#120a1f'; cap=@(180,140,232); capFg=@(26,16,51); cutie=$STAR; segs=@(
    @{ bg=@(107,63,160); fg=@(245,230,255); text="~/projects" }
    @{ bg=@(45,27,78);   fg=@(245,169,208); text="$GIT master" }
    @{ bg=@(26,16,51);   fg=@(180,140,232); text="$NODE v22" }
    @{ bg=@(15,8,32);    fg=@(212,184,240); text="$CLOCK 14:32" }
  )}
  @{ name='Rainbow Dash'; backdrop='#0a1420'; cap=@(137,207,240); capFg=@(13,27,42); cutie=$BOLT; segs=@(
    @{ bg=@(93,173,236);  fg=@(255,255,255); text="~/projects" }
    @{ bg=@(255,107,107); fg=@(13,27,42);    text="$GIT master" }
    @{ bg=@(255,217,61);  fg=@(13,27,42);    text="$NODE v22" }
    @{ bg=@(27,58,92);    fg=@(137,207,240); text="$CLOCK 14:32" }
  )}
  @{ name='Pinkie Pie'; backdrop='#1a0a14'; cap=@(245,169,208); capFg=@(45,20,36); cutie=$HEART; segs=@(
    @{ bg=@(232,91,168); fg=@(45,20,36);    text="~/projects" }
    @{ bg=@(92,35,71);   fg=@(108,180,238); text="$GIT master" }
    @{ bg=@(61,24,48);   fg=@(245,169,208); text="$NODE v22" }
    @{ bg=@(45,20,36);   fg=@(245,169,208); text="$CLOCK 14:32" }
  )}
  @{ name='Applejack'; backdrop='#150a06'; cap=@(240,160,75); capFg=@(42,24,16); cutie=$SEEDLING; segs=@(
    @{ bg=@(217,119,6); fg=@(253,232,200); text="~/projects" }
    @{ bg=@(74,140,58); fg=@(253,232,200); text="$GIT master" }
    @{ bg=@(77,46,26);  fg=@(240,160,75);  text="$NODE v22" }
    @{ bg=@(42,24,16);  fg=@(240,160,75);  text="$CLOCK 14:32" }
  )}
  @{ name='Rarity'; backdrop='#0f0a1c'; cap=@(212,192,237); capFg=@(26,21,48); cutie=$GEM; segs=@(
    @{ bg=@(157,126,201); fg=@(245,237,255); text="~/projects" }
    @{ bg=@(45,36,71);    fg=@(127,184,212); text="$GIT master" }
    @{ bg=@(31,26,56);    fg=@(212,192,237); text="$NODE v22" }
    @{ bg=@(26,21,48);    fg=@(212,192,237); text="$CLOCK 14:32" }
  )}
  @{ name='Fluttershy'; backdrop='#1a140a'; cap=@(253,233,164); capFg=@(45,36,24); cutie=$BUTTERFLY; segs=@(
    @{ bg=@(212,184,90); fg=@(58,47,31);    text="~/projects" }
    @{ bg=@(74,61,40);   fg=@(244,168,200); text="$GIT master" }
    @{ bg=@(58,47,31);   fg=@(253,233,164); text="$NODE v22" }
    @{ bg=@(45,36,24);   fg=@(244,168,200); text="$CLOCK 14:32" }
  )}
)

$targets = if ($Pony) {
  $ponies | Where-Object { $_.name -like "*$Pony*" }
} else {
  $ponies
}

foreach ($cur in $targets) {
  $bd = if ($Backdrop) { $Backdrop } else { $cur.backdrop }
  ShowPony $cur $bd
}
Write-Host ""
