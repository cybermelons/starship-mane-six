#!/usr/bin/env bash
# Starship Mane 6 theme generator (bash port of pony.ps1).
# Examples:
#   ./pony.sh --pony twilight --shape round
#   ./pony.sh --pony pinkie --shape bubble
#   ./pony.sh --list
#   ./pony.sh --restore
#
# Requires bash 4+ (associative arrays). Glyphs are emitted as UTF-8.
set -euo pipefail

pony=""; shape="sharp"; list=0; restore=0
out_path="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pony) pony="$2"; shift 2 ;;
    --shape) shape="$2"; shift 2 ;;
    --list) list=1; shift ;;
    --restore) restore=1; shift ;;
    --out-path) out_path="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# --- glyph constants (Nerd Font codepoints) ---
G_BRANCH=$''; G_NODE=$''; G_RUST=$''; G_GO=$''
G_PHP=$''; G_PYTHON=$''; G_CLOCK=$''; G_DOCS=$''; G_DOWN=$''
SHADES=$'░▒▓'

# --- palettes (cutie = each pony's signature glyph) ---
declare -A P
set_pal() { # name cap capFg dir dirFg git gitFg lang langFg time timeFg cutie
  P[$1,cap]=$2; P[$1,capFg]=$3; P[$1,dir]=$4; P[$1,dirFg]=$5; P[$1,git]=$6; P[$1,gitFg]=$7
  P[$1,lang]=$8; P[$1,langFg]=$9; P[$1,time]=${10}; P[$1,timeFg]=${11}; P[$1,cutie]=${12}
}
set_pal twilight   '#b48ce8' '#1a1033' '#6b3fa0' '#f5e6ff' '#2d1b4e' '#f5a9d0' '#1a1033' '#b48ce8' '#0f0820' '#d4b8f0' $''
set_pal rainbow    '#89cff0' '#0d1b2a' '#5dadec' '#ffffff' '#ff6b6b' '#0d1b2a' '#ffd93d' '#0d1b2a' '#1b3a5c' '#89cff0' $''
set_pal pinkie     '#f5a9d0' '#2d1424' '#e85ba8' '#2d1424' '#5c2347' '#6cb4ee' '#3d1830' '#f5a9d0' '#2d1424' '#f5a9d0' $''
set_pal applejack  '#f0a04b' '#2a1810' '#d97706' '#fde8c8' '#4a8c3a' '#fde8c8' '#4d2e1a' '#f0a04b' '#2a1810' '#f0a04b' $''
set_pal rarity     '#d4c0ed' '#1a1530' '#9d7ec9' '#f5edff' '#2d2447' '#7fb8d4' '#1f1a38' '#d4c0ed' '#1a1530' '#d4c0ed' $''
set_pal fluttershy '#fde9a4' '#2d2418' '#d4b85a' '#3a2f1f' '#4a3d28' '#f4a8c8' '#3a2f1f' '#fde9a4' '#2d2418' '#f4a8c8' $'ʚɞ'

ponies=(twilight rainbow pinkie applejack rarity fluttershy)
shapes=(sharp round slant backslant bubble capsule thin block bracketed)

# shape kind + glyphs
declare -A SK SDIV SLCAP SRCAP
SK[sharp]=cont;     SDIV[sharp]=$''
SK[round]=cont;     SDIV[round]=$''
SK[slant]=cont;     SDIV[slant]=$''
SK[backslant]=cont; SDIV[backslant]=$''
SK[bubble]=pill;    SLCAP[bubble]=$'';  SRCAP[bubble]=$''
SK[capsule]=pill;   SLCAP[capsule]=$''; SRCAP[capsule]=$''
SK[thin]=thin;      SDIV[thin]=$''
SK[block]=block
SK[bracketed]=brackets

if [[ $list -eq 1 ]]; then
  echo "Ponies: ${ponies[*]}"
  echo "Shapes: ${shapes[*]}"
  exit 0
fi
if [[ $restore -eq 1 ]]; then
  if [[ -f "$out_path.bak" ]]; then cp -f "$out_path.bak" "$out_path"; echo "Restored from $out_path.bak"
  else echo "No backup at $out_path.bak"; fi
  exit 0
fi
if [[ -z "$pony" ]]; then echo "Specify --pony. Try --list." >&2; exit 1; fi
if [[ -z "${SK[$shape]:-}" ]]; then echo "Unknown shape '$shape'. Try --list." >&2; exit 1; fi
if [[ -z "${P[$pony,cap]:-}" ]]; then echo "Unknown pony '$pony'. Try --list." >&2; exit 1; fi

cap=${P[$pony,cap]}; capFg=${P[$pony,capFg]}; dir=${P[$pony,dir]}; dirFg=${P[$pony,dirFg]}
git=${P[$pony,git]}; gitFg=${P[$pony,gitFg]}; lang=${P[$pony,lang]}; langFg=${P[$pony,langFg]}
tm=${P[$pony,time]}; tmFg=${P[$pony,timeFg]}; cutie=${P[$pony,cutie]}

lang_modules() { # langFg [langBg]
  local lfg="$1" lbg="${2:-}" bgpart=""
  [[ -n "$lbg" ]] && bgpart=" bg:$lbg"
  cat <<EOF

[nodejs]
symbol = "$G_NODE"
format = '[ \$symbol (\$version) ](fg:$lfg$bgpart)'

[rust]
symbol = "$G_RUST"
format = '[ \$symbol (\$version) ](fg:$lfg$bgpart)'

[golang]
symbol = "$G_GO"
format = '[ \$symbol (\$version) ](fg:$lfg$bgpart)'

[php]
symbol = "$G_PHP"
format = '[ \$symbol (\$version) ](fg:$lfg$bgpart)'

[python]
symbol = "$G_PYTHON"
format = '[ \$symbol (\$version )(\(\$virtualenv\) )](fg:$lfg$bgpart)'
python_binary = ["python", "python3"]
EOF
}

dir_subs() {
  cat <<EOF
[directory.substitutions]
"Documents" = "$G_DOCS "
"Downloads" = "$G_DOWN "
EOF
}

header_toml() {
  cat <<EOF
# Generated: pony=$pony shape=$shape (regenerate via pony.sh)
"\$schema" = 'https://starship.rs/config-schema.json'

EOF
}

continuous() {
  local d=${SDIV[$shape]}
  header_toml
  cat <<EOF
format = """
[$SHADES]($cap)\\
[ $cutie ](bg:$cap fg:$capFg)\\
\$hostname\\
[$d](bg:$dir fg:$cap)\\
\$directory\\
[$d](fg:$dir bg:$git)\\
\$git_branch\$git_status\\
[$d](fg:$git bg:$lang)\\
\$nodejs\$rust\$golang\$php\$python\\
[$d](fg:$lang bg:$tm)\\
\$time\\
[$d](fg:$tm)\\
\n\$character"""

[directory]
style = "fg:$dirFg bg:$dir"
format = "[ \$path ](\$style)"
truncation_length = 3
truncation_symbol = "…/"

$(dir_subs)

[git_branch]
symbol = "$G_BRANCH"
format = '[ \$symbol \$branch ](fg:$gitFg bg:$git)'

[git_status]
format = '[(\$all_status\$ahead_behind )](fg:$gitFg bg:$git)'
$(lang_modules "$langFg" "$lang")

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK \$time ](fg:$tmFg bg:$tm)'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[\$hostname ](bg:$cap fg:$capFg)'

[character]
success_symbol = '[$cutie]($cap)'
error_symbol = '[$cutie]($git)'
EOF
}

pills() {
  local lc=${SLCAP[$shape]} rc=${SRCAP[$shape]}
  header_toml
  cat <<EOF
format = """
[$lc]($cap)[ $cutie ](bg:$cap fg:$capFg)\$hostname[$rc](fg:$cap)\\
 [$lc]($dir)\$directory[$rc](fg:$dir)\\
 [$lc]($git)\$git_branch\$git_status[$rc](fg:$git)\\
 [$lc]($lang)\$nodejs\$rust\$golang\$php\$python[$rc](fg:$lang)\\
 [$lc]($tm)\$time[$rc](fg:$tm)\\
\n\$character"""

[directory]
style = "fg:$dirFg bg:$dir"
format = "[ \$path ](\$style)"
truncation_length = 3
truncation_symbol = "…/"

$(dir_subs)

[git_branch]
symbol = "$G_BRANCH"
format = '[ \$symbol \$branch ](fg:$gitFg bg:$git)'

[git_status]
format = '[(\$all_status\$ahead_behind )](fg:$gitFg bg:$git)'
$(lang_modules "$langFg" "$lang")

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK \$time ](fg:$tmFg bg:$tm)'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[\$hostname ](bg:$cap fg:$capFg)'

[character]
success_symbol = '[$cutie]($cap)'
error_symbol = '[$cutie]($git)'
EOF
}

thin() {
  local d=${SDIV[$shape]}
  header_toml
  cat <<EOF
format = """
[$cutie ](fg:$cap)\\
\$hostname\\
\$directory\\
[$d ](fg:$cap)\\
\$git_branch\$git_status\\
[$d ](fg:$cap)\\
\$nodejs\$rust\$golang\$php\$python\\
[$d ](fg:$cap)\\
\$time\\
\n\$character"""

[directory]
style = "fg:$dir"
format = "[\$path](\$style) "
truncation_length = 3
truncation_symbol = "…/"

$(dir_subs)

[git_branch]
symbol = "$G_BRANCH"
format = '[\$symbol \$branch](fg:$gitFg) '

[git_status]
format = '[(\$all_status\$ahead_behind)](fg:$gitFg)'
$(lang_modules "$langFg")

[time]
disabled = false
time_format = "%R"
format = '[$G_CLOCK \$time](fg:$tmFg)'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[\$hostname ](fg:$cap)'

[character]
success_symbol = '[$cutie](fg:$cap)'
error_symbol = '[$cutie](fg:$gitFg)'
EOF
}

block() {
  header_toml
  cat <<EOF
format = """
[ $cutie ](bg:$cap fg:$capFg)\$hostname \\
\$directory \\
\$git_branch\$git_status \\
\$nodejs\$rust\$golang\$php\$python \\
\$time\\
\n\$character"""

[directory]
style = "fg:$dirFg bg:$dir"
format = "[ \$path ](\$style)"
truncation_length = 3
truncation_symbol = "…/"

$(dir_subs)

[git_branch]
symbol = "$G_BRANCH"
format = '[ \$symbol \$branch ](fg:$gitFg bg:$git)'

[git_status]
format = '[(\$all_status\$ahead_behind )](fg:$gitFg bg:$git)'
$(lang_modules "$langFg" "$lang")

[time]
disabled = false
time_format = "%R"
format = '[ $G_CLOCK \$time ](fg:$tmFg bg:$tm)'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[\$hostname ](bg:$cap fg:$capFg)'

[character]
success_symbol = '[$cutie]($cap)'
error_symbol = '[$cutie]($git)'
EOF
}

brackets() {
  header_toml
  cat <<EOF
format = """
[$cutie ](fg:$cap)\\
\$hostname\\
[\[ ](fg:$dir)\$directory[ \]](fg:$dir) \\
[\[ ](fg:$gitFg)\$git_branch\$git_status[ \]](fg:$gitFg) \\
[\[ ](fg:$langFg)\$nodejs\$rust\$golang\$php\$python[ \]](fg:$langFg) \\
[\[ ](fg:$tmFg)\$time[ \]](fg:$tmFg)\\
\n\$character"""

[directory]
style = "fg:$dirFg"
format = "[\$path](\$style)"
truncation_length = 3
truncation_symbol = "…/"

$(dir_subs)

[git_branch]
symbol = "$G_BRANCH"
format = '[\$symbol \$branch](fg:$gitFg)'

[git_status]
format = '[(\$all_status\$ahead_behind)](fg:$gitFg)'
$(lang_modules "$langFg")

[time]
disabled = false
time_format = "%R"
format = '[$G_CLOCK \$time](fg:$tmFg)'

[hostname]
ssh_only = true
ssh_symbol = ""
format = '[\$hostname ](fg:$cap)'

[character]
success_symbol = '[$cutie](fg:$cap)'
error_symbol = '[$cutie](fg:$gitFg)'
EOF
}

case "${SK[$shape]}" in
  cont)     toml=$(continuous) ;;
  pill)     toml=$(pills) ;;
  thin)     toml=$(thin) ;;
  block)    toml=$(block) ;;
  brackets) toml=$(brackets) ;;
esac

[[ -f "$out_path" ]] && cp -f "$out_path" "$out_path.bak"
printf '%s\n' "$toml" >"$out_path"
echo "Wrote $pony / $shape to $out_path (backup: $out_path.bak)"
echo "Open a new shell to see it."
