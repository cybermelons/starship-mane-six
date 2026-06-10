# Shape variant preview - Twilight Sparkle palette, 9 terminator styles.
# Uses [char] codepoints so file encoding cannot mangle the glyphs.

$ESC      = [char]27
$ARR      = [char]0xE0B0   # sharp right arrow (filled)
$ARR_THIN = [char]0xE0B1   # thin/outline right arrow
$BUB_L    = [char]0xE0B6   # left bubble cap (filled)
$BUB_R    = [char]0xE0B4   # right bubble cap (filled) -- also the "round" divider
$BUB_L_O  = [char]0xE0B7   # left bubble cap (outline)
$BUB_R_O  = [char]0xE0B5   # right bubble cap (outline)
$SLANT    = [char]0xE0B8   # lower-right slant (forward /)
$BACK     = [char]0xE0BC   # upper-right slant (backward \)
$GIT      = [char]0xE0A0   # git branch
$NODE     = [char]0xF898   # nodejs
$CLOCK    = [char]0xF017   # clock

function Seg($r,$g,$b,$fr,$fg,$fb,$text) {
  "$ESC[48;2;$r;$g;${b}m$ESC[38;2;$fr;$fg;${fb}m$text$ESC[0m"
}
function Glyph($r,$g,$b,$nr,$ng,$nb,$ch) {
  if ($null -eq $nr) { "$ESC[38;2;$r;$g;${b}m$ch$ESC[0m" }
  else { "$ESC[48;2;$nr;$ng;${nb}m$ESC[38;2;$r;$g;${b}m$ch$ESC[0m" }
}
function Fg($r,$g,$b,$ch) { "$ESC[38;2;$r;$g;${b}m$ch$ESC[0m" }

$purple = @(107,63,160); $plum = @(45,27,78); $dark = @(26,16,51); $deep = @(15,8,32)
$text   = @(245,230,255); $pink = @(245,169,208); $lav = @(180,140,232); $time = @(212,184,240)

# Continuous-style renderer (sharp/slant/back/round): swap the divider glyph.
function Continuous($divider, $title) {
  Write-Host ""
  Write-Host "  $title" -ForegroundColor White
  $l  = (Seg   $purple[0] $purple[1] $purple[2] $text[0] $text[1] $text[2] " ~/projects ")
  $l += (Glyph $purple[0] $purple[1] $purple[2] $plum[0] $plum[1] $plum[2] $divider)
  $l += (Seg   $plum[0]   $plum[1]   $plum[2]   $pink[0] $pink[1] $pink[2] " $GIT master ")
  $l += (Glyph $plum[0]   $plum[1]   $plum[2]   $dark[0] $dark[1] $dark[2] $divider)
  $l += (Seg   $dark[0]   $dark[1]   $dark[2]   $lav[0]  $lav[1]  $lav[2]  " $NODE v22 ")
  $l += (Glyph $dark[0]   $dark[1]   $dark[2]   $deep[0] $deep[1] $deep[2] $divider)
  $l += (Seg   $deep[0]   $deep[1]   $deep[2]   $time[0] $time[1] $time[2] " $CLOCK 14:32 ")
  $l += (Fg    $deep[0]   $deep[1]   $deep[2]   $divider)
  Write-Host "  $l"
}

# Pill renderer (bubble/capsule): each segment isolated, gaps between.
function Pills($lcap, $rcap, $title) {
  Write-Host ""
  Write-Host "  $title" -ForegroundColor White
  $l  = (Fg  $purple[0] $purple[1] $purple[2] $lcap)
  $l += (Seg $purple[0] $purple[1] $purple[2] $text[0] $text[1] $text[2] " ~/projects ")
  $l += (Fg  $purple[0] $purple[1] $purple[2] $rcap)
  $l += " "
  $l += (Fg  $plum[0]   $plum[1]   $plum[2]   $lcap)
  $l += (Seg $plum[0]   $plum[1]   $plum[2]   $pink[0] $pink[1] $pink[2] " $GIT master ")
  $l += (Fg  $plum[0]   $plum[1]   $plum[2]   $rcap)
  $l += " "
  $l += (Fg  $dark[0]   $dark[1]   $dark[2]   $lcap)
  $l += (Seg $dark[0]   $dark[1]   $dark[2]   $lav[0]  $lav[1]  $lav[2]  " $NODE v22 ")
  $l += (Fg  $dark[0]   $dark[1]   $dark[2]   $rcap)
  $l += " "
  $l += (Fg  $deep[0]   $deep[1]   $deep[2]   $lcap)
  $l += (Seg $deep[0]   $deep[1]   $deep[2]   $time[0] $time[1] $time[2] " $CLOCK 14:32 ")
  $l += (Fg  $deep[0]   $deep[1]   $deep[2]   $rcap)
  Write-Host "  $l"
}

Continuous $ARR   "1. SHARP        - tokyo-night / pastel-powerline style"
Continuous $BUB_R "2. ROUND        - sharp shape, half-circle dividers (lualine round)"
Continuous $SLANT "3. SLANT        - jetpack style, leans right /"
Continuous $BACK  "4. BACKSLANT    - leans left \\, mirror of slant"
Pills      $BUB_L $BUB_R   "5. BUBBLE       - filled pills with gaps (pastel-powerline)"
Pills      $BUB_L_O $BUB_R_O "6. CAPSULE      - hollow outlined pills, low ink"

Write-Host ""
Write-Host "  7. THIN         - bracketed-segments style, no fills, minimal" -ForegroundColor White
$l  = (Fg $lav[0]    $lav[1]    $lav[2]    "~/projects")
$l += (Fg $purple[0] $purple[1] $purple[2] " $ARR_THIN ")
$l += (Fg $pink[0]   $pink[1]   $pink[2]   "$GIT master")
$l += (Fg $purple[0] $purple[1] $purple[2] " $ARR_THIN ")
$l += (Fg $lav[0]    $lav[1]    $lav[2]    "$NODE v22")
$l += (Fg $purple[0] $purple[1] $purple[2] " $ARR_THIN ")
$l += (Fg $time[0]   $time[1]   $time[2]   "$CLOCK 14:32")
Write-Host "  $l"

Write-Host ""
Write-Host "  8. BLOCK        - colored blocks, single-space gap, no glyph" -ForegroundColor White
$l  = (Seg $purple[0] $purple[1] $purple[2] $text[0] $text[1] $text[2] " ~/projects ")
$l += " "
$l += (Seg $plum[0]   $plum[1]   $plum[2]   $pink[0] $pink[1] $pink[2] " $GIT master ")
$l += " "
$l += (Seg $dark[0]   $dark[1]   $dark[2]   $lav[0]  $lav[1]  $lav[2]  " $NODE v22 ")
$l += " "
$l += (Seg $deep[0]   $deep[1]   $deep[2]   $time[0] $time[1] $time[2] " $CLOCK 14:32 ")
Write-Host "  $l"

Write-Host ""
Write-Host "  9. BRACKETED    - ASCII brackets, font-independent" -ForegroundColor White
$l  = (Fg $lav[0]  $lav[1]  $lav[2]  "[ ~/projects ]")
$l += (Fg $pink[0] $pink[1] $pink[2] "[ master ]")
$l += (Fg $lav[0]  $lav[1]  $lav[2]  "[ v22 ]")
$l += (Fg $time[0] $time[1] $time[2] "[ 14:32 ]")
Write-Host "  $l"

Write-Host ""
