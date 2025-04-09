#!/bin/bash

LOG_FILE="/var/log/xmrig_watchdog.log"
STATE_FILE="/tmp/xmrig_status"
STATUS="OK"

if pgrep -x "xmrig" > /dev/null; then
    echo "$(date): XMRig está funcionando normalmente." >> $LOG_FILE
    if [ -f $STATE_FILE ] && grep -q "ERROR" $STATE_FILE; then
        echo "OK" > $STATE_FILE
        /home/ghb/monero-miner-setup/scripts/send_telegram.sh "✅ XMRig foi reiniciado com sucesso e está operando normalmente."
    fi
else
    echo "$(date): XMRig NÃO está rodando. Reiniciando o serviço..." >> $LOG_FILE
    echo "ERROR" > $STATE_FILE
    systemctl restart xmrig.service
    /home/ghb/monero-miner-setup/scripts/send_telegram.sh "🚨 XMRig estava parado e foi reiniciado!"
fi
