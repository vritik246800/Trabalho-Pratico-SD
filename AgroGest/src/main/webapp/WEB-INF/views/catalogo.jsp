<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Catálogo"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<c:set var="rotCat" value="${{'SEMENTE':'Sementes', 'FERTILIZANTE':'Fertilizantes', 'MAQUINARIA':'Maquinaria', 'FERRAMENTA':'Ferramentas'}}"/>
<c:set var="icone" value="${{'SEMENTE':'🌱', 'FERTILIZANTE':'🧪', 'MAQUINARIA':'🚜', 'FERRAMENTA':'🔧'}}"/>
<c:set var="carrinho" value="${sessionScope.carrinho}"/>

<div class="titulo-linha">
    <h1>Catálogo</h1>
    <c:if test="${not eu.admin}">
        <a class="btn btn-sec" href="${ctx}/carrinho">Ver carrinho<c:if test="${not empty carrinho}"> (${fn:length(carrinho)})</c:if></a>
    </c:if>
</div>

<nav class="filtros" aria-label="Filtrar por categoria">
    <a class="${empty categoria ? 'activo' : ''}" href="${ctx}/catalogo">Todas <span>${totalProdutos}</span></a>
    <c:forEach var="cat" items="${categorias}">
        <a class="${cat == categoria ? 'activo' : ''}" href="${ctx}/catalogo?categoria=${cat}">${icone[cat.name()]}&nbsp;${rotCat[cat.name()]} <span>${contagem[cat]}</span></a>
    </c:forEach>
</nav>

<c:if test="${eu.admin}">
    <p class="alerta alerta-info">Vista de administrador: as compras só se fazem com uma conta de cliente.</p>
</c:if>

<div class="grid catalogo">
<c:forEach var="p" items="${produtos}">
    <c:set var="noCarrinho" value="${empty carrinho[p.id] ? 0 : carrinho[p.id]}"/>
    <c:set var="podeJuntar" value="${p.quantidade - noCarrinho}"/>
    <article class="card produto ${p.quantidade == 0 ? 'esgotado' : ''}" id="p${p.id}">
        <%-- sem foto (ou foto que não carrega) mostra o ícone da categoria --%>
        <div class="produto-foto" data-icone="${icone[p.categoria.name()]}">
            <c:if test="${not empty p.foto}">
                <img src="${fn:escapeXml(p.foto)}" alt="${fn:escapeXml(p.nome)}" loading="lazy" onerror="this.remove()">
            </c:if>
        </div>
        <div class="produto-corpo">
            <div class="produto-meta">
                <span class="selo">${rotCat[p.categoria.name()]}</span>
                <span class="nota"><c:out value="${fornecedorPorId[p.fornecedorId].nome}" default="Fornecedor desconhecido"/></span>
            </div>
            <h2 class="produto-nome"><c:out value="${p.nome}"/></h2>
            <c:if test="${not empty p.descricao}"><p class="produto-desc"><c:out value="${p.descricao}"/></p></c:if>
            <dl class="produto-dados">
                <dt>Preço</dt>
                <dd class="preco"><fmt:formatNumber value="${p.preco}" minFractionDigits="2" maxFractionDigits="2"/> MT <small>/ <c:out value="${p.unidade}"/></small></dd>
                <dt>Disponível</dt>
                <dd>
                    <c:choose>
                        <c:when test="${p.quantidade == 0}"><span class="texto-erro">Esgotado</span></c:when>
                        <c:otherwise>${p.quantidade}&nbsp;<c:out value="${p.unidade}"/></c:otherwise>
                    </c:choose>
                </dd>
                <dt>Validade</dt>
                <dd>${empty p.validade ? '—' : p.validadeFmt}</dd>
            </dl>
            <c:if test="${noCarrinho > 0}">
                <p class="no-carrinho">No carrinho: ${noCarrinho}&nbsp;<c:out value="${p.unidade}"/></p>
            </c:if>

            <c:choose>
                <c:when test="${eu.admin}"></c:when>
                <c:when test="${p.quantidade == 0}">
                    <button class="btn" type="button" disabled>Esgotado</button>
                </c:when>
                <c:when test="${podeJuntar <= 0}">
                    <p class="nota">Já tem todo o stock disponível no carrinho.</p>
                </c:when>
                <c:otherwise>
                    <form class="adicionar" method="post" action="${ctx}/carrinho/add">
                        <input type="hidden" name="produtoId" value="${p.id}">
                        <input type="hidden" name="categoria" value="${categoria}">
                        <label>Qtd
                            <input type="number" name="qtd" value="1" min="1" max="${podeJuntar}" step="1" required>
                        </label>
                        <button class="btn" type="submit">Adicionar</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </article>
</c:forEach>
</div>
<c:if test="${empty produtos}">
    <p class="nota">Sem produtos<c:if test="${not empty categoria}"> nesta categoria</c:if>.</p>
</c:if>
<%@ include file="_footer.jspf" %>
