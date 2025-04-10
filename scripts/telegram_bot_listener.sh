#!/bin/bash

TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"
OFFSET=0

get_diag_data() {
  CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')
  RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
  RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
  RAM_PERC=$(free | awk '/Mem:/ {printf("%.0f%%", $3/$2 * 100)}')
  CPU_TEMP=$(sensors | grep -m 1 'Core 0' | awk '{print $3}' | sed 's/+//' || echo "N/A")
  HD_TEMP=$(smartctl -A /dev/sda 2>/dev/null | awk '/Temperature_Celsius/ {print $10 "°C"}')
  [[ -z "$HD_TEMP" ]] && HD_TEMP="N/A"
  DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " usados)"}')
  UPTIME=$(uptime -s | xargs -I{} date -d {} "+%d dias, %H horas e %M minutos atrás")

  # Verificação real do processo xmrig
  if pgrep -x xmrig >/dev/null; then
    XMRIG_STATUS="🟢 Ativo"
  else
    XMRIG_STATUS="🔴 FALHA"
  fi

  echo -e "🧠 Uso da CPU: $CPU_USAGE\n💾 RAM usada: ${RAM_USED}MB de ${RAM_TOTAL}MB ($RAM_PERC)\n\n🌡️ Temp CPU: $CPU_TEMP\n🧊 Temp HD: $HD_TEMP\n\n💽 Disco: $DISK\n♻️ Último reinício: $UPTIME\n⛏️ XMRig: $XMRIG_STATUS"
}

send_menu_buttons() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="$message" \
    -d reply_markup='{
      "keyboard":[
        [{"text":"works-1"},{"text":"works-2"}],
        [{"text":"works-3"},{"text":"works-4"}],
        [{"text":"works-5"}]
      ],
      "resize_keyboard":true,
      "one_time_keyboard":true
    }' > /dev/null
}

while true; do
  UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET")

  for row in $(echo "$UPDATES" | jq -c '.result[]'); do
    UPDATE_ID=$(echo "$row" | jq '.update_id')
    MESSAGE=$(echo "$row" | jq -r '.message.text')
    CHAT_ID=$(echo "$row" | jq -r '.message.chat.id')

    OFFSET=$((UPDATE_ID + 1))

    case "$MESSAGE" in
      "/diag")
        send_menu_buttons "Selecione um minerador:"
        ;;
      works-*)
        WORK_SELECTED="$MESSAGE"
        DIAG=$(get_diag_data)
        text=$'📋 Diagnóstico do '"${WORK_SELECTED}"$'\n```\n'"$DIAG"$'\n```'

        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
          -d chat_id="$CHAT_ID" \
          -d text="$text" \
          -d parse_mode="Markdown" > /dev/null
        ;;
    esac
  done

  sleep 1
done
