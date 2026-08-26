#!/usr/bin/env bash
# botan-layouts — full-prompt layout variants: where the stripes + gradient live.
set -u
BASE="${BOTAN_BASE:-$HOME/.config/starship-themes/botan.toml}"
OUT="${BOTAN_OUT:-$HOME/.cache/botan-layouts}"
rm -rf "$OUT"; mkdir -p "$OUT"

python3 - "$BASE" "$OUT" <<'PY'
import io,sys,re
base,out=sys.argv[1],sys.argv[2]
S,SL=chr(0xE0B0),chr(0xE0B8)
W,BK,D,K,GD='#f2f3f5','#0e0f12','#1b1e24','#2b2f36','#d4a94a'
G1,G2,G3='#8b9098','#5a5f68','#3f434a'
s=io.open(base,encoding='utf-8').read()
def c(fg,bg): return '[%s](fg:%s bg:%s)'%(S,fg,bg)
def stripes(n=3):
    return ''.join('[%s](fg:%s bg:%s)[%s](fg:%s bg:%s)'%(SL,BK,W,SL,W,BK) for _ in range(n))
plain   = lambda a,b: c(a,b)
str_seg = lambda a,b,n=3: c(a,BK)+stripes(n)+c(BK,b)
ramp    = lambda a,b: c(a,G1)+c(G1,G2)+c(G2,G3)+c(G3,GD)+c(GD,b)

head=s[:s.index('format = """')]
tail=s[s.index('\\n$character"""'):]
def fmt(host_div, dir_div, second_line=''):
    return ('format = """\n'
     '[░▒▓](#2b2f36)\\\n'
     '[ \U0001f981 ](bg:#2b2f36 fg:#d4a94a)\\\n'
     '$username$hostname\\\n'
     +host_div+'\\\n$directory\\\n'+dir_div+'\\\n'
     '$git_branch$git_status\\\n'
     +c(K,D)+'\\\n$nodejs$rust$golang$php$python\\\n'
     +c(D,BK)+'\\\n$time\\\n'+c(BK)[:-1].replace(' bg:','')+'\\\n'
     +second_line)
def endcap(): return '[%s](fg:%s)'%(S,BK)
def build(host_div,dir_div,second=''):
    return ('format = """\n'
     '[░▒▓](#2b2f36)\\\n'
     '[ \U0001f981 ](bg:#2b2f36 fg:#d4a94a)\\\n'
     '$username$hostname\\\n'
     +host_div+'\\\n$directory\\\n'+dir_div+'\\\n'
     '$git_branch$git_status\\\n'
     +c(K,D)+'\\\n$nodejs$rust$golang$php$python\\\n'
     +c(D,BK)+'\\\n$time\\\n'+endcap()+'\\\n'+second)

V={
 'current':        build(str_seg(K,D), ramp(D,K)),
 'stripes-only':   build(str_seg(K,D), plain(D,K)),
 'gradient-only':  build(plain(K,D),   ramp(D,K)),
 'stripes-after':  build(plain(K,D),   c(D,BK)+stripes()+c(BK,K)),
 'stripes-both-thin': build(str_seg(K,D,2), plain(D,K)),
 'stripes-line2':  build(plain(K,D), ramp(D,K),
                    '[%s](fg:%s bg:%s)%s[%s](fg:%s)'%(S,'#2b2f36',BK,stripes(),S,BK)+'\\\n'),
 'minimal':        build(plain(K,D), plain(D,K)),
 'gold-only':      build(plain(K,D), c(D,GD)+c(GD,K)),
}
for n,f in V.items():
    io.open('%s/%s.toml'%(out,n),'w',encoding='utf-8').write(head+f+tail)
io.open('%s/.order'%out,'w').write(''.join(n+'\n' for n in V))
PY
[ -s "$OUT/.order" ] || exit 1
dirs=("$@"); [ ${#dirs[@]} -eq 0 ] && dirs=("$HOME/dotfiles")
for d in "${dirs[@]}"; do
  printf '\n\033[1m── %s ──\033[0m\n\n' "$d"
  while read -r v; do
    printf '  \033[2m%-18s\033[0m\n  ' "$v"
    o=$( cd "$d" && STARSHIP_CONFIG="$OUT/$v.toml" starship prompt 2>/dev/null \
         | sed -e 's/%{//g' -e 's/%}//g' -e '/^[[:space:]]*$/d' )
    if [ -z "$o" ]; then
      printf '\033[31m[empty]\033[0m %s' "$( cd "$d" && STARSHIP_CONFIG="$OUT/$v.toml" starship prompt 2>&1 >/dev/null|head -2|tr '\n' ' ')"
    else printf '%s' "$o"; fi
    printf '\n\n'
  done < "$OUT/.order"
done
printf '\033[2mapply: cp %s/NAME.toml %s && exec zsh\033[0m\n' "$OUT" "$BASE"
