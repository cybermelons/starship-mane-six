#!/usr/bin/env bash
# botan-stripes — demo every slash glyph x stripe count/width.
# Usage: botan-stripes
python3 - <<'PY'
BK,W,GD,K,D="#0e0f12","#f2f3f5","#d4a94a","#2b2f36","#1b1e24"
def rgb(h,bg=False):
    r,g,b=int(h[1:3],16),int(h[3:5],16),int(h[5:7],16)
    return f"\033[{48 if bg else 38};2;{r};{g};{b}m"
def pair(fg,bg):
    fr,fg_,fb=int(fg[1:3],16),int(fg[3:5],16),int(fg[5:7],16)
    br,bg_,bb=int(bg[1:3],16),int(bg[3:5],16),int(bg[5:7],16)
    return f"\033[38;2;{fr};{fg_};{fb};48;2;{br};{bg_};{bb}m"
R="\033[0m"
GLYPHS=[(0xE0BB,"E0BB thin / (canonical)"),(0xE0B9,"E0B9 thin \\ (canonical)"),
        (0xE0BD,"E0BD thin / (redundant)"),(0xE0BC,"E0BC filled upper-left"),
        (0xE0B8,"E0B8 filled lower-left"),(0x2571,"2571 box / (avoid: dbl-width)")]
def stripes(ch,n,gap,fill=W,ink=BK):
    # A STRIPE = A MIRRORED GLYPH PAIR.
    #   [ink fg, fill bg][fill fg, ink bg]  -> slanted band between the diagonals
    o=""
    for i in range(n):
        o+=pair(ink,fill)+ch               # dark ink on light
        o+=pair(fill,ink)+ch               # light ink on dark
        if i<n-1 and gap: o+=rgb(ink,True)+gap
    return o+R
print()
for cp,name in GLYPHS:
    ch=chr(cp)
    print(f"  \033[1m{name}\033[0m")
    for n,label in ((2,"2 stripes"),(3,"3 stripes"),(4,"4 stripes")):
        for gap,gl in (("","tight"),(" ","spaced")):
            norm=rgb(BK,True)+"  "+stripes(ch,n,gap)+rgb(BK,True)+"  "+R
            inv =rgb(BK,True)+"  "+stripes(ch,n,gap,fill=BK,ink=W)+rgb(BK,True)+"  "+R
            print(f"    {label:10} {gl:5} {norm}   INV {inv}")
    print()
print(f"  reference: host{rgb(K,True)} kiri@botan {R}{rgb(BK,True)}{stripes(chr(0x2571),3,' ')}{rgb(D,True)} ~/dir {R}\n")
PY
