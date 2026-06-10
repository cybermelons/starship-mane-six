#!/usr/bin/env bash
# Zellij Mane 6 theme generator (bash port of zellij-pony.ps1).
# Writes KDL theme files under ~/.config/zellij/themes/ (or --out-dir).
# Activate by adding `theme "pony-<name>"` to your zellij config.kdl.
#
# Examples:
#   ./zellij-pony.sh --pony twilight              # write one
#   ./zellij-pony.sh --all                        # write all
#   ./zellij-pony.sh --list
#   ./zellij-pony.sh --pony pinkie --out-dir ./out
#   ./zellij-pony.sh --pony twilight --light      # light-mode variant
#
# Requires bash 4+ (associative arrays).
set -euo pipefail

pony=""; all=0; list=0; light=0; out_dir=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pony) pony="$2"; shift 2 ;;
    --all) all=1; shift ;;
    --list) list=1; shift ;;
    --light) light=1; shift ;;
    --out-dir) out_dir="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$out_dir" ]]; then
  out_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zellij/themes"
fi
config_path="${XDG_CONFIG_HOME:-$HOME/.config}/zellij/config.kdl"

# --- palettes: 11 ANSI slots per pony ---
declare -A P
set_pal() { # name fg bg black white red green yellow blue magenta cyan orange
  P[$1,fg]=$2; P[$1,bg]=$3; P[$1,black]=$4; P[$1,white]=$5
  P[$1,red]=$6; P[$1,green]=$7; P[$1,yellow]=$8
  P[$1,blue]=$9; P[$1,magenta]=${10}; P[$1,cyan]=${11}; P[$1,orange]=${12}
}
#       name        fg       bg       black    white    red      green    yellow   blue     magenta  cyan     orange
set_pal twilight   '#f5e6ff' '#0a0414' '#1a1033' '#f5e6ff' '#f5a9d0' '#4e9d6a' '#ffd93d' '#6cb4ee' '#b48ce8' '#7fb8d4' '#f0a04b'
set_pal rainbow    '#ffffff' '#0a1420' '#0d1b2a' '#ffffff' '#ff6b6b' '#6bcf7f' '#ffd93d' '#5dadec' '#b388eb' '#89cff0' '#ffa94d'
set_pal pinkie     '#fde2f3' '#1a0a14' '#2d1424' '#fde2f3' '#e85ba8' '#94c973' '#f9d56e' '#6cb4ee' '#f5a9d0' '#89cff0' '#f0a04b'
set_pal applejack  '#fde8c8' '#150a06' '#2a1810' '#fde8c8' '#d97706' '#4a8c3a' '#f5d068' '#6cb4ee' '#b48ce8' '#7fb8d4' '#f0a04b'
set_pal rarity     '#f5edff' '#0f0a1c' '#1a1530' '#f5edff' '#f5a9d0' '#94c973' '#f0d878' '#7fb8d4' '#9d7ec9' '#d4c0ed' '#f0a04b'
set_pal fluttershy '#fff7d6' '#1a140a' '#2d2418' '#fff7d6' '#c8506e' '#9bb86b' '#fde9a4' '#a8c0d8' '#f4a8c8' '#b8e0d0' '#f0a04b'
set_pal fluttershy-swap     '#fff7d6' '#1a140a' '#2d2418' '#fff7d6' '#c8506e' '#9bb86b' '#fde9a4' '#a8c0d8' '#f4a8c8' '#b8e0d0' '#f0a04b'
set_pal fluttershy-pinkbg   '#2d1424' '#fde2f3' '#2d1424' '#fde2f3' '#c8506e' '#5e7e3a' '#a87914' '#5e7c98' '#a8197a' '#3e7e6c' '#b8541a'
set_pal fluttershy-yellowbg '#2d2418' '#fde9a4' '#2d2418' '#fde9a4' '#c8506e' '#5e7e3a' '#a87914' '#5e7c98' '#8c2858' '#3e7e6c' '#b8541a'

declare -A PL
set_pall() { PL[$1,fg]=$2; PL[$1,bg]=$3; PL[$1,black]=$4; PL[$1,white]=$5
  PL[$1,red]=$6; PL[$1,green]=$7; PL[$1,yellow]=$8
  PL[$1,blue]=$9; PL[$1,magenta]=${10}; PL[$1,cyan]=${11}; PL[$1,orange]=${12}; }
set_pall twilight   '#1a1033' '#f5e6ff' '#1a1033' '#f5e6ff' '#c8506e' '#2d8c5e' '#a87914' '#3a6e98' '#6b3fa0' '#3a7090' '#b8541a'
set_pall rainbow    '#0d1b2a' '#e8f4ff' '#0d1b2a' '#e8f4ff' '#b82c2c' '#3a8c44' '#a87914' '#1e4a8c' '#5e2a8c' '#1e6e8c' '#b8541a'
set_pall pinkie     '#2d1424' '#fde2f3' '#2d1424' '#fde2f3' '#a8197a' '#5e8a3a' '#a87914' '#3a6e98' '#a8197a' '#3a7090' '#b8541a'
set_pall applejack  '#2a1810' '#fde8c8' '#2a1810' '#fde8c8' '#a85d04' '#2d6e22' '#a87914' '#3a6e98' '#7a5dc4' '#3a7090' '#a85d04'
set_pall rarity     '#1a1530' '#f5edff' '#1a1530' '#f5edff' '#c8506e' '#3a8c5e' '#a87914' '#3a6e8c' '#5e3da0' '#3a6e8c' '#b8541a'
set_pall fluttershy '#2d2418' '#fff7d6' '#2d2418' '#fff7d6' '#c8506e' '#5e7e3a' '#a87914' '#5e7c98' '#8c2858' '#3e7e6c' '#b8541a'

# --- chromes: zellij UI overrides ---
declare -A C
set_chrome() { # name ru_bg ru_base ru_e0 ru_e1 ru_e2 ru_e3 rs_bg rs_base rs_e0 rs_e1 rs_e2 rs_e3 frame_sel frame_un frame_hl ok err
  C[$1,ru_bg]=$2; C[$1,ru_base]=$3; C[$1,ru_e0]=$4; C[$1,ru_e1]=$5; C[$1,ru_e2]=$6; C[$1,ru_e3]=$7
  C[$1,rs_bg]=$8; C[$1,rs_base]=$9; C[$1,rs_e0]=${10}; C[$1,rs_e1]=${11}; C[$1,rs_e2]=${12}; C[$1,rs_e3]=${13}
  C[$1,frame_sel]=${14}; C[$1,frame_un]=${15}; C[$1,frame_hl]=${16}; C[$1,ok]=${17}; C[$1,err]=${18}
}
set_chrome twilight   '#b48ce8' '#1a1033' '#3d1f6e' '#2d1b4e' '#1a1033' '#0a0414' '#f5a9d0' '#1a1033' '#3d1f6e' '#2d1b4e' '#1a1033' '#0a0414' '#b48ce8' '#2d1b4e' '#f5a9d0' '#4e9d6a' '#e85b8a'
set_chrome rainbow    '#5dadec' '#0d1b2a' '#8c1a1a' '#5a2a8c' '#1a4a18' '#6e3a14' '#ff6b6b' '#0d1b2a' '#4a3a08' '#1a3a8c' '#1a4a18' '#3a1a5e' '#89cff0' '#1b3a5c' '#ff6b6b' '#6bcf7f' '#ff6b6b'
set_chrome pinkie     '#e85ba8' '#2d1424' '#1e4070' '#5c2347' '#2d1424' '#3d1830' '#6cb4ee' '#2d1424' '#8c2858' '#5c2347' '#2d1424' '#3d1830' '#f5a9d0' '#5c2347' '#6cb4ee' '#94c973' '#e85ba8'
set_chrome applejack  '#d97706' '#2a1810' '#1e4d18' '#4d2e1a' '#2a1810' '#3a2014' '#4a8c3a' '#2a1810' '#fde8c8' '#1a0c06' '#2a1810' '#3a2014' '#f0a04b' '#4d2e1a' '#4a8c3a' '#4a8c3a' '#d97706'
set_chrome rarity     '#9d7ec9' '#1a1530' '#2d1f5e' '#2d2447' '#1a1530' '#0f0a1c' '#7fb8d4' '#1a1530' '#2d1f5e' '#2d2447' '#1a1530' '#0f0a1c' '#d4c0ed' '#2d2447' '#7fb8d4' '#9be3c8' '#f5a9d0'
set_chrome fluttershy '#fde9a4' '#2d2418' '#c8506e' '#4a3d28' '#2d2418' '#3a2f1f' '#f4a8c8' '#2d2418' '#1a4c30' '#4a3d28' '#2d2418' '#3a2f1f' '#d4b85a' '#4a3d28' '#f4a8c8' '#9bb86b' '#c8506e'
set_chrome fluttershy-swap     '#f4a8c8' '#2d2418' '#1a4c30' '#4a3d28' '#2d2418' '#3a2f1f' '#fde9a4' '#2d2418' '#c8506e' '#4a3d28' '#2d2418' '#3a2f1f' '#f4a8c8' '#4a3d28' '#fde9a4' '#9bb86b' '#c8506e'
set_chrome fluttershy-pinkbg   '#a87914' '#fff7d6' '#fff7d6' '#fde9a4' '#fff7d6' '#fff7d6' '#8c2858' '#fff7d6' '#fde9a4' '#f4a8c8' '#fff7d6' '#fde9a4' '#a87914' '#4a3d28' '#8c2858' '#5e7e3a' '#c8506e'
set_chrome fluttershy-yellowbg '#c8506e' '#fff7d6' '#fff7d6' '#fde9a4' '#fff7d6' '#fff7d6' '#8c2858' '#fff7d6' '#fde9a4' '#f4a8c8' '#fff7d6' '#fde9a4' '#c8506e' '#4a3d28' '#8c2858' '#5e7e3a' '#c8506e'

declare -A CL
set_chromel() { CL[$1,ru_bg]=$2; CL[$1,ru_base]=$3; CL[$1,ru_e0]=$4; CL[$1,ru_e1]=$5; CL[$1,ru_e2]=$6; CL[$1,ru_e3]=$7
  CL[$1,rs_bg]=$8; CL[$1,rs_base]=$9; CL[$1,rs_e0]=${10}; CL[$1,rs_e1]=${11}; CL[$1,rs_e2]=${12}; CL[$1,rs_e3]=${13}
  CL[$1,frame_sel]=${14}; CL[$1,frame_un]=${15}; CL[$1,frame_hl]=${16}; CL[$1,ok]=${17}; CL[$1,err]=${18}; }
set_chromel twilight   '#6b3fa0' '#f5e6ff' '#ffd93d' '#f5a9d0' '#f5e6ff' '#fde2f3' '#c8506e' '#f5e6ff' '#ffd93d' '#fde2f3' '#f5e6ff' '#fde2f3' '#6b3fa0' '#9d7ec9' '#c8506e' '#2d8c5e' '#c8506e'
set_chromel rainbow    '#1e4a8c' '#e8f4ff' '#ff6b6b' '#ffd93d' '#e8f4ff' '#89cff0' '#b82c2c' '#e8f4ff' '#ffd93d' '#e8f4ff' '#e8f4ff' '#ffffff' '#1e4a8c' '#1b3a5c' '#b82c2c' '#3a8c44' '#b82c2c'
set_chromel pinkie     '#a8197a' '#fde2f3' '#ffd93d' '#6cb4ee' '#fde2f3' '#f5a9d0' '#1e6e98' '#fde2f3' '#f5a9d0' '#ffd93d' '#fde2f3' '#89cff0' '#a8197a' '#5c2347' '#1e6e98' '#5e8a3a' '#a8197a'
set_chromel applejack  '#a85d04' '#fde8c8' '#2a1810' '#fde8c8' '#fde8c8' '#fdc26b' '#2d6e22' '#fde8c8' '#fdc26b' '#fde8c8' '#fde8c8' '#fdc26b' '#a85d04' '#4d2e1a' '#2d6e22' '#2d6e22' '#a85d04'
set_chromel rarity     '#5e3da0' '#f5edff' '#7fb8d4' '#d4c0ed' '#f5edff' '#f5edff' '#3a6e8c' '#f5edff' '#d4c0ed' '#d4c0ed' '#f5edff' '#f5edff' '#5e3da0' '#2d2447' '#3a6e8c' '#3a8c5e' '#c8506e'
set_chromel fluttershy '#a87914' '#fff7d6' '#fff7d6' '#fde9a4' '#fff7d6' '#fff7d6' '#8c2858' '#fff7d6' '#fde9a4' '#f4a8c8' '#fff7d6' '#fde9a4' '#a87914' '#4a3d28' '#8c2858' '#5e7e3a' '#c8506e'

dark_ponies=(twilight rainbow pinkie applejack rarity fluttershy fluttershy-swap fluttershy-pinkbg fluttershy-yellowbg)
light_ponies=(twilight rainbow pinkie applejack rarity fluttershy)

if [[ $list -eq 1 ]]; then
  echo "Ponies: ${dark_ponies[*]}"
  exit 0
fi

hexrgb() { local h=${1#\#}; printf '%d %d %d' $((16#${h:0:2})) $((16#${h:2:2})) $((16#${h:4:2})); }

to_kdl() { # name  (reads $pal/$chr nameref via globals below)
  local name=$1
  local fg=${pp[fg]} bg=${pp[bg]} black=${pp[black]} red=${pp[red]} green=${pp[green]}
  local yellow=${pp[yellow]} blue=${pp[blue]} magenta=${pp[magenta]} cyan=${pp[cyan]} white=${pp[white]} orange=${pp[orange]}
  local ru_bg; ru_bg=$(hexrgb "${cc[ru_bg]}"); local ru_base; ru_base=$(hexrgb "${cc[ru_base]}")
  local ru_e0; ru_e0=$(hexrgb "${cc[ru_e0]}"); local ru_e1; ru_e1=$(hexrgb "${cc[ru_e1]}")
  local ru_e2; ru_e2=$(hexrgb "${cc[ru_e2]}"); local ru_e3; ru_e3=$(hexrgb "${cc[ru_e3]}")
  local rs_bg; rs_bg=$(hexrgb "${cc[rs_bg]}"); local rs_base; rs_base=$(hexrgb "${cc[rs_base]}")
  local rs_e0; rs_e0=$(hexrgb "${cc[rs_e0]}"); local rs_e1; rs_e1=$(hexrgb "${cc[rs_e1]}")
  local rs_e2; rs_e2=$(hexrgb "${cc[rs_e2]}"); local rs_e3; rs_e3=$(hexrgb "${cc[rs_e3]}")
  local fr_sel; fr_sel=$(hexrgb "${cc[frame_sel]}"); local fr_un; fr_un=$(hexrgb "${cc[frame_un]}")
  local fr_hl; fr_hl=$(hexrgb "${cc[frame_hl]}")
  local ok_rgb; ok_rgb=$(hexrgb "${cc[ok]}"); local err_rgb; err_rgb=$(hexrgb "${cc[err]}")
  local fg_rgb; fg_rgb=$(hexrgb "$fg"); local bg_rgb; bg_rgb=$(hexrgb "$bg")
  local red_rgb; red_rgb=$(hexrgb "$red"); local yellow_rgb; yellow_rgb=$(hexrgb "$yellow")
  local cyan_rgb; cyan_rgb=$(hexrgb "$cyan"); local green_rgb; green_rgb=$(hexrgb "$green")
  cat <<EOF
// Generated by zellij-pony.sh
// Activate via:  theme "pony-$name"  in your zellij config.kdl
themes {
    pony-$name {
        // ANSI palette (used by programs inside the terminal)
        fg              "$fg"
        bg              "$bg"
        black           "$black"
        red             "$red"
        green           "$green"
        yellow          "$yellow"
        blue            "$blue"
        magenta         "$magenta"
        cyan            "$cyan"
        white           "$white"
        orange          "$orange"

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
            base       $fg_rgb
            background $bg_rgb
            emphasis_0 $red_rgb
            emphasis_1 $yellow_rgb
            emphasis_2 $cyan_rgb
            emphasis_3 $green_rgb
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
            background $bg_rgb
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
EOF
}

write_one() { # base-name
  local base=$1 suffix="" theme_name out
  [[ $light -eq 1 ]] && suffix="-light"
  theme_name="$base$suffix"
  out="$out_dir/pony-$theme_name.kdl"
  declare -A pp cc
  local k
  if [[ $light -eq 1 ]]; then
    for k in fg bg black white red green yellow blue magenta cyan orange; do pp[$k]=${PL[$base,$k]}; done
    for k in ru_bg ru_base ru_e0 ru_e1 ru_e2 ru_e3 rs_bg rs_base rs_e0 rs_e1 rs_e2 rs_e3 frame_sel frame_un frame_hl ok err; do cc[$k]=${CL[$base,$k]}; done
  else
    for k in fg bg black white red green yellow blue magenta cyan orange; do pp[$k]=${P[$base,$k]}; done
    for k in ru_bg ru_base ru_e0 ru_e1 ru_e2 ru_e3 rs_bg rs_base rs_e0 rs_e1 rs_e2 rs_e3 frame_sel frame_un frame_hl ok err; do cc[$k]=${C[$base,$k]}; done
  fi
  to_kdl "$theme_name" >"$out"
  echo "Wrote $out"
}

mkdir -p "$out_dir"

if [[ $all -eq 1 ]]; then
  if [[ $light -eq 1 ]]; then ponies=("${light_ponies[@]}"); else ponies=("${dark_ponies[@]}"); fi
  for n in "${ponies[@]}"; do write_one "$n"; done
  echo
  echo "Add one of these to $config_path :"
  for n in "${dark_ponies[@]}"; do echo "  theme \"pony-$n\""; done
  exit 0
fi

if [[ -z "$pony" ]]; then echo "Specify --pony or --all. Try --list." >&2; exit 1; fi
if [[ -z "${P[$pony,fg]:-}" ]]; then echo "Unknown pony '$pony'. Try --list." >&2; exit 1; fi
write_one "$pony"
echo
echo "Activate by adding to $config_path :"
echo "  theme \"pony-$pony\""
