#!/bin/bash

# Navega até o diretório do repositório
cd /home/ghb/monero-miner-setup || exit

# Adiciona todos os arquivos
git add .

# Solicita mensagem de commit
read -p "Mensagem de commit: " mensagem

# Usa mensagem padrão se o usuário não digitar nada
if [ -z "$mensagem" ]; then
    mensagem="Atualização automática"
fi

# Realiza o commit
git commit -m "$mensagem"

# Envia para o GitHub
git push origin main
