#!/bin/bash

# Configurações
TOKEN="7078100178:AAGa3664wjivxXnNu9i3qlJdjG7LhLvypCM"
CHAT_ID="237385199"

MENSAGEM="$1"

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
     -d chat_id="${CHAT_ID}" \
     -d text="${MENSAGEM}" \
     -d parse_mode="HTML" \
     -o /dev/null
