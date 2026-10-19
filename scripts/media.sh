#!/usr/bin/env bash
# Estado do player MPRIS escolhido, em JSON (só emite quando muda).
# Prioridade: Spotify aberto (tocando ou pausado) > outro tocando > outro pausado.
set -u
export LC_ALL=C

FMT=$'{{playerName}}\t{{playerInstance}}\t{{status}}\t{{position}}\t{{mpris:length}}\t{{duration(position)}}\t{{duration(mpris:length)}}\t{{artist}}\t{{title}}'

last=""
while :; do
    out=$(playerctl -a metadata --format "$FMT" 2>/dev/null | jq -sRc '
        split("\n")
        | map(select(length > 0) | split("\t") | {
            name: .[0], player: .[1], status: .[2],
            pos: (.[3] | tonumber? // 0), len: (.[4] | tonumber? // 0),
            pos_str: .[5], len_str: .[6], artist: .[7], title: (.[8:] | join("\t"))
          })
        | map(select(.status == "Playing" or .status == "Paused"))
        | (map(select(.name == "spotify"))[0]
           // map(select(.status == "Playing"))[0]
           // .[0]) as $p
        | if $p == null then
            {active: false, name: "", player: "", status: "", state: "", artist: "", title: "",
             pos_str: "", len_str: "", pct: 0}
          else
            $p + {
              active: true,
              state: (if $p.status == "Playing" then "tocando" else "pausado" end),
              pct: (if $p.len > 0 then ([$p.pos / $p.len * 100, 100] | min) else 0 end)
            }
          end')
    if [[ $out != "$last" ]]; then
        printf '%s\n' "$out"
        last=$out
    fi
    sleep 1
done
