




## Passo 2: Configurando a mineração com MoneroOcean

1. Crie o arquivo `xmrig_config/config.json` com seu endereço XMR:
   - Substitua `"SEU_ENDERECO_MONERO"` pelo seu endereço da carteira Monero.
   - A pool padrão usada é `gulf.moneroocean.stream:10128`.

2. Inicie a mineração com o script:

```bash
./scripts/start_miner.sh


---

## Passo 3: Monitoramento e Automação

- Execute o painel de status:

```bash
./monitor/monitor_miner.sh

## 🧱 Passo 4: Testar mineração e configurar o serviço do minerador

---

### 🎯 Objetivo

Verificar se o minerador está funcionando corretamente com a MoneroOcean e configurar o `XMRig` como serviço para iniciar automaticamente com o sistema.

---

### ✅ Etapa 1: Verifique se o minerador está funcionando corretamente

1. Execute o script de inicialização manualmente:

```bash
./scripts/start_miner.sh
```

2. Verifique se há saída semelhante a esta:
```
new job from gulf.moneroocean.stream:10128
init dataset algo rx/0
allocated huge pages...
```

3. Acesse o site da MoneroOcean para verificar se o minerador foi detectado:

🔗 https://moneroocean.stream

- Cole o endereço da sua carteira.
- Pode levar até 5 minutos para o minerador aparecer após enviar os primeiros shares.

---

### ⚠️ Possível erro: "Address Not Found"

Se a mensagem "Address Not Found" aparecer:

1. Verifique se o endereço de carteira está correto no arquivo de configuração:

```bash
nano /home/ghb/monero-miner-setup/xmrig/xmrig_config/config.json
```

Confirme que o campo:
```json
"user": "49FghA146BadPMhsKnXgrgd1aS3uH3EXsaWhe9cn76ZcgGpXjz7AC2eYVoYAayrZNBH7CbAzJ5LUrX5nx8KMECPp7XmUpe8"
```
contém o endereço correto.

2. Se estiver correto, aguarde 1 a 5 minutos até o painel da MoneroOcean atualizar.

---

### 🔁 Etapa 2: Criar serviço systemd para XMRig

1. Crie o arquivo de serviço:
```bash
sudo nano /etc/systemd/system/xmrig.service
```

2. Cole o conteúdo abaixo:
```ini
[Unit]
Description=XMRig Monero Miner
After=network.target

[Service]
ExecStart=/home/ghb/monero-miner-setup/xmrig/xmrig -c /home/ghb/monero-miner-setup/xmrig/xmrig_config/config.json
WorkingDirectory=/home/ghb/monero-miner-setup/xmrig
Restart=always
User=root
Nice=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

> 💡 Altere `User=root` caso esteja usando outro usuário.

3. Atualize e ative o serviço:
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable xmrig.service
sudo systemctl start xmrig.service
```

4. Verifique o status:
```bash
sudo systemctl status xmrig.service
```

5. (Opcional) Veja os logs:
```bash
journalctl -fu xmrig.service
```

---

✅ Pronto! O minerador agora iniciará automaticamente com o sistema.
