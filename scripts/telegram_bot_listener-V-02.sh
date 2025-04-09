#!/bin/bash

BOT_TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"
BOT_URL="https://api.telegram.org/bot$BOT_TOKEN"
POSITION_FILE="/tmp/telegram_bot_position.txt"

get_status_info() {
  cpu_model=$(lscpu | grep "Model name" | awk -F: '{print $2}' | sed 's/^[ \t]*//;s/ \+/ /g' | cut -d'@' -f1 | head -n1)
  cpu_speed=$(lscpu | grep "Model name" | awk -F@ '{print $2}' | sed 's/^[ \t]*//')
  cpu_info="🖥️ CPU: $cpu_model @ $cpu_speed"

  cpu_count=$(lscpu | awk '/^CPU\(s\):/ {print $2}')
  sockets=$(lscpu | awk '/Socket\(s\)/ {print $2}')
  cores_per_socket=$(lscpu | awk '/Core\(s\) per socket/ {print $5}')
  core_info="💾 Núcleos: ${cpu_count} CPUs (${sockets} pacote(s) x ${cores_per_socket} núcleo(s))"

  uptime=$(uptime -p | sed 's/up //')
  uptime_info="⏱️ Uptime: $uptime"

  datetime=$(date)
  datetime_info="📅 Data/hora: $datetime"

  ip=$(hostname -I | awk '{print $1}')
  ip_info="🌐 IP: $ip"

  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | cut -d. -f1)
  cpu_info_usage="🧠 Uso da CPU: ${cpu_usage}%"

  mem_used=$(free -m | awk '/Mem:/ {print $3}')
  mem_total=$(free -m | awk '/Mem:/ {print $2}')
  mem_percent=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')
  ram_info="📈 RAM usada: ${mem_used}MB"
  mem_info="📊 Memória: ${mem_percent}% usada"

  swap_used=$(free -m | awk '/Swap:/ {print $3}')
  swap_total=$(free -m | awk '/Swap:/ {print $2}')
  swap_percent=0
  [[ "$swap_total" -gt 0 ]] && swap_percent=$((swap_used * 100 / swap_total))
  swap_info="📂 Swap: ${swap_used}MB (${swap_percent}%)"

  disk_info=$(df -h / | awk 'NR==2 {print "💽 Disco: Usado: "$3" / Total: "$2" ("$5" usados)"}')

  echo -e "$cpu_info\n$core_info\n$uptime_info\n$datetime_info\n$ip_info\n$cpu_info_usage\n$ram_info\n$mem_info\n$swap_info\n$disk_info"
}

send_message() {
  local text="$1"
  curl -s -X POST "$BOT_URL/sendMessage" -d chat_id="$CHAT_ID" -d text="$text" -d parse_mode="HTML"
}

send_menu() {
  curl -s -X POST "$BOT_URL/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="Escolha o minerador para ver o status:" \
    -d reply_markup='{
      "keyboard": [
        [{"text": "/works-1"}, {"text": "/works-2"}],
        [{"text": "/works-3"}, {"text": "/works-4"}],
        [{"text": "/works-5"}]
      ],
      "resize_keyboard": true,
      "one_time_keyboard": true
    }'
}

send_status_response() {
  selected=$(cat "$POSITION_FILE" 2>/dev/null)
  worker_name=$(echo "$selected" | sed 's|/||')
  echo "🛠️ Exibindo status do $worker_name..."

  status_info=$(get_status_info)
  curl -s -X POST "$BOT_URL/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="🔍 <b>Status do $worker_name</b>\n\n<pre>$status_info</pre>" \
    -d parse_mode="HTML"
}

check_updates() {
  offset=0
  while true; do
    response=$(curl -s "$BOT_URL/getUpdates?offset=$offset&timeout=60")
    messages=$(echo "$response" | jq -c '.result[]')

    for message in $messages; do
      update_id=$(echo "$message" | jq '.update_id')
      offset=$((update_id + 1))
      text=$(echo "$message" | jq -r '.message.text')

      case $text in
        "/menu")
          send_menu
          ;;
        "/status" | "/works-1" | "/works-2" | "/works-3" | "/works-4" | "/works-5")
          echo "$text" > "$POSITION_FILE"
          send_status_response
          ;;
      esac
    done

    sleep 1
  done
}

check_updates
