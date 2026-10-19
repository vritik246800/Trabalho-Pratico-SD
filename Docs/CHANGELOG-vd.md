# CHANGELOG — vd

Entradas desta branch. Mais recente no topo.

## [A9] Polimento UI/UX admin e cliente — 2026-10-19 · Vritik
- update: AgroGest/src/main/webapp/WEB-INF/views/_header.jspf
- update: AgroGest/src/main/webapp/css/style.css
- update: AgroGest/src/main/webapp/css/cliente-b.css
- menu :: página activa em destaque (`aria-current`), contador do carrinho em badge, nome do utilizador
- topo sticky com sombra · cartões com sombra e hover · tabelas com moldura, cabeçalho compacto, zebra
- forms com anel de foco · `:focus-visible` · `.alerta-aviso` novo · mobile: tabela-cartões sem moldura dupla

## [A8] Produto expirado: sem venda + alerta no admin — 2026-10-19 · Vritik
- update: AgroGest/src/main/java/mz/agrogest/model/Produto.java
- update: AgroGest/src/main/java/mz/agrogest/service/VendaService.java
- update: AgroGest/src/main/java/mz/agrogest/service/ProdutoService.java
- update: AgroGest/src/main/java/mz/agrogest/servlet/admin/DashboardServlet.java
- update: AgroGest/src/main/java/mz/agrogest/servlet/admin/ProdutoServlet.java
- update: AgroGest/src/main/webapp/WEB-INF/views/catalogo.jsp
- update: AgroGest/src/main/webapp/WEB-INF/views/admin/dashboard.jsp
- update: AgroGest/src/main/webapp/WEB-INF/views/admin/produtos.jsp
- `Produto.isExpirado()` :: `validade < hoje` (getter calculado, sem campo novo → `.ser` compatível)
- RN01 :: `VendaService` recusa adicionar/actualizar/finalizar produto expirado (mensagem na JSP, stock intacto)
- catálogo :: selo "Expirado" na foto, botão "Fora da validade" desactivado
- admin :: alerta com lista de expirados no dashboard · alerta + linha/etiqueta vermelha em Produtos

## [A7] Abrir pasta do .ser no Finder / Explorador — 2026-10-15 · Vritik
- update: AgroGest/src/main/java/mz/agrogest/repo/Persistencia.java
- update: AgroGest/src/main/java/mz/agrogest/servlet/admin/PersistenciaServlet.java
- update: AgroGest/src/main/webapp/WEB-INF/views/admin/persistencia.jsp
- caminho do .ser visível · botão abre `open -R` (macOS) / `explorer /select,` (Windows)

## [Docs] Instruções para Yannis e Yasin — 2026-10-14 · Vritik
- create: Docs/INSTRUCOES.md
- update: CLAUDE.md (sincronizar com `dev` no início da sessão), Docs/INDEX.md, README.md

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
