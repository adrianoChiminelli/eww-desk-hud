#!/usr/bin/env bash
# Sem argumentos: emite o volume do sink padrão em JSON a cada mudança (via pactl subscribe).
# "scroll up|down": ajusta o volume em 5%.
set -u
export LC_ALL=C

SINK=@DEFAULT_AUDIO_SINK@

if [[ ${1:-} == scroll ]]; then
    case ${2:-} in
        up) wpctl set-volume -l 1.0 "$SINK" 5%+ ;;
        down) wpctl set-volume "$SINK" 5%- ;;
    esac
    exit 0
fi

emit() {
    local out pct muted=false
    out=$(wpctl get-volume "$SINK" 2>/dev/null) || return
    pct=$(awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$out")
    [[ $out == *MUTED* ]] && muted=true
    printf -v line '{"pct":%d,"muted":%s}' "$pct" "$muted"
    if [[ $line != "${last:-}" ]]; then
        printf '%s\n' "$line"
        last=$line
    fi
}

emit
# "server" cobre a troca de sink padrão (ex.: fone ↔ caixa)
pactl subscribe 2>/dev/null | while read -r ev; do
    [[ $ev == *" on sink "* || $ev == *" on server "* ]] && emit
done
