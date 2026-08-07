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

# --- Servidor Minecraft com shutdown gracioso ---
cd server

# Cria um named pipe (FIFO) para mandar comandos ao console do Java
FIFO_PATH="/tmp/mc_console_input"
rm -f "$FIFO_PATH"
mkfifo "$FIFO_PATH"

# Funcao chamada quando o script recebe sinal de termino (SIGTERM/SIGINT)
graceful_shutdown() {
  echo "[shutdown] Sinal de encerramento recebido. Salvando o mundo..."
  echo "stop" > "$FIFO_PATH"
  # Espera o processo Java realmente terminar (ate 60s)
  wait "$JAVA_PID" 2>/dev/null
  echo "[shutdown] Servidor encerrado com seguranca."
  rm -f "$FIFO_PATH"
  exit 0
}

trap graceful_shutdown SIGTERM SIGINT

if [ -f run.sh ]; then
  echo "Usando run.sh gerado pelo Forge"
  # Mantem o FIFO aberto como stdin do processo, permitindo enviar comandos
  tail -f "$FIFO_PATH" | bash run.sh nogui &
  JAVA_PID=$!
else
  JAR=$(ls forge-*.jar 2>/dev/null | grep -v installer | head -n 1)
  if [ -z "$JAR" ]; then
    echo "ERRO: nenhum jar de servidor encontrado. Rode a instalacao primeiro:"
    echo "  java -jar forge-*-installer.jar --installServer"
    exit 1
  fi
  echo "Usando jar: $JAR"
  tail -f "$FIFO_PATH" | java -Xmx6G -Xms2G -jar "$JAR" nogui &
  JAVA_PID=$!
fi

# Espera o processo Java (ou o sinal de shutdown)
wait "$JAVA_PID"