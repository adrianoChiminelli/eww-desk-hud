#!/usr/bin/env bash
# CPU (% e temperatura) e RAM em JSON, uma linha a cada INTERVAL segundos.
set -u
export LC_ALL=C

INTERVAL=2
W=20  # largura da barra em blocos

bar() {
    local n=$(( ($1 * W + 50) / 100 )) on off
    (( n > W )) && n=$W
    printf -v on '%*s' "$n" ''
    printf -v off '%*s' "$(( W - n ))" ''
    printf '"on":"%s","off":"%s"' "${on// /█}" "${off// /░}"
}

# hwmonN muda entre boots: localiza pelo nome
temp_file=""
for h in /sys/class/hwmon/hwmon*; do
    [[ $(<"$h/name") == k10temp ]] && temp_file="$h/temp1_input" && break
done

read_cpu() {
    local _ user nice system idle iowait irq softirq steal
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    cpu_idle=$(( idle + iowait ))
    cpu_total=$(( user + nice + system + idle + iowait + irq + softirq + steal ))
}

read_cpu
prev_idle=$cpu_idle prev_total=$cpu_total
sleep 0.5

while :; do
    read_cpu
    dt=$(( cpu_total - prev_total )) di=$(( cpu_idle - prev_idle ))
    cpu=$(( dt > 0 ? (100 * (dt - di) + dt / 2) / dt : 0 ))
    prev_idle=$cpu_idle prev_total=$cpu_total

    temp=0
    [[ -n $temp_file ]] && temp=$(( $(<"$temp_file") / 1000 ))

    while read -r key val _; do
        case $key in
            MemTotal:) mem_total=$val ;;
            MemAvailable:) mem_avail=$val ;;
        esac
    done < /proc/meminfo
    used_kb=$(( mem_total - mem_avail ))
    used_t=$(( (used_kb * 10 + 524288) / 1048576 ))      # GiB em décimos
    total_g=$(( (mem_total + 524288) / 1048576 ))
    ram_pct=$(( 100 * used_kb / mem_total ))

    printf '{"cpu":{"pct":%d,"temp":%d,%s},"ram":{"used":"%d,%d","total":%d,"pct":%d,%s}}\n' \
        "$cpu" "$temp" "$(bar "$cpu")" \
        $(( used_t / 10 )) $(( used_t % 10 )) "$total_g" "$ram_pct" "$(bar "$ram_pct")"

    sleep "$INTERVAL"
done
