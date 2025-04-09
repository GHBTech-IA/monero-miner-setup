#!/bin/bash

# Caminho para o config.json do XMRig
CONFIG_FILE="/home/ghb/monero-miner-setup/xmrig/xmrig_config/config.json"

# Verifica se o arquivo existe
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Erro: config.json não encontrado em $CONFIG_FILE"
  exit 1
fi

# Extrai o endereço da carteira
WALLET=$(jq -r '.pools[0].user' "$CONFIG_FILE")
WORKER=$(jq -r '.pools[0]."rig-id"' "$CONFIG_FILE")

# Endpoint da API
API_URL="https://api.moneroocean.stream/miner/${WALLET}/stats"

# Consulta a API
RESPONSE=$(curl -s "$API_URL")

# Verifica se houve resposta
if [[ -z "$RESPONSE" ]]; then
  echo "Erro: sem resposta da API."
  exit 1
fi

# Extrai os dados
HASHRATE=$(echo "$RESPONSE" | jq '.hash' | awk '{printf "%.2f", $1}')
PENDING=$(echo "$RESPONSE" | jq '.amtDue')
PAID=$(echo "$RESPONSE" | jq '.amtPaid')
HASHES=$(echo "$RESPONSE" | jq '.totalHashes')

# Converte para XMR
PENDING_XMR=$(awk "BEGIN { printf \"%.6f\", $PENDING / 1000000000000 }")
PAID_XMR=$(awk "BEGIN { printf \"%.6f\", $PAID / 1000000000000 }")

# Consulta a cotação em USD via CoinGecko
USD_RATE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=monero&vs_currencies=usd" | jq -r '.monero.usd')
PENDING_USD=$(awk "BEGIN { printf \"%.4f\", $PENDING_XMR * $USD_RATE }")

# Exibe resultado
echo "📟 Minerador: $WORKER"
echo "⚡ Hashrate: $HASHRATE H/s"
echo "💰 Saldo pendente: $PENDING_XMR XMR"
echo "💵 Estimativa em USD: \$$PENDING_USD"
echo "✅ Total pago: $PAID_XMR XMR"
echo "📊 Hashes enviados: $HASHES"

