#!/usr/bin/env bash
# Copia a config para ~/.config/eww (cópia, não symlink: o repo pode ser removido depois)
# e instala a entrada de autostart. Pode ser rodado de novo para atualizar.
set -euo pipefail

src=$(cd "$(dirname "$0")" && pwd)
config=${XDG_CONFIG_HOME:-$HOME/.config}
dest=$config/eww
marker=$dest/.eww-desk-hud

if [[ -L $dest ]]; then
    echo "erro: $dest é um symlink; remova-o antes de instalar" >&2
    exit 1
fi

# Config do eww que não é nossa: preserva em backup
if [[ -d $dest && ! -e $marker ]] && [[ -n $(ls -A "$dest") ]]; then
    backup=$dest.bak.$(date +%Y%m%d%H%M%S)
    mv "$dest" "$backup"
    echo "config existente movida para $backup"
fi

mkdir -p "$dest" "$config/autostart"
cp -r "$src/eww.yuck" "$src/eww.scss" "$src/scripts" "$dest/"
touch "$marker"

sed "s|@START@|$dest/scripts/start.sh|" "$src/autostart/eww-desk-hud.desktop" \
    > "$config/autostart/eww-desk-hud.desktop"

echo "instalado em $dest"
echo "autostart: $config/autostart/eww-desk-hud.desktop"
