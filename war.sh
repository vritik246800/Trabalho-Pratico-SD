#!/usr/bin/env bash
# Gera o WAR do AgroGest pronto a publicar :: AgroGest/target/agrogest.war
# Publicar :: cp AgroGest/target/agrogest.war $CATALINA_HOME/webapps/ (Tomcat 10.1, porta 8081)
# macOS/Linux: ./war.sh · Windows: Git Bash.
set -euo pipefail
cd "$(dirname "$0")"

sair() { echo "✖ $*" >&2; exit 1; }

# --- Java 17+ ----------------------------------------------------------------
command -v java >/dev/null || sair "Java não encontrado. Instalar JDK 17 ou superior."
JV=$(java -version 2>&1 | awk -F'"' '/version/ { split($2, v, "."); print (v[1] == 1 ? v[2] : v[1]); exit }')
[ "${JV:-0}" -ge 17 ] || sair "Java $JV encontrado; o AgroGest precisa de Java 17+."

# --- Maven: mvn no PATH, senão o que o wrapper já descarregou ------------------
MVN=$(command -v mvn || true)
[ -n "$MVN" ] || MVN=$(ls -d "$HOME"/.m2/wrapper/dists/apache-maven-3.9*/*/bin/mvn 2>/dev/null | sort -V | tail -1 || true)
[ -n "$MVN" ] || sair "Maven não encontrado. Instalar (brew install maven · https://maven.apache.org)."

echo "▶ mvn clean package"
(cd AgroGest && "$MVN" -q clean package) || sair "Build falhou."
WAR=AgroGest/target/agrogest.war
[ -f "$WAR" ] || sair "$WAR não foi gerado."

# JSTL tem de ir no WAR; servlet-api não (o Tomcat fornece)
LISTA=$(unzip -l "$WAR")
grep -q "WEB-INF/lib/jakarta.servlet.jsp.jstl-" <<<"$LISTA" || sair "JSTL em falta em WEB-INF/lib."
grep -q "WEB-INF/lib/jakarta.servlet-api" <<<"$LISTA" && sair "servlet-api dentro do WAR (devia ser provided)."

SHA=$( (command -v sha256sum >/dev/null && sha256sum "$WAR" || shasum -a 256 "$WAR") | awk '{ print $1 }')
echo "✔ $WAR ($(du -h "$WAR" | cut -f1)) · sha256 $SHA"
echo "  publicar: cp $WAR \$CATALINA_HOME/webapps/ · abrir http://localhost:8081/agrogest/"
