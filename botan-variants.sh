#!/usr/bin/env bash
# botan-variants — print botan prompt stripe variants side by side.
# Usage: botan-variants [dir ...]
set -u
BASE="${BOTAN_BASE:-$HOME/.config/starship-themes/botan.toml}"
TMP="${BOTAN_OUT:-$HOME/.cache/botan-variants}"
rm -rf "$TMP"; mkdir -p "$TMP"
[ -r "$BASE" ] || { echo "no base config: $BASE" >&2; exit 1; }

python3 - "$BASE" "$TMP" <<'PY'
import io,sys,re
base,out=sys.argv[1],sys.argv[2]
S=chr(0xE0B0)
s=io.open(base,encoding='utf-8').read()
m=re.search(r'\$directory\\\n(.*?)\\\n\$git_branch', s, re.S)
if not m: sys.exit("can't locate divider run after $directory")
cur=m.group(1)
D,W,MG,DG,GD,K='#1b1e24','#f2f3f5','#8b9098','#5a5f68','#d4a94a','#2b2f36'
def c(fg,bg): return '[%s](fg:%s bg:%s)'%(S,fg,bg)
import os
SL=chr(int(os.environ.get('BOTAN_SLASH','0xE0BD'),16))   # default: thin upper-left slash /
G1,G2,G3='#8b9098','#5a5f68','#3f434a'
def sl(fg,bg): return '[%s](fg:%s bg:%s)'%(SL,fg,bg)
# three white slashes inside the directory bg, between host and dir
BK='#0e0f12'   # black ground
# THE STRIPE IS THE GAP: slash, space, slash, space... N gaps = N stripes.
def stripes(n, gap=' ', light=W, dark=BK):
    # A STRIPE = A MIRRORED GLYPH PAIR:
    #   [dark fg, light bg][light fg, dark bg]
    # The slanted band between the two diagonals IS the stripe.
    out=''
    for i in range(n):
        out+='[%s](fg:%s bg:%s)'%(SL,dark,light)
        out+='[%s](fg:%s bg:%s)'%(SL,light,dark)
        if i<n-1 and gap: out+='[%s](bg:%s)'%(gap,dark)
    return out
# host -> black block containing 3 GAPS between 4 slashes -> directory
HOSTSEP      = c(K,BK)+stripes(3,'')+c(BK,D)      # tight: pairs butt together
HOSTSEP_WIDE = c(K,BK)+stripes(3,' ')+c(BK,D)     # one space between stripes
HOSTSEP_2    = c(K,BK)+stripes(2,'')+c(BK,D)
HOSTSEP_4    = c(K,BK)+stripes(4,'')+c(BK,D)
V=[
 ('current',        cur),
 ('slash-gap1',     c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 ('slash-gap2',     c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 ('slash-2stripe',  c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 ('slash-4',        c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 # grey gradient -> hard gold LAST (gold-pair ending)
 ('grad3-gold',     c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 ('grad2-gold',     c(D,G1)+c(G1,G3)+c(G3,GD)+c(GD,K)),
 ('grad-lt-gold',   c(D,W)+c(W,G1)+c(G1,G2)+c(G2,GD)+c(GD,K)),
 ('grad3-goldpair', c(D,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,K)),
 ('gold-pair',      c(D,GD)+c(GD,K)),
 ('gold-solo',      c(D,K)+c(GD,K)),
 ('ramp-dark-grey', c(D,W)+c(W,DG)+c(DG,GD)+c(GD,K)),
 ('no-accent',      c(D,K)),
]
hs=re.search(r'\$username\$hostname\\\n(.*?)\\\n\$directory', s, re.S)
oldhost=hs.group(1) if hs else None
for n,run in V:
    v=s.replace(cur,run,1)
    if oldhost and n!='current':
        hsep={'slash-gap2':HOSTSEP_WIDE,'slash-2stripe':HOSTSEP_2,'slash-4':HOSTSEP_4}.get(n,HOSTSEP)
        v=v.replace(oldhost,hsep,1)
    io.open('%s/%s.toml'%(out,n),'w',encoding='utf-8').write(v)
io.open('%s/.order'%out,'w').write(''.join(n+'\n' for n,_ in V))
PY
[ -s "$TMP/.order" ] || exit 1

dirs=("$@")
if [ ${#dirs[@]} -eq 0 ]; then
  dirs=("$HOME")
  [ -d "$HOME/dotfiles" ] && dirs+=("$HOME/dotfiles")
  [ -d "$HOME/Documents" ] && dirs+=("$HOME/Documents")
fi

for d in "${dirs[@]}"; do
  printf '\n\033[1m── %s ──\033[0m\n\n' "$d"
  while read -r v; do
    printf '  \033[2m%-15s\033[0m' "$v"
    out=$( cd "$d" && STARSHIP_CONFIG="$TMP/$v.toml" starship prompt 2>/dev/null \
        | sed -e 's/%{//g' -e 's/%}//g' -e '/^[[:space:]]*$/d' | head -1 )
    if [ -z "$out" ]; then
      err=$( cd "$d" && STARSHIP_CONFIG="$TMP/$v.toml" starship prompt 2>&1 >/dev/null | head -3 | tr '\n' ' ' )
      printf '\033[31m[empty]\033[0m %s' "$err"
    else
      printf '%s' "$out"
    fi
    printf '\n'
  done < "$TMP/.order"
done
printf '\n\033[2mvariants in %s — apply with:\n  cp %s/NAME.toml %s\033[0m\n' "$TMP" "$TMP" "$BASE"
