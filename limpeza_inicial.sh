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