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
