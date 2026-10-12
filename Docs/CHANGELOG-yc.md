# CHANGELOG — yc

Entradas desta branch. Mais recente no topo.

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
