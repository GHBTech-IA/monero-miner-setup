#!/bin/bash

cpu_info=$(lscpu | grep "Model name" | cut -d: -f2- | xargs)
cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
uptime=$(uptime -p | cut -d " " -f2-)
datetime=$(date -u '+%a %d %b %Y %H:%M:%S UTC')
ip=$(hostname -I | awk '{print $1}')
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
ram_used=$(free -m | awk '/Mem:/ {print $3 "MB"}')
ram_percent=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
swap_used=$(free -m | awk '/Swap:/ {print $3 "MB"}')
disk=$(df -h / | awk 'NR==2 {print $3 " / Total: " $2 " (" $5 " usados)"}')

echo -e "🔍 *Status do works-1*\n\n\
🧠 *CPU:* $cpu_info\n\
🧩 *Núcleos:* $cores\n\
🕒 *Uptime:* $uptime\n\
📅 *Data/hora:* $datetime\n\
🌐 *IP:* $ip\n\
📊 *Uso da CPU:* ${cpu_usage}%\n\
🧮 *RAM usada:* $ram_used\n\
📉 *Memória:* ${ram_percent}% usada\n\
📥 *Swap:* $swap_used\n\
💽 *Disco:* Usado: $disk"
