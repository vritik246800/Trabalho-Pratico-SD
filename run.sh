#!/usr/bin/env bash
# Compila o AgroGest (Maven), publica o WAR num Tomcat 10.1 na porta 8081 e arranca-o.
# Tomcat :: usa $CATALINA_HOME se existir, senão descarrega um para ~/.agrogest-tomcat (uma vez).
# macOS/Linux: ./run.sh · Windows: Git Bash. Ctrl+C pára o Tomcat (grava o .ser, contextDestroyed).
set -euo pipefail
cd "$(dirname "$0")"

PORTA=8081
URL="http://localhost:$PORTA/agrogest/"
sair() { echo "✖ $*" >&2; exit 1; }

# --- Java 17+ ----------------------------------------------------------------
command -v java >/dev/null || sair "Java não encontrado. Instalar JDK 17 ou superior."
JV=$(java -version 2>&1 | awk -F'"' '/version/ { split($2, v, "."); print (v[1] == 1 ? v[2] : v[1]); exit }')
[ "${JV:-0}" -ge 17 ] || sair "Java $JV encontrado; o AgroGest precisa de Java 17+."

# porta ocupada = outro Tomcat já a correr
if curl -s -o /dev/null "http://localhost:$PORTA/"; then
  sair "Porta $PORTA ocupada. Parar o outro servidor (\$CATALINA_HOME/bin/shutdown.sh) e voltar a correr."
fi

# --- Maven: mvn no PATH, senão o que o wrapper já descarregou ------------------
MVN=$(command -v mvn || true)
[ -n "$MVN" ] || MVN=$(ls -d "$HOME"/.m2/wrapper/dists/apache-maven-3.9*/*/bin/mvn 2>/dev/null | sort -V | tail -1 || true)
[ -n "$MVN" ] || sair "Maven não encontrado. Instalar (brew install maven · https://maven.apache.org)."
[ -f AgroGest/pom.xml ] || sair "AgroGest/pom.xml não existe nesta branch ($(git branch --show-current 2>/dev/null)). A base (T0) ainda não chegou aqui."

echo "▶ mvn package"
(cd AgroGest && "$MVN" -q clean package) || sair "Build falhou."
WAR=AgroGest/target/agrogest.war

# --- Tomcat 10.1 ----------------------------------------------------------------
if [ -z "${CATALINA_HOME:-}" ]; then
  DIR="$HOME/.agrogest-tomcat"
  CATALINA_HOME=$(ls -d "$DIR"/apache-tomcat-10.1.* 2>/dev/null | sort -V | tail -1 || true)
  if [ -z "$CATALINA_HOME" ]; then
    V=$(curl -fsS https://dlcdn.apache.org/tomcat/tomcat-10/ | grep -oE 'v10\.1\.[0-9]+' | sort -V | tail -1) ||
      sair "Sem ligação a dlcdn.apache.org. Instalar Tomcat 10.1 e exportar CATALINA_HOME."
    V=${V#v}
    echo "▶ a descarregar Tomcat $V para $DIR"
    mkdir -p "$DIR"
    BASE="https://dlcdn.apache.org/tomcat/tomcat-10/v$V/bin/apache-tomcat-$V.tar.gz"
    curl -fsSL -o "$DIR/tomcat.tar.gz" "$BASE" && curl -fsSL -o "$DIR/tomcat.sha512" "$BASE.sha512" ||
      sair "Download do Tomcat falhou."
    ESPERADO=$(awk '{ print $1 }' "$DIR/tomcat.sha512")
    REAL=$( (command -v sha512sum >/dev/null && sha512sum "$DIR/tomcat.tar.gz" || shasum -a 512 "$DIR/tomcat.tar.gz") | awk '{ print $1 }')
    [ "$ESPERADO" = "$REAL" ] || { rm -f "$DIR/tomcat.tar.gz"; sair "Checksum SHA-512 do Tomcat não bate. Download apagado."; }
    tar xzf "$DIR/tomcat.tar.gz" -C "$DIR" && rm -f "$DIR/tomcat.tar.gz" "$DIR/tomcat.sha512"
    CATALINA_HOME="$DIR/apache-tomcat-$V"
    rm -rf "$CATALINA_HOME"/webapps/{docs,examples,host-manager,manager}
  fi
fi
[ -d "$CATALINA_HOME/webapps" ] || sair "CATALINA_HOME=$CATALINA_HOME não parece um Tomcat."
export CATALINA_HOME

# porta 8081 (enunciado)
CONF="$CATALINA_HOME/conf/server.xml"
if ! grep -q "port=\"$PORTA\" protocol=\"HTTP/1.1\"" "$CONF"; then
  sed -i.bak -E "s/port=\"[0-9]+\" protocol=\"HTTP\/1.1\"/port=\"$PORTA\" protocol=\"HTTP\/1.1\"/" "$CONF"
fi

# --- publicar e arrancar --------------------------------------------------------
rm -rf "$CATALINA_HOME/webapps/agrogest" "$CATALINA_HOME/webapps/agrogest.war"
cp "$WAR" "$CATALINA_HOME/webapps/agrogest.war"

# abre o browser quando a app responder (em segundo plano)
(
  for _ in $(seq 60); do
    curl -s -o /dev/null "$URL" && break
    sleep 1
  done
  case "$(uname -s)" in
    Darwin) open "$URL" ;;
    Linux) xdg-open "$URL" >/dev/null 2>&1 || true ;;
    *) start "$URL" 2>/dev/null || explorer.exe "$URL" || true ;;
  esac
) &

echo "▶ Tomcat em $CATALINA_HOME"
echo "  $URL · admin@agro.mz / admin234 · Ctrl+C para parar"
case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*) exec cmd.exe //c "$(cygpath -w "$CATALINA_HOME/bin/catalina.bat")" run ;;
  *) exec "$CATALINA_HOME/bin/catalina.sh" run ;;
esac
