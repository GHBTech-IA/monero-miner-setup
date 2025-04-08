monero-miner-setup/
├── README.md                 # Visão geral do projeto
├── limpeza_inicial.sh       # Script de limpeza do sistema
├── scripts/
│   └── install_xmrig.sh     # Script de instalação e compilação do XMRig
├── configs/
│   └── config-example.json  # Exemplo de configuração do XMRig
└── docs/
    └── etapas.md            # Etapas e anotações do processo

# README.md
# Monero Miner Setup

Este repositório documenta todo o processo de preparação de um sistema Ubuntu para mineração de Monero (XMR) usando XMRig. Inclui limpeza do sistema, instalação, configuração e automação.

## Estrutura
- `limpeza_inicial.sh`: limpa serviços e pacotes desnecessários
- `scripts/install_xmrig.sh`: instala e compila o XMRig
- `configs/config-example.json`: configuração exemplo do minerador
- `docs/etapas.md`: anotações e etapas detalhadas do processo

---

# limpeza_inicial.sh
#!/bin/bash

echo "🚀 Iniciando limpeza inicial do Ubuntu para mineração..."

systemctl stop snapd.service snapd.socket
systemctl disable snapd.service snapd.socket

systemctl stop apt-daily.timer apt-daily-upgrade.timer
systemctl disable apt-daily.timer apt-daily-upgrade.timer

systemctl stop unattended-upgrades.service
systemctl disable unattended-upgrades.service

apt remove --purge -y \
    snapd \
    apport \
    cloud-init \
    fwupd \
    modemmanager \
    open-vm-tools \
    unattended-upgrades \
    update-notifier-common \
    multipath-tools

apt autoremove -y
apt clean

systemctl daemon-reload
systemctl daemon-reexec

echo "✅ Limpeza concluída! Pronto para configurar mineração."

---

# scripts/install_xmrig.sh
#!/bin/bash

set -e

echo "🔧 Instalando dependências..."
sudo apt update && sudo apt install -y git build-essential cmake automake libtool autoconf

echo "📥 Clonando repositório do XMRig..."
git clone https://github.com/xmrig/xmrig.git
cd xmrig

mkdir build && cd build

echo "⚙️ Compilando o XMRig..."
cmake ..
make -j$(nproc)

echo "✅ XMRig instalado com sucesso!"

---

# configs/config-example.json
{
  "autosave": true,
  "cpu": true,
  "opencl": false,
  "cuda": false,
  "pools": [
    {
      "url": "pool.supportxmr.com:3333",
      "user": "<sua_carteira_monero>",
      "pass": "x",
      "keepalive": true,
      "nicehash": false
    }
  ]
}

---

# docs/etapas.md

## Etapas concluídas

### Limpeza do sistema
- Serviços e pacotes removidos
- Script `limpeza_inicial.sh` aplicado com sucesso

### Instalação do minerador
- Dependências instaladas
- XMRig clonado e compilado via `install_xmrig.sh`

### Próximos passos
- Definir carteira e pool
- Gerar configuração final do minerador
- Automatizar inicialização com systemd
