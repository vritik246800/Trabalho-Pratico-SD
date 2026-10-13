# CHANGELOG — ym

Entradas desta branch. Mais recente no topo.

## [C5] Deploy Tomcat :8081 + systemd — 2026-10-13 · Yasin
- create: Docs/deploy/agrogest.service
- create: Docs/deploy/DEPLOY.md
- update: README.md (secção Instalação e deploy)

## [C4] Persistência `.ser` — 2026-10-13 · Yasin
- create: AgroGest/src/main/java/mz/agrogest/repo/Persistencia.java
- update: AgroGest/src/main/java/mz/agrogest/listener/AppListener.java
- create: AgroGest/src/main/java/mz/agrogest/servlet/admin/PersistenciaServlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/admin/persistencia.jsp
- Escrita atómica (.tmp → ATOMIC_MOVE), fallback a seed() se ficheiro corrompido

## [C3] Colheitas — 2026-10-13 · Yasin
- create: AgroGest/src/main/java/mz/agrogest/servlet/admin/ColheitaServlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/admin/colheitas.jsp
- valorTotal = kg × precoKg calculado no service, totais na tabela

## [C2] Cultivos — 2026-10-13 · Yasin
- create: AgroGest/src/main/java/mz/agrogest/servlet/admin/CultivoServlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/admin/cultivos.jsp
- Campanha fechada bloqueia formulário, não remove cultivo com colheitas

## [C1] Campanhas — 2026-10-13 · Yasin
- create: AgroGest/src/main/java/mz/agrogest/service/CampanhaService.java
- create: AgroGest/src/main/java/mz/agrogest/servlet/admin/CampanhaServlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/admin/campanhas.jsp
- create: AgroGest/src/main/webapp/css/admin-c.css
- criar, fechar, reabrir, remover; não remove campanha com cultivos
