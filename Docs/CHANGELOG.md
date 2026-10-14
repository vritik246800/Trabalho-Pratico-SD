# CHANGELOG

Consolidado de `CHANGELOG-vd.md`, `CHANGELOG-yc.md`, `CHANGELOG-ym.md`. Mais recente no topo.

## [A6] SECURITY.md na raiz + protecção GitHub — 2026-10-14 · Vritik
- update: Docs/SEGURANCA.md → SECURITY.md (raiz, política GitHub)
- create: .github/dependabot.yml
- update: .github/workflows/main-only-from-dev.yml (`permissions: {}`)
- delete: .metadata/ do índice git (`git rm -r --cached`, já estava no `.gitignore`)
- update: SECURITY.md (secção GitHub só com o que funciona em repo privado + conta grátis)
- update: Docs/TODO.md, Docs/INDEX.md, README.md

## [A6] Documento de segurança — 2026-10-14 · Vritik
- create: Docs/SEGURANCA.md
- update: Docs/TODO.md, Docs/INDEX.md, README.md
- medidas implementadas (hash, sessão, RN03–RN05, XSS, locks, `.ser` atómico) + limitações L1–L11

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

## [B1–B6] Pacote B · cliente: registo, catálogo, carrinho, compra, factura, histórico — 2026-10-12 · Yannis
- create: AgroGest/src/main/java/mz/agrogest/service/{ClienteService, CatalogoService, VendaService}.java
- create: AgroGest/src/main/java/mz/agrogest/servlet/{Registo, Catalogo, Carrinho, Compra, Factura, MinhasCompras}Servlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/{registo, catalogo, carrinho, compra, factura, minhas-compras}.jsp
- create: AgroGest/src/main/webapp/css/cliente-b.css
- update: README.md (secção Cliente · pacote B)
- B1 email único verificado e inserido sob o lock do `DataStore` (sem distinguir maiúsculas) · pass com `PasswordUtil.hash` · entrada automática com sessão nova
- B2 cartões com foto (ícone da categoria se não houver), preço, validade, stock, fornecedor · filtro `?categoria=` com contagens · esgotado sem botão
- B3 `LinkedHashMap` na sessão, escrita sob o lock do próprio carrinho · PRG em add/update/remove/limpar · RN01: quantidade acima do stock recusada com mensagem; linha que ficou sem stock assinalada e "Finalizar" bloqueado
- B4 RN01 + RN02 em `VendaService.finalizar`: `synchronized (DataStore.get())` (o mesmo lock do repor stock), valida todos os itens antes de descontar · IVA 16 % ao cêntimo · duplo clique não compra duas vezes
- B5 dados do cliente, itens com unidade, subtotal, IVA, total · `window.print()` + `@media print` · RN03: factura de outro cliente → 403, inexistente → 404 · `/factura` sem id = lista de todas para o admin
- B6 só as vendas do cliente da sessão, mais recente primeiro, com total gasto · admin vai para `/factura`
- Testado em Tomcat 10.1.61 :8081: 74 verificações HTTP (registo, filtros, carrinho, RN01, RN02, RN03, RN05) · 20 compras simultâneas do mesmo produto (8 aceites, stock final 4, nunca negativo) · telemóvel 390 px · impressão da factura em PDF

## [A1–A5] Pacote A · admin: fornecedores, produtos, listagens, relatórios, dashboard — 2026-10-12 · Vritik
- create: AgroGest/src/main/java/mz/agrogest/service/{FornecedorService, ProdutoService, RelatorioService}.java
- create: AgroGest/src/main/java/mz/agrogest/servlet/admin/{Fornecedor, Produto, Listagem, Relatorio, Dashboard}Servlet.java
- create: AgroGest/src/main/webapp/WEB-INF/views/admin/{fornecedores, produtos, listagens, relatorios, dashboard}.jsp
- create: AgroGest/src/main/webapp/css/admin-a.css
- A1 campos obrigatórios · não remove fornecedor com produtos (mensagem com nº de produtos)
- A2 preço > 0, quantidade ≥ 0, validade válida (vazia = sem validade), fornecedor existe, foto só http(s) · repor stock sob o lock do `DataStore`
- A3 `?tipo=produtos|fornecedores|clientes|armazem|compras&ordem=nome|preco|stock|data|valor&dir=asc|desc` · compras detalhadas com cliente, endereço, telefone, itens, IVA, total, data
- A4 por nome ↑ · por volume ↓ · mais assíduos ↓ · sem compras (extra)
- A5 dashboard: 3 fornecedores · 3 produtos · 5 clientes · 4 vendas · 1 campanha (seed)
- Testado em Tomcat 10.1.61 :8081: CRUD, erros de validação na JSP, escape de HTML (`<script>` no nome)

## [T0] Base comum — 2026-10-12 · Vritik
- create: AgroGest/pom.xml (WAR `agrogest`, Java 17, JSTL 3.0 no WAR, servlet/JSP `provided`)
- create: AgroGest/src/main/java/mz/agrogest/model/* (8 POJOs + 3 enums, `Serializable`)
- create: AgroGest/src/main/java/mz/agrogest/repo/DataStore.java (singleton, `AtomicInteger` por entidade, seed do enunciado)
- create: AgroGest/src/main/java/mz/agrogest/{service/NegocioException, util/PasswordUtil, util/Datas}.java
- create: AgroGest/src/main/java/mz/agrogest/{filter/AuthFilter, listener/AppListener, servlet/LoginServlet}.java
- create: AgroGest/src/main/webapp/{index.jsp, css/style.css, WEB-INF/views/{_header.jspf, _footer.jspf, login.jsp, 403.jsp}}
- update: AgroGest/.classpath, AgroGest/.gitignore · delete: 8 jars sem uso em AgroGest/lib
- RN04 (403), RN05 (redirect /login), RN06 (`AtomicInteger`), passwords SHA-256 + salt
- Testado em Tomcat 10.1.61 :8081: login admin/cliente, 403 em /admin para cliente e anónimo
