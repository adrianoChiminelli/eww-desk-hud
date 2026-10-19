#!/usr/bin/env bash
# Uso e VRAM da GPU NVIDIA em JSON. Um único nvidia-smi em loop (-lms) em vez de um processo por leitura.
set -u
export LC_ALL=C

INTERVAL_MS=2000
W=20

bar() {
    local n=$(( ($1 * W + 50) / 100 )) on off
    (( n > W )) && n=$W
    printf -v on '%*s' "$n" ''
    printf -v off '%*s' "$(( W - n ))" ''
    printf '"on":"%s","off":"%s"' "${on// /█}" "${off// /░}"
}

# Se o nvidia-smi morrer (ex.: atualização do driver), tenta de novo em vez de congelar o widget
while :; do
    nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total \
        --format=csv,noheader,nounits -lms "$INTERVAL_MS" 2>/dev/null |
    while IFS=', ' read -r util used total; do
        [[ $util =~ ^[0-9]+$ ]] || continue
        used_t=$(( (used * 10 + 512) / 1024 ))   # GiB em décimos
        printf '{"pct":%d,"used":"%d,%d","total":%d,%s}\n' \
            "$util" $(( used_t / 10 )) $(( used_t % 10 )) $(( (total + 512) / 1024 )) "$(bar "$util")"
    done
    sleep 5
done
