# CHANGELOG — vd

Entradas desta branch. Mais recente no topo.

## [A14] UI animada: GSAP, modelos 3D, imagens, transições — 2026-10-29 · Vritik
- create: AgroGest/src/main/webapp/js/{motion.js, cena3d.js}, js/vendor/{gsap.min.js, three-agro.min.js}, css/motion.css
- create: AgroGest/src/main/webapp/modelos/*.glb (12), img/produtos/{semente-milho, enxada}.jpg, blender/modelos.py, img.sh
- update: AgroGest/src/main/webapp/WEB-INF/views/_header.jspf (scripts, cortina, `data-pagina`, `?v=12`), js/app.js, css/admin-a.css, README.md
- só UI: nenhum servlet, service, model ou JSP de página alterado · tudo é melhoria progressiva (sem JS, sem WebGL ou com "reduzir movimento" a app fica como em A11)
- login/registo → caixa sai, cortina com logo, "Olá, Nome", menu e conteúdo entram · logout e troca de painel → cortina só sobre a área do conteúdo
- entrada de cada página com stagger · painel: contagens sobem · relatórios: barra do volume · produtos expirados piscam · cartões inclinam-se para o rato · catálogo: foto voa para o carrinho
- 3D: um modelo por painel no cabeçalho (arrastar roda, clique dá uma volta) · produto sem foto ou com URL partido → modelo da categoria · um só `WebGLRenderer` partilhado (limite de ~16 contextos WebGL)
- `three-agro.min.js` = bundle esbuild só com o que se usa (600 KB, 155 KB gzip) · modelos 12 × 10–85 KB, carregados só na página que os usa
- formulário de produto: pré-visualização do URL da foto · `img.sh`: curl + ffmpeg → `.jpg` 480px < 40 KB (o ffmpeg do brew não tem libwebp)
- fotos Wikimedia Commons :: `semente-milho.jpg` = `Corn_kernels.jpg`, Danielgrad, CC BY-SA 3.0 · `enxada.jpg` = `Hoe.jpg`, S.Jasmine jeno, CC0

## [A13] Release no GitHub — 2026-10-21 · Vritik
- create: .github/workflows/release.yml
- update: README.md (Instalação e deploy → como publicar release)
- tag `v*` → Java 17 Temurin + cache Maven → `mvn package` → `gh release create` com `agrogest.war`, `agrogest.war.sha256` e notas geradas
- `permissions: {}` no topo, `contents: write` só no job

## [C6] Manual de utilização — 2026-10-21 · Vritik
- create: Docs/MANUAL.md, Docs/img/manual/*.png (20 screenshots)
- update: Docs/INDEX.md, README.md (Documentação → MANUAL.md)
- C6 reatribuída de Yasin para Vritik · manual em Markdown em vez de PDF
- sistema (rotas, RN01–RN06, credenciais) · passo a passo admin (painel → persistência) e cliente (registo → factura → histórico) · 403 e vista telemóvel

## [A12] Script war.sh — 2026-10-21 · Vritik
- create: war.sh
- update: README.md (Instalação e deploy usa `./war.sh`, menciona `run.sh`)
- verifica Java 17+ e Maven · `mvn clean package` · confirma JSTL em `WEB-INF/lib` e servlet-api fora do WAR · imprime tamanho e sha256

## [A11] Redesign completo da UI (sidebar, wizard, login, SVG) — 2026-10-19 · Vritik
- create: AgroGest/src/main/webapp/WEB-INF/views/_icones.jspf, _alertas.jspf, _broto.jspf, _campo.jspf, _fluxo.jspf
- create: AgroGest/src/main/webapp/js/app.js, AgroGest/src/main/webapp/img/logo.svg
- update: AgroGest/src/main/webapp/WEB-INF/views/_header.jspf, _footer.jspf, login.jsp, registo.jsp, 403.jsp, catalogo.jsp, carrinho.jsp, compra.jsp, factura.jsp, minhas-compras.jsp
- update: AgroGest/src/main/webapp/WEB-INF/views/admin/dashboard.jsp, fornecedores.jsp, produtos.jsp, listagens.jsp, relatorios.jsp, campanhas.jsp, cultivos.jsp, colheitas.jsp, persistencia.jsp
- update: AgroGest/src/main/webapp/css/style.css, admin-a.css, admin-c.css, cliente-b.css
- paleta terra/savana :: creme `#F4EFE6`, oliva `#3C4A2A`, terracota `#C8692C`, milho `#D9A441` · Fraunces (títulos) + Inter (texto), fallback Georgia/system-ui sem internet
- sidebar escura com grupos (Catálogo, Produção, Vendas, Sistema) · botão de menu recolhe para ícones (desktop, lembrado em `localStorage`) ou abre gaveta (≤1000 px)
- login e registo :: ecrã dividido com paisagem SVG animada (sol a nascer, sulcos a desenhar, brotos a crescer)
- wizard :: produto (criar/editar, painel lateral) e registo, com passo "Rever" · sem JS os passos ficam todos visíveis
- passos da compra (Carrinho → Confirmar → Factura) · flash de sucesso como toast · botões de envio com spinner e sem duplo envio
- ícones SVG próprios em sprite · zero emoji · `prefers-reduced-motion` respeitado · CSS/JS com `?v=11` contra cache antigo

## [A10] Editar produto — 2026-10-19 · Vritik
- update: AgroGest/src/main/java/mz/agrogest/service/ProdutoService.java
- update: AgroGest/src/main/java/mz/agrogest/servlet/admin/ProdutoServlet.java
- update: AgroGest/src/main/webapp/WEB-INF/views/admin/produtos.jsp
- `ProdutoService.editar(id, dados)` :: todos os campos, mesmas validações do `criar` (`validar` partilhado), lock do `DataStore`
- `POST /admin/produtos acao=editar` · `GET ?editar=id` abre o painel com os valores · erro volta ao painel com o que foi escrito

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
