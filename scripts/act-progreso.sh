#!/bin/bash

set -euo pipefail

fecha_inicio="2026-10-21"
fecha_actual=$(date +%Y-%m-%d)

inicio_sec=$(date -d "$fecha_inicio" +%s)
actual_sec=$(date -d "$fecha_actual" +%s)
dif_sec=$((actual_sec - inicio_sec))
dias_pasados=$((dif_sec / 86400))

if [[ "$dias_pasados" -lt 0 ]]; then
    dias_pasados=0
fi

if [[ ! -f "README.md" ]]; then
    echo "[!] README.md no encontrado" >&2
    exit 1
fi

sed -E -i.bak "s/\*\*Día actual: [0-9]{1,3}\/ 365\*\*/\*\*Día actual: $dias_pasados\/ 365\*\*/g" README.md

if diff -q README.md README.md.bak >/dev/null 2>&1; then
    echo "[=] Sin cambios necesarios"
    rm README.md.bak
    exit 0
fi

rm README.md.bak
echo "[+] README.md actualizado: Día $dias_pasados/365"