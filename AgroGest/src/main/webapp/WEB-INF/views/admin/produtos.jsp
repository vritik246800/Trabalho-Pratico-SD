<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Produtos"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Produtos</h1>
<c:if test="${not empty expirados}">
    <div class="alerta alerta-aviso">
        <strong>⚠ ${fn:length(expirados)} produto(s) fora da validade</strong> (assinalados na tabela). Os clientes já não os podem comprar:
        remova-os ou crie o produto de novo com a validade do lote novo.
    </div>
</c:if>

<c:set var="voltou" value="${param.acao == 'criar'}"/>
<section class="card">
    <h2 class="sem-margem">Novo produto</h2>
    <c:choose>
        <c:when test="${empty fornecedores}">
            <p class="nota">Crie primeiro um <a href="${ctx}/admin/fornecedores">fornecedor</a>.</p>
        </c:when>
        <c:otherwise>
            <form class="form" method="post" action="${ctx}/admin/produtos">
                <input type="hidden" name="acao" value="criar">
                <div class="form-linha">
                    <label>Nome <input name="nome" value="${voltou ? fn:escapeXml(param.nome) : ''}" required maxlength="100"></label>
                    <label>Categoria
                        <select name="categoria" required>
                            <c:forEach var="cat" items="${categorias}">
                                <option value="${cat}" ${voltou && param.categoria == cat ? 'selected' : ''}>${cat}</option>
                            </c:forEach>
                        </select>
                    </label>
                    <label>Fornecedor
                        <select name="fornecedorId" required>
                            <c:forEach var="f" items="${fornecedores}">
                                <option value="${f.id}" ${voltou && param.fornecedorId == f.id ? 'selected' : ''}><c:out value="${f.nome}"/></option>
                            </c:forEach>
                        </select>
                    </label>
                </div>
                <div class="form-linha">
                    <label>Preço (MT) <input type="number" name="preco" min="0.01" step="0.01" value="${voltou ? fn:escapeXml(param.preco) : ''}" required></label>
                    <label>Quantidade <input type="number" name="quantidade" min="0" step="1" value="${voltou ? fn:escapeXml(param.quantidade) : ''}" required></label>
                    <label>Unidade <input name="unidade" list="unidades" value="${voltou ? fn:escapeXml(param.unidade) : ''}" required maxlength="30" placeholder="kg, saco, unidade"></label>
                    <label>Validade <input type="date" name="validade" value="${voltou ? fn:escapeXml(param.validade) : ''}"></label>
                </div>
                <datalist id="unidades"><option>kg</option><option>saco</option><option>litro</option><option>unidade</option></datalist>
                <label>Foto (URL) <input type="url" name="foto" value="${voltou ? fn:escapeXml(param.foto) : ''}" maxlength="500" placeholder="https://..."></label>
                <label>Descrição <textarea name="descricao" rows="2" maxlength="500">${voltou ? fn:escapeXml(param.descricao) : ''}</textarea></label>
                <p class="nota sem-margem">Validade vazia = produto sem validade (ferramentas, maquinaria).</p>
                <div><button class="btn" type="submit">Criar produto</button></div>
            </form>
        </c:otherwise>
    </c:choose>
</section>

<div class="tabela-wrap">
<table class="tabela">
    <thead><tr><th>ID</th><th></th><th>Nome</th><th>Categoria</th><th>Fornecedor</th><th class="num">Preço</th><th class="num">Stock</th><th>Validade</th><th>Repor stock</th><th></th></tr></thead>
    <tbody>
    <c:forEach var="p" items="${produtos}">
        <tr class="${p.expirado ? 'linha-expirado' : p.quantidade == 0 ? 'sem-stock' : ''}">
            <td>${p.id}</td>
            <td><c:if test="${not empty p.foto}"><img class="mini" src="${fn:escapeXml(p.foto)}" alt="" loading="lazy"></c:if></td>
            <td><strong><c:out value="${p.nome}"/></strong><c:if test="${not empty p.descricao}"><br><span class="nota"><c:out value="${p.descricao}"/></span></c:if></td>
            <td><span class="etiqueta">${p.categoria}</span></td>
            <td><c:out value="${fornecedorPorId[p.fornecedorId].nome}" default="—"/></td>
            <td class="num"><fmt:formatNumber value="${p.preco}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
            <td class="num">${p.quantidade} <c:out value="${p.unidade}"/></td>
            <td>${empty p.validade ? '—' : p.validadeFmt}<c:if test="${p.expirado}"> <span class="etiqueta etiqueta-expirado">Expirado</span></c:if></td>
            <td class="acoes">
                <form class="repor" method="post" action="${ctx}/admin/produtos">
                    <input type="hidden" name="acao" value="repor">
                    <input type="hidden" name="id" value="${p.id}">
                    <input type="number" name="qtd" min="1" step="1" required aria-label="Quantidade a repor" placeholder="+qtd">
                    <button class="btn btn-sec btn-peq" type="submit">Repor</button>
                </form>
            </td>
            <td class="acoes">
                <form method="post" action="${ctx}/admin/produtos" onsubmit="return confirm('Remover este produto?')">
                    <input type="hidden" name="acao" value="remover">
                    <input type="hidden" name="id" value="${p.id}">
                    <button class="btn btn-danger btn-peq" type="submit">Remover</button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty produtos}"><tr><td colspan="10" class="nota">Sem produtos.</td></tr></c:if>
    </tbody>
</table>
</div>
<%@ include file="../_footer.jspf" %>
