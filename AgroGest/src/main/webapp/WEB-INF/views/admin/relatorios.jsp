<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Relatórios"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-relatorio"/></svg>Vendas</p>
        <h1>Relatórios de clientes</h1>
        <p>Quem compra mais, quem compra mais vezes e quem ainda não comprou.</p>
    </div>
</header>
<nav class="separadores" aria-label="Ir para o relatório">
    <a href="#volume">Por volume</a><a href="#assiduos">Mais assíduos</a><a href="#sem">Sem compras</a><a href="#nome">Por nome</a>
</nav>
<div class="relatorios">



<section class="card" id="volume">
    <h2 class="sem-margem">Por volume comprado</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>#</th><th>Nome</th><th class="num">Total comprado</th><th class="num">Compras</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${porVolume}" varStatus="st">
            <tr><td><span class="posicao">${st.count}</span></td><td><c:out value="${s.cliente.nome}"/></td>
                <td class="num"><fmt:formatNumber value="${s.volume}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="num">${s.compras}</td></tr>
        </c:forEach>
        <c:if test="${empty porVolume}"><tr><td colspan="4" class="nota">Ainda não há compras.</td></tr></c:if>
        </tbody>
    </table></div>
</section>

<section class="card" id="assiduos">
    <h2 class="sem-margem">Mais assíduos</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>#</th><th>Nome</th><th class="num">Compras</th><th>Última compra</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${assiduos}" varStatus="st">
            <tr><td><span class="posicao">${st.count}</span></td><td><c:out value="${s.cliente.nome}"/></td>
                <td class="num">${s.compras}</td><td>${s.ultimaCompraFmt}</td></tr>
        </c:forEach>
        <c:if test="${empty assiduos}"><tr><td colspan="4" class="nota">Ainda não há compras.</td></tr></c:if>
        </tbody>
    </table></div>
</section>

<section class="card largo" id="sem">
    <h2 class="sem-margem">Clientes sem compras</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>Nome</th><th>Email</th><th>Telefone</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${semCompras}">
            <tr><td><c:out value="${s.cliente.nome}"/></td><td><c:out value="${s.cliente.email}"/></td><td><c:out value="${s.cliente.telefone}"/></td></tr>
        </c:forEach>
        <c:if test="${empty semCompras}"><tr><td colspan="3" class="nota">Todos os clientes já compraram.</td></tr></c:if>
        </tbody>
    </table></div>
</section>
<section class="card largo" id="nome">
    <h2 class="sem-margem">Todos os clientes, por nome</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>Nome</th><th>Email</th><th>Telefone</th><th>Endereço</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${porNome}">
            <tr><td><c:out value="${s.cliente.nome}"/></td><td><c:out value="${s.cliente.email}"/></td>
                <td><c:out value="${s.cliente.telefone}"/></td><td><c:out value="${s.cliente.endereco}"/></td></tr>
        </c:forEach>
        <c:if test="${empty porNome}"><tr><td colspan="4" class="nota">Sem clientes.</td></tr></c:if>
        </tbody>
    </table></div>
</section>
</div>
<%@ include file="../_footer.jspf" %>
