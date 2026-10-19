#!/usr/bin/env bash
# Sobe o daemon em primeiro plano (processo principal do serviço de autostart do systemd)
# e abre a janela assim que o IPC responder.
set -u

{
    for _ in $(seq 40); do
        eww ping >/dev/null 2>&1 && exec eww open clock
        sleep 0.25
    done
} &

exec eww daemon --no-daemonize
