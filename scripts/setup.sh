#!/bin/bash
set -e

mkdir -p server
cd server

curl -O https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.10/forge-1.20.1-47.4.10-installer.jar

java -jar forge-1.20.1-47.4.10-installer.jar --installServer

echo "eula=true" > eula.txt

mkdir -p mods config

echo "Setup concluído. Coloque os mods em server/mods/"
