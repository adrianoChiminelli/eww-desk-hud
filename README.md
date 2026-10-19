# eww-desk-hud

Desktop widget built with [Eww](https://github.com/elkowar/eww): clock, CPU/RAM/GPU stats and media controls (MPRIS). Pinned to the left side, behind windows, no background.

## Requirements

- Wayland with `wlr-layer-shell` (COSMIC, Hyprland, Sway, KDE… — **not** GNOME)
- Eww ≥ 0.6 with Wayland support
- `bash`, `jq`, `playerctl`, `wpctl`, `pactl`, `nvidia-smi`
- Fonts: JetBrains Mono + a Nerd Font v3 (default: Maple Mono NF)

## Installation

**1. Eww**: install it from your distro's package manager, or build it from source:

```sh
git clone https://github.com/elkowar/eww && cd eww
cargo build --release --no-default-features --features=wayland
install -Dm755 target/release/eww ~/.local/bin/eww
```

**2. Fonts**: install them from your package manager, or download the releases ([JetBrains Mono](https://github.com/JetBrains/JetBrainsMono/releases), [Maple Mono NF](https://github.com/subframe7536/maple-font/releases)) into `~/.local/share/fonts`, then run `fc-cache -f`.

**3. Widget**

```sh
git clone <repo-url> && cd eww-desk-hud
./install.sh
eww daemon && eww open clock
```

`install.sh` copies the config into `~/.config/eww`. It is a copy, not a symlink, so you can delete the cloned repo afterwards. The script also adds an XDG autostart entry, and it backs up any existing eww config before installing. To update, pull the repo and run `./install.sh` again.

If your compositor doesn't support XDG autostart, run `~/.config/eww/scripts/start.sh` from its own config (`exec-once`, `exec`…).

## Usage

```sh
eww reload   # after editing yuck/scss
eww logs     # errors
```

- Volume: click a segment, scroll (±5%), or click `vol` to mute.
- Media: Spotify takes priority. The section hides when no player is active.

## Hardware

Written for an AMD CPU and an NVIDIA GPU.

- Intel CPU: replace `k10temp` with `coretemp` in `scripts/sys.sh`.
- AMD/Intel GPU: rewrite `scripts/gpu.sh`, keeping the same JSON output.

## Customization

- Colors and fonts: `eww.scss`
- Position, monitor and icons: `eww.yuck`
- Update intervals and bar width: `scripts/*.sh`
