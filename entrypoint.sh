#!/bin/sh
set -e

CONFIG_DIR="/data"
export XDG_CONFIG_HOME="$CONFIG_DIR"
export HOME="$CONFIG_DIR"

echo "=== Inicializando Prowlarr ==="
echo "CONFIG_DIR = $CONFIG_DIR"

mkdir -p "$CONFIG_DIR"
chmod -R 0777 "$CONFIG_DIR" || true

# Copiar indexadores customizados
INDEXERS_SRC="$CONFIG_DIR/Definitions/Indexers"
INDEXERS_DST="$CONFIG_DIR/Definitions/Indexers"

mkdir -p "$INDEXERS_DST"

if [ -d "$INDEXERS_SRC" ]; then
    count=$(find "$INDEXERS_SRC" -name "*.yml" -type f 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "[✓] Encontrados $count indexadores customizados"
        find "$INDEXERS_SRC" -name "*.yml" -type f 2>/dev/null | while read -r file; do
            echo "  → $(basename "$file")"
        done
    else
        echo "[!] Nenhum indexador customizado encontrado"
    fi
else
    echo "[!] Pasta de indexadores não existe"
fi

# Copiar config.xml se existir (criado via UI do Prowlarr)
if [ -f "$CONFIG_DIR/config.xml" ]; then
    echo "[✓] Copiando config.xml..."
    cp -f "$CONFIG_DIR/config.xml" /app/Prowlarr/config.xml 2>/dev/null || true
fi

# Copiar arquivos de configuração importantes
find "$CONFIG_DIR" -maxdepth 1 \( -name "*.json" -o -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" \) -type f 2>/dev/null | while read -r file; do
    echo "[✓] Copiando $(basename "$file")..."
    cp -f "$file" /app/Prowlarr/ 2>/dev/null || true
done

echo ""
echo "=== Iniciando tinyproxy ==="
service tinyproxy start

export http_proxy="http://127.0.0.1:8888"
export https_proxy="http://127.0.0.1:8888"
export DOTNET_SYSTEM_NET_DISABLEIPV6=1

echo "=== Iniciando Prowlarr ==="
exec /app/Prowlarr/Prowlarr \
  --nobrowser \
  --data="$CONFIG_DIR"
