#!/bin/bash

# Token e chat ID do seu bot
BOT_TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"
LAST_UPDATE_ID_FILE="/tmp/telegram_last_update_id.txt"

# Inicializa ID da última atualização
if [ ! -f "$LAST_UPDATE_ID_FILE" ]; then
  echo 0 > "$LAST_UPDATE_ID_FILE"
fi

while true; do
  LAST_UPDATE_ID=$(cat "$LAST_UPDATE_ID_FILE")
  RESPONSE=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$((LAST_UPDATE_ID + 1))")

  # Extrai comandos e IDs
  UPDATE_ID=$(echo "$RESPONSE" | jq -r '.result[-1].update_id')
  MESSAGE=$(echo "$RESPONSE" | jq -r '.result[-1].message.text')

  if [[ "$UPDATE_ID" != "null" && "$MESSAGE" != "null" ]]; then
    echo "$UPDATE_ID" > "$LAST_UPDATE_ID_FILE"

    if [[ "$MESSAGE" == "/works-1" ]]; then
      STATS=$(bash /home/ghb/monero-miner-setup/scripts/get_miner_stats.sh)
      curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$STATS" \
        -d parse_mode="HTML" > /dev/null
    fi
  fi

  sleep 5
done
