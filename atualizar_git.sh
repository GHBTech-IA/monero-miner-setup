#!/bin/bash

# Navega até o diretório do repositório
cd /home/ghb/monero-miner-setup || exit

# Adiciona todos os arquivos
git add .

# Obtém data e hora atual
data_atual=$(date +"%Y-%m-%d %H:%M:%S")

# Solicita mensagem opcional do usuário
read -p "Mensagem de commit (pressione Enter para usar padrão): " mensagem

# Define a mensagem de commit
if [ -z "$mensagem" ]; then
    mensagem="Atualização automática em $data_atual"
else
    mensagem="$mensagem – $data_atual"
fi

# Realiza o commit
git commit -m "$mensagem"

# Envia para o GitHub
git push origin main

# Registra o commit no log local
echo "$data_atual | $mensagem" >> /home/ghb/monero-miner-setup/logs/commit-log.txt
