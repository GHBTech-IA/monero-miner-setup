#!/bin/bash

CPU_INFO=$(lscpu)
UPTIME=$(uptime -p)
DATETIME=$(date -u "+%a %d %b %Y %T UTC")
IP=$(hostname -I | awk '{print $1}')
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
RAM_USED=$(free -m | awk '/Mem:/ { print $3 }')
RAM_TOTAL=$(free -m | awk '/Mem:/ { print $2 }')
RAM_PERCENT=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
SWAP_USED=$(free -m | awk '/Swap:/ { print $3 }')
SWAP_TOTAL=$(free -m | awk '/Swap:/ { print $2 }')
SWAP_PERCENT=$(free | awk '/Swap/ { if ($2 == 0) print "0"; else printf("%.0f"), $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2 {print $3", Total: "$2" ("$5" usados)"}')

# Extração da CPU
CPU_MODEL=$(echo "$CPU_INFO" | grep "Model name" | head -n1 | awk -F: '{print $2}' | sed 's/^[ \t]*//')
CORES=$(echo "$CPU_INFO" | grep "^CPU(s):" | awk '{print $2}')
SOCKETS=$(echo "$CPU_INFO" | grep "Socket(s):" | awk '{print $2}')
CORES_PER_SOCKET=$(echo "$CPU_INFO" | grep "Core(s) per socket:" | awk '{print $4}')

# Temperatura CPU (usa sensors)
CPU_TEMP=$(sensors | grep -m 1 'Core 0' | awk '{print $3}' | sed 's/+//' || echo "N/A")

# Temperatura do HD (usa smartctl)
HD_TEMP=$(smartctl -A /dev/sda 2>/dev/null | grep -i Temperature_Celsius | awk '{print $10 "°C"}')
[[ -z "$HD_TEMP" ]] && HD_TEMP="N/A"

echo -e "🔍 Status do works-1"
echo -e "🖥️ CPU: $CPU_MODEL"
echo -e "💾 Núcleos: ${CORES} CPUs (${SOCKETS} pacote(s) x núcleo(s))"
echo -e "⏱️ Uptime: $UPTIME"
echo -e "📅 Data/hora: $DATETIME"
echo -e "🌐 IP: $IP"
echo -e "🧠 Uso da CPU: ${CPU_USAGE}%"
echo -e "📈 RAM usada: ${RAM_USED}MB"
echo -e "📊 Memória: ${RAM_PERCENT}% usada"
echo -e "🌡️ Temp CPU: $CPU_TEMP"
echo -e "🧊 Temp HD: $HD_TEMP"
echo -e "🔁 Swap: ${SWAP_USED}MB (${SWAP_PERCENT}%)"
echo -e "💽 Usado: $DISK_USAGE"
