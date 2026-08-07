#!/bin/bash
set -e

# --- Instalar playit.gg (persistente entre rebuilds) ---
if ! command -v playit &> /dev/null; then
  echo "Instalando playit.gg..."
  curl -SsL https://playit-cloud.github.io/ppa/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/playit-cloud.gpg
  echo "deb [signed-by=/usr/share/keyrings/playit-cloud.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
  sudo apt update
  sudo apt install -y playit
else
  echo "playit ja instalado, pulando."
fi

# --- Instalar Forge (so na primeira vez) ---
mkdir -p server
cd server

if [ ! -f run.sh ] && ! ls forge-*.jar 2>/dev/null | grep -qv installer; then
  echo "Instalando Forge..."
  curl -O https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.10/forge-1.20.1-47.4.10-installer.jar
  java -jar forge-1.20.1-47.4.10-installer.jar --installServer
else
  echo "Forge ja instalado, pulando."
fi

echo "eula=true" > eula.txt
mkdir -p mods config

echo "Setup concluido."