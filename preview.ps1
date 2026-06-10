# Live truecolor preview of all Mane 6 themes against a backdrop.
# Usage:
#   preview.ps1                              # uses Catppuccin Mocha base (#1e1e2e)
#   preview.ps1 -Backdrop '#1a1b26'          # Tokyo Night bg
#   preview.ps1 -Backdrop '#0d0d12'          # pitch dark
#   preview.ps1 -All                         # show each pony on 4 different backdrops

param(
  [string]$Backdrop = '#1e1e2e',
  [switch]$All
)

$ESC   = [char]27
$GIT   = [char]0xE0A0
$NODE  = [char]0xF898
$CLOCK = [char]0xF017
$ARR   = [char]0xE0B0

function HexRgb($hex) {
  $h = $hex.TrimStart('#')
  ,@([Convert]::ToInt32($h.Substring(0,2),16),
     [Convert]::ToInt32($h.Substring(2,2),16),
     [Convert]::ToInt32($h.Substring(4,2),16))
}
function Seg($bg, $fg, $text) {
  "$ESC[48;2;$($bg[0]);$($bg[1]);$($bg[2])m$ESC[38;2;$($fg[0]);$($fg[1]);$($fg[2])m$text$ESC[0m"
}
function Arrow($from, $to) {
  "$ESC[48;2;$($to[0]);$($to[1]);$($to[2])m$ESC[38;2;$($from[0]);$($from[1]);$($from[2])m$ARR$ESC[0m"
}
function Tail($c) { "$ESC[38;2;$($c[0]);$($c[1]);$($c[2])m$ARR$ESC[0m" }
function Bar($bg, $w=72) {
  "$ESC[48;2;$($bg[0]);$($bg[1]);$($bg[2])m$(' ' * $w)$ESC[0m"
}

function ShowPony($name, $segs, $bd) {
  $bdRgb = (HexRgb $bd)[0]
  Write-Host ""
  Write-Host "  $name  (backdrop $bd)" -ForegroundColor White
  Write-Host "  $(Bar $bdRgb 72)"
  $line = (Bar $bdRgb 2)
  for ($i=0; $i -lt $segs.Count; $i++) {
    $s = $segs[$i]
    $line += (Seg $s.bg $s.fg " $($s.text) ")
    if ($i -lt $segs.Count - 1) {
      $line += (Arrow $s.bg $segs[$i+1].bg)
    } else {
      $line += (Tail $s.bg)
    }
  }
  # Pad the trailing edge so the backdrop continues to bar width.
  $line += (Bar $bdRgb 30)
  Write-Host "  $line"
  Write-Host "  $(Bar $bdRgb 72)"
}

# --- Mane 6 segment definitions ---
$ponies = @(
  @{ name='Twilight Sparkle'; segs=@(
    @{ bg=@(107,63,160); fg=@(245,230,255); text="~/projects" }
    @{ bg=@(45,27,78);   fg=@(245,169,208); text="$GIT master" }
    @{ bg=@(26,16,51);   fg=@(180,140,232); text="$NODE v22" }
    @{ bg=@(15,8,32);    fg=@(212,184,240); text="$CLOCK 14:32" }
  )}
  @{ name='Rainbow Dash'; segs=@(
    @{ bg=@(93,173,236); fg=@(255,255,255); text="~/projects" }
    @{ bg=@(255,107,107);fg=@(13,27,42);    text="$GIT master" }
    @{ bg=@(255,169,77); fg=@(13,27,42);    text="$NODE v22" }
    @{ bg=@(255,217,61); fg=@(13,27,42);    text=" 1.75" }
    @{ bg=@(107,207,127);fg=@(13,27,42);    text=" 3.12" }
    @{ bg=@(27,58,92);   fg=@(137,207,240); text="$CLOCK 14:32" }
  )}
  @{ name='Pinkie Pie'; segs=@(
    @{ bg=@(232,91,168); fg=@(45,20,36);    text="~/projects" }
    @{ bg=@(92,35,71);   fg=@(108,180,238); text="$GIT master" }
    @{ bg=@(61,24,48);   fg=@(245,169,208); text="$NODE v22" }
    @{ bg=@(45,20,36);   fg=@(245,169,208); text="$CLOCK 14:32" }
  )}
  @{ name='Applejack'; segs=@(
    @{ bg=@(217,119,6);  fg=@(253,232,200); text="~/projects" }
    @{ bg=@(74,140,58);  fg=@(253,232,200); text="$GIT master" }
    @{ bg=@(77,46,26);   fg=@(240,160,75);  text="$NODE v22" }
    @{ bg=@(42,24,16);   fg=@(240,160,75);  text="$CLOCK 14:32" }
  )}
  @{ name='Rarity'; segs=@(
    @{ bg=@(157,126,201);fg=@(245,237,255); text="~/projects" }
    @{ bg=@(45,36,71);   fg=@(127,184,212); text="$GIT master" }
    @{ bg=@(31,26,56);   fg=@(212,192,237); text="$NODE v22" }
    @{ bg=@(26,21,48);   fg=@(212,192,237); text="$CLOCK 14:32" }
  )}
  @{ name='Fluttershy'; segs=@(
    @{ bg=@(212,184,90); fg=@(58,47,31);    text="~/projects" }
    @{ bg=@(74,61,40);   fg=@(244,168,200); text="$GIT master" }
    @{ bg=@(58,47,31);   fg=@(253,233,164); text="$NODE v22" }
    @{ bg=@(45,36,24);   fg=@(244,168,200); text="$CLOCK 14:32" }
  )}
)

$backdrops = if ($All) {
  @('#1e1e2e','#1a1b26','#0d0d12','#16161e')
} else {
  @($Backdrop)
}

foreach ($bd in $backdrops) {
  Write-Host ""
  Write-Host "=== Backdrop $bd ===" -ForegroundColor Cyan
  foreach ($pony in $ponies) {
    ShowPony $pony.name $pony.segs $bd
  }
}
Write-Host ""
