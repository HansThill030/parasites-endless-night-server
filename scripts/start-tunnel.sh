#!/bin/bash
sudo mkdir -p /run/playit
sudo pkill -f playitd 2>/dev/null
sudo rm -f /run/playit/playitd.sock

sudo playitd --platform-docker \
  --secret-path ~/.config/playit_gg/playit.toml \
  --socket-path /run/playit/playitd.sock &

sleep 2
echo "playitd rodando em background"