# starship-mane-six

Starship prompt theme generator inspired by the Mane 6.
**6 palettes × 9 powerline shapes = 54 combos** from one PowerShell script.

## Quick start

```powershell
# Generate ~/.config/starship.toml
./pony.ps1 -Pony twilight -Shape round
./pony.ps1 -Pony pinkie   -Shape bubble
./pony.ps1 -Pony rainbow  -Shape slant
./pony.ps1 -List          # show all ponies + shapes
./pony.ps1 -Restore       # roll back to previous starship.toml
```

Every run backs up the existing config to `starship.toml.bak` first.
Open a new shell to see the change live.

## Ponies

| Pony | Palette | Cutie glyph |
|---|---|---|
| `twilight`   | deep magic purple + pink streak           | star |
| `rainbow`    | cyan sky + rainbow segments               | bolt |
| `pinkie`     | hot pink party + balloon-blue accents     | heart |
| `applejack`  | earthy orange + apple green               | seedling |
| `rarity`     | violet-white + diamond cyan               | gem |
| `fluttershy` | butter-yellow + rose-pink mane            | `ʚɞ` |

## Shapes

| Shape | Style | Glyphs |
|---|---|---|
| `sharp`     | classic powerline (default)        | ``  |
| `round`     | continuous, half-circle dividers   | ``  |
| `slant`     | jetpack-style angled, leans `/`    | ``  |
| `backslant` | mirror of slant, leans `\`         | ``  |
| `bubble`    | filled pills with gaps             | `  ` |
| `capsule`   | hollow outlined pills              | `  ` |
| `thin`      | outlined arrows, no fills          | ``  |
| `block`     | bg-colored blocks, no glyph        | *(none)* |
| `bracketed` | ASCII `[ ]`, font-independent      | *(none)* |

## Previews

```powershell
./preview.ps1                       # all 6 ponies on a Catppuccin Mocha backdrop
./preview.ps1 -Backdrop '#0d0d12'   # try a different terminal bg
./preview.ps1 -All                  # render against 4 common backdrops
./preview-shapes.ps1                # all 9 shapes in Twilight Sparkle palette
```

## Requirements

- [Starship](https://starship.rs) installed and wired into your shell.
- A **Nerd Font** (CaskaydiaCove NF, JetBrainsMono NF, etc.) with Powerline Extra Symbols (U+E0B0–E0BF).
- A truecolor terminal (Windows Terminal, WezTerm, Alacritty, Kitty, iTerm2…).
- PowerShell 7+ (`pwsh`). Works on Windows, macOS, Linux.

## Ready-made TOMLs

Pre-generated examples for each Mane 6 palette live in [`examples/`](examples/).
If you don't want to run PowerShell, just copy one to `~/.config/starship.toml`.

## How it works

`pony.ps1` keeps two hashtables — `$Palettes` (per-pony hex colors + cutie glyph) and `$Shapes` (per-shape divider/cap glyphs) — then dispatches to a shape renderer that emits a full Starship TOML. All glyphs are stored as `[char]` codepoints so the script never depends on file encoding.

Add your own pony by appending an entry to `$Palettes`. Add a new shape by appending to `$Shapes` plus writing a corresponding renderer function.

## License

MIT
