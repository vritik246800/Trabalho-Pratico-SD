<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Catálogo"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<c:set var="rotCat" value="${{'SEMENTE':'Sementes', 'FERTILIZANTE':'Fertilizantes', 'MAQUINARIA':'Maquinaria', 'FERRAMENTA':'Ferramentas'}}"/>
<c:set var="icCat" value="${{'SEMENTE':'i-semente', 'FERTILIZANTE':'i-fertilizante', 'MAQUINARIA':'i-maquinaria', 'FERRAMENTA':'i-ferramenta'}}"/>
<c:set var="carrinho" value="${sessionScope.carrinho}"/>

<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-catalogo"/></svg>Loja</p>
        <h1>Catálogo</h1>
        <p>Preços em meticais, sem IVA. O IVA de 16% entra no carrinho.</p>
    </div>
</header>

<nav class="filtros" aria-label="Filtrar por categoria">
    <a class="${empty categoria ? 'activo' : ''}" href="${ctx}/catalogo">Todas <span>${totalProdutos}</span></a>
    <c:forEach var="cat" items="${categorias}">
        <a class="${cat == categoria ? 'activo' : ''}" href="${ctx}/catalogo?categoria=${cat}"><svg class="ic"><use href="#${icCat[cat.name()]}"/></svg>${rotCat[cat.name()]} <span>${contagem[cat]}</span></a>
    </c:forEach>
</nav>

<c:if test="${eu.admin}">
    <div class="alerta alerta-info"><svg class="ic"><use href="#i-info"/></svg><div>Vista de administrador: as compras só se fazem com uma conta de cliente.</div></div>
</c:if>

<div class="catalogo">
<c:forEach var="p" items="${produtos}">
    <c:set var="noCarrinho" value="${empty carrinho[p.id] ? 0 : carrinho[p.id]}"/>
    <c:set var="podeJuntar" value="${p.quantidade - noCarrinho}"/>
    <article class="produto ${p.quantidade == 0 || p.expirado ? 'indisponivel' : ''}" id="p${p.id}">
        <div class="produto-foto">
            <svg class="produto-ic" viewBox="0 0 24 24" aria-hidden="true"><use href="#${icCat[p.categoria.name()]}"/></svg>
            <c:if test="${not empty p.foto}">
                <img src="${fn:escapeXml(p.foto)}" alt="${fn:escapeXml(p.nome)}" loading="lazy" onerror="this.remove()">
            </c:if>
            <c:choose>
                <c:when test="${p.expirado}"><span class="selo-foto selo-erro"><svg class="ic"><use href="#i-alerta"/></svg>Fora da validade</span></c:when>
                <c:when test="${p.quantidade == 0}"><span class="selo-foto selo-neutro">Esgotado</span></c:when>
                <c:when test="${noCarrinho > 0}"><span class="selo-foto selo-ok"><svg class="ic"><use href="#i-carrinho"/></svg>${noCarrinho}&nbsp;<c:out value="${p.unidade}"/> no carrinho</span></c:when>
            </c:choose>
        </div>
        <div class="produto-corpo">
            <p class="produto-meta"><svg class="ic"><use href="#${icCat[p.categoria.name()]}"/></svg>${rotCat[p.categoria.name()]} · <c:out value="${fornecedorPorId[p.fornecedorId].nome}" default="Fornecedor desconhecido"/></p>
            <h2 class="produto-nome"><c:out value="${p.nome}"/></h2>
            <c:if test="${not empty p.descricao}"><p class="produto-desc"><c:out value="${p.descricao}"/></p></c:if>
            <p class="preco"><fmt:formatNumber value="${p.preco}" minFractionDigits="2" maxFractionDigits="2"/><small> MT / <c:out value="${p.unidade}"/></small></p>
            <dl class="produto-dados">
                <div><dt>Em stock</dt><dd>${p.quantidade == 0 ? '0' : p.quantidade}&nbsp;<c:out value="${p.unidade}"/></dd></div>
                <div><dt>Validade</dt><dd class="${p.expirado ? 'texto-erro' : ''}">${empty p.validade ? 'sem validade' : p.validadeFmt}</dd></div>
            </dl>

            <c:choose>
                <c:when test="${eu.admin}"></c:when>
                <c:when test="${p.expirado}"><button class="btn" type="button" disabled>Fora da validade</button></c:when>
                <c:when test="${p.quantidade == 0}"><button class="btn" type="button" disabled>Esgotado</button></c:when>
                <c:when test="${podeJuntar <= 0}"><p class="nota produto-aviso">Já tem todo o stock disponível no carrinho.</p></c:when>
                <c:otherwise>
                    <form class="adicionar" method="post" action="${ctx}/carrinho/add">
                        <input type="hidden" name="produtoId" value="${p.id}">
                        <input type="hidden" name="categoria" value="${categoria}">
                        <label class="qtd-caixa"><span class="visualmente-oculto">Quantidade</span>
                            <input type="number" name="qtd" value="1" min="1" max="${podeJuntar}" step="1" required>
                        </label>
                        <button class="btn btn-acento" type="submit"><svg class="ic"><use href="#i-carrinho"/></svg>Adicionar</button>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>
    </article>
</c:forEach>
</div>
<c:if test="${empty produtos}">
    <section class="card vazio"><%@ include file="_broto.jspf" %><p>Sem produtos<c:if test="${not empty categoria}"> nesta categoria</c:if> de momento.</p>
        <c:if test="${not empty categoria}"><a class="btn btn-sec" href="${ctx}/catalogo">Ver todas as categorias</a></c:if></section>
</c:if>
<%@ include file="_footer.jspf" %>
