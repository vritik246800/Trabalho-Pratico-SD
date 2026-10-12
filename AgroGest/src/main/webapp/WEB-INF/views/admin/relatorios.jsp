<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Relatórios"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Relatórios de clientes</h1>
<nav class="separadores">
    <a href="#nome">Por nome</a><a href="#volume">Por volume</a><a href="#assiduos">Mais assíduos</a><a href="#sem">Sem compras</a>
</nav>

<section class="card" id="nome">
    <h2 class="sem-margem">Clientes por nome (A→Z)</h2>
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

<section class="card" id="volume">
    <h2 class="sem-margem">Clientes que compraram · por volume</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>#</th><th>Nome</th><th class="num">Total comprado</th><th class="num">Compras</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${porVolume}" varStatus="st">
            <tr><td>${st.count}</td><td><c:out value="${s.cliente.nome}"/></td>
                <td class="num"><fmt:formatNumber value="${s.volume}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="num">${s.compras}</td></tr>
        </c:forEach>
        <c:if test="${empty porVolume}"><tr><td colspan="4" class="nota">Ainda não há compras.</td></tr></c:if>
        </tbody>
    </table></div>
</section>

<section class="card" id="assiduos">
    <h2 class="sem-margem">Clientes mais assíduos · nº de compras</h2>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>#</th><th>Nome</th><th class="num">Compras</th><th>Última compra</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${assiduos}" varStatus="st">
            <tr><td>${st.count}</td><td><c:out value="${s.cliente.nome}"/></td>
                <td class="num">${s.compras}</td><td>${s.ultimaCompraFmt}</td></tr>
        </c:forEach>
        <c:if test="${empty assiduos}"><tr><td colspan="4" class="nota">Ainda não há compras.</td></tr></c:if>
        </tbody>
    </table></div>
</section>

<section class="card" id="sem">
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
<%@ include file="../_footer.jspf" %>
