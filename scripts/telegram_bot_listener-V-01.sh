#!/bin/bash

TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"
OFFSET=0
MINERADOR=$(hostname)

get_miner_data() {
  bash ./get_miner_stats.sh
}

get_status_data() {
  bash ./get_status.sh
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
        LAST_COMMAND="menu"
        send_menu_buttons "menu"
        ;;
      "/status")
        LAST_COMMAND="status"
        STATUS=$(get_status_data)
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
          -d chat_id="$CHAT_ID" \
          -d text="🔍 *Status do ${MINERADOR}*\n\n\`\`\`\n$STATUS\n\`\`\`" \
          -d parse_mode="Markdown"
        send_menu_buttons "status"
        ;;
      "works-"*)
        WORK_SELECTED="$MESSAGE_TEXT"
        if [[ "$LAST_COMMAND" == "/status" ]]; then
          STATUS=$(get_status_data)
          curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="🔍 *Status do ${WORK_SELECTED}*\n\n\`\`\`\n$STATUS\n\`\`\`" \
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
