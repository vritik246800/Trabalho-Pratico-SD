#!/usr/bin/env bash
# Baixa uma imagem da internet e reduz para foto de produto (.jpg 480px, < 40 KB) :: AgroGest/src/main/webapp/img/produtos/<nome>.jpg
# Uso :: ./img.sh <url> <nome>        ex. ./img.sh https://exemplo.com/milho.png semente-milho
# Depois, no formulário do produto, campo "Foto (URL)" :: http://localhost:8081/agrogest/img/produtos/<nome>.jpg
# Precisa de curl e ffmpeg (brew install ffmpeg). macOS/Linux; Windows: Git Bash.
set -euo pipefail
cd "$(dirname "$0")"

sair() { echo "✖ $*" >&2; exit 1; }
[ $# -eq 2 ] || sair "Uso: ./img.sh <url> <nome>"
URL=$1; NOME=$2
[[ $URL =~ ^https?:// ]] || sair "O URL tem de começar por http:// ou https://."
[[ $NOME =~ ^[a-z0-9-]+$ ]] || sair "Nome só com minúsculas, números e '-' (ex. semente-milho)."
command -v ffmpeg >/dev/null || sair "ffmpeg não encontrado (brew install ffmpeg)."

DEST=AgroGest/src/main/webapp/img/produtos/$NOME.jpg
MAX=40960
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

curl -fsSL -A "AgroGest/1.0 (img.sh)" --max-time 30 --max-filesize 20000000 -o "$TMP/orig" "$URL" || sair "Download falhou: $URL"

# qualidade JPEG 3 (melhor) → 15 até caber em 40 KB; 480px de largura, cor sRGB, sem metadados
for Q in 3 5 7 9 11 13 15; do
    ffmpeg -v error -y -i "$TMP/orig" -frames:v 1 -vf "scale='min(480,iw)':-2:flags=lanczos,format=yuvj420p" \
        -q:v "$Q" -map_metadata -1 "$TMP/out.jpg" || sair "ffmpeg não conseguiu ler a imagem (é mesmo uma imagem?)."
    [ "$(wc -c < "$TMP/out.jpg")" -le $MAX ] && break
done

mkdir -p "$(dirname "$DEST")"
mv "$TMP/out.jpg" "$DEST"
echo "✔ $DEST · $(( $(wc -c < "$DEST") / 1024 )) KB (original $(( $(wc -c < "$TMP/orig") / 1024 )) KB, q=$Q)"
echo "  Foto (URL) :: http://localhost:8081/agrogest/img/produtos/$NOME.jpg"
