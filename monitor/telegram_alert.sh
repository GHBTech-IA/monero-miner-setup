#!/bin/bash

# Configurações
BOT_TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"

if ! pgrep -x "xmrig" > /dev/null
then
  curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
  -d chat_id="$CHAT_ID" \
  -d text="🚨 Atenção! O processo XMRig não está rodando."
fi
