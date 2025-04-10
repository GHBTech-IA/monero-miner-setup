#!/bin/bash

TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"
OFFSET=0
MINERADOR=$(hostname)
LAST_COMMAND=""

get_miner_data() {
  bash ./get_miner_stats.sh
}

get_status_data() {
  bash ./get_status.sh
}

check_hd_temp_manual() {
  local resultado=""
  local discos=$(lsblk -dno NAME | grep ^sd)

  for disco in $discos; do
    local temp=$(smartctl -A /dev/$disco 2>/dev/null | awk '/Temperature_Celsius/ {print $10}')
    if [[ "$temp" =~ ^[0-9]+$ ]]; then
      resultado+="🧊 Temp do HD /dev/$disco: ${temp}°C\n"
    else
      resultado+="❓ Temp do HD /dev/$disco: Não disponível\n"
    fi
  done

  # Remove o último \n para evitar quebra desnecessária
  resultado=$(echo -e "$resultado" | sed '$d')

  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text=$'🔍 Verificação manual de temperatura:\n\n'"$resultado"
}



send_menu_buttons() {
  local CMD=$1
  curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
    -d chat_id="$CHAT_ID" \
    -d text="Selecione um minerador:" \
    -d reply_markup="$(cat <<EOF
{
  "keyboard": [
    [{"text": "works-1"}, {"text": "works-2"}],
    [{"text": "works-3"}, {"text": "works-4"}],
    [{"text": "works-5"}]
  ],
  "resize_keyboard": true,
  "one_time_keyboard": false
}
EOF
)"
}

while true; do
  UPDATES=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET")
  MESSAGES=$(echo "$UPDATES" | jq -c '.result[]')

  for MSG in $MESSAGES; do
    UPDATE_ID=$(echo "$MSG" | jq '.update_id')
    OFFSET=$((UPDATE_ID + 1))

    MESSAGE_TEXT=$(echo "$MSG" | jq -r '.message.text')
    CHAT_ID=$(echo "$MSG" | jq -r '.message.chat.id')

    case "$MESSAGE_TEXT" in
      "/menu")
        send_menu_buttons "menu"
        LAST_COMMAND="/menu"
        ;;
      "/status")
        send_menu_buttons "status"
        LAST_COMMAND="/status"
        ;;
      "/Teste")
        check_hd_temp_manual
        ;;
      "works-"*)
        WORK_SELECTED="$MESSAGE_TEXT"
        if [[ "$LAST_COMMAND" == "/status" ]]; then
          STATUS=$(get_status_data)
          curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="🔍 Status do ${WORK_SELECTED}\n\`\`\`\n$STATUS\n\`\`\`" \
            -d parse_mode="Markdown"
        else
          MINER_STATS=$(get_miner_data)
          curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="$MINER_STATS"
        fi
        ;;
    esac
  done

  sleep 2
done
