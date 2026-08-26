#!/usr/bin/env bash
# pl-glyphs — print every powerline separator glyph so you can pick one.
python3 - <<'PY'
G=[(0xE0B0,"filled triangle right"),(0xE0B1,"thin chevron right"),
   (0xE0B2,"filled triangle left"),(0xE0B3,"thin chevron left"),
   (0xE0B4,"filled half-circle r"),(0xE0B5,"thin half-circle r"),
   (0xE0B6,"filled half-circle l"),(0xE0B7,"thin half-circle l"),
   (0xE0B8,"lower-left filled"),(0xE0B9,"lower-left thin"),
   (0xE0BA,"lower-right filled"),(0xE0BB,"lower-right thin"),
   (0xE0BC,"UPPER-LEFT filled  <- slant /"),(0xE0BD,"upper-left thin  /"),
   (0xE0BE,"lower-right filled <- slant \\"),(0xE0BF,"lower-right thin \\"),
   (0x2571,"box slash /"),(0x2572,"box backslash")]
DK,GD,W="\033[48;2;27;30;36m","\033[38;2;212;169;74m","\033[38;2;242;243;245m"
R="\033[0m"
print("\n  glyph  codepoint  name                            on-dark   as 3 stripes")
for cp,name in G:
    ch=chr(cp)
    solo=f"\033[48;2;14;15;18m{W} {ch} {R}"
    trip=f"\033[48;2;14;15;18m{W} {ch}{ch}{ch} {R}"
    seg=f"\033[48;2;212;169;74m\033[38;2;27;30;36m{ch}{R}"
    print(f"   {ch}    U+{cp:04X}     {name:30} {solo} {trip}  gold-edge:{seg}")
print()
PY
