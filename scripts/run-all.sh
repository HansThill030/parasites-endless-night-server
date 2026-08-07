#!/bin/bash

# --- Keepalive (evita timeout de inatividade do Codespace) ---
(
  while true; do
    echo "[keepalive] $(date '+%Y-%m-%d %H:%M:%S') - servidor ativo"
    sleep 300
  done
) &

# --- Túnel playit.gg ---
sudo mkdir -p /run/playit
sudo pkill -f playitd 2>/dev/null
sudo rm -f /run/playit/playitd.sock

sudo playitd --platform-docker \
  --secret-path ~/.config/playit_gg/playit.toml \
  --socket-path /run/playit/playitd.sock &

sleep 2
echo "playitd rodando em background"

# --- Servidor Minecraft ---
cd server

if [ -f run.sh ]; then
  echo "Usando run.sh gerado pelo Forge"
  bash run.sh nogui
else
  JAR=$(ls forge-*.jar 2>/dev/null | grep -v installer | head -n 1)
  if [ -z "$JAR" ]; then
    echo "ERRO: nenhum jar de servidor encontrado. Rode a instalacao primeiro:"
    echo "  java -jar forge-*-installer.jar --installServer"
    exit 1
  fi
  echo "Usando jar: $JAR"
  java -Xmx6G -Xms2G -jar "$JAR" nogui
fi