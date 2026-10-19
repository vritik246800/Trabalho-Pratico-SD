<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- B6 histórico do cliente · também a lista de todas as facturas do admin (FacturaServlet, todas=true) --%>
<c:set var="titulo" value="${todas ? 'Facturas' : 'Minhas compras'}"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#${todas ? 'i-factura' : 'i-compras'}"/></svg>${todas ? 'Vendas' : 'Loja'}</p>
        <h1>${titulo}</h1>
        <p>
            <c:choose>
                <c:when test="${empty vendas}">${todas ? 'Nenhuma factura emitida.' : 'Nenhuma compra feita.'}</c:when>
                <c:when test="${todas}">${fn:length(vendas)} factura(s) emitida(s), mais recente primeiro.</c:when>
                <c:otherwise>${fn:length(vendas)} compra(s) · total gasto <strong><fmt:formatNumber value="${totalGasto}" minFractionDigits="2" maxFractionDigits="2"/> MT</strong></c:otherwise>
            </c:choose>
        </p>
    </div>
</header>

<c:choose>
<c:when test="${empty vendas}">
    <section class="card vazio">
        <%@ include file="_broto.jspf" %>
        <c:choose>
            <c:when test="${todas}"><p>Ainda não há facturas emitidas.</p></c:when>
            <c:otherwise>
                <p>Ainda não fez nenhuma compra.</p>
                <a class="btn btn-acento" href="${ctx}/catalogo"><svg class="ic"><use href="#i-catalogo"/></svg>Ver catálogo</a>
            </c:otherwise>
        </c:choose>
    </section>
</c:when>
<c:otherwise>
    <div class="tabela-wrap">
    <table class="tabela tabela-cartoes">
        <thead><tr>
            <th>Factura</th><th>Data</th><c:if test="${todas}"><th>Cliente</th></c:if><th>Produtos</th><th class="num">Total</th><th></th>
        </tr></thead>
        <tbody>
        <c:forEach var="v" items="${vendas}">
            <tr>
                <td data-label="Factura"><strong class="num-factura">${v.numeroFactura}</strong></td>
                <td data-label="Data">${v.dataFmt}</td>
                <c:if test="${todas}">
                    <td data-label="Cliente"><c:out value="${clientePorId[v.clienteId].nome}" default="Cliente n.º ${v.clienteId}"/></td>
                </c:if>
                <td data-label="Produtos">
                    <c:forEach var="i" items="${v.itens}" varStatus="st"><c:out value="${i.nomeProduto}"/> × ${i.quantidade}<c:if test="${not st.last}">, </c:if></c:forEach>
                </td>
                <td data-label="Total" class="num total-linha"><fmt:formatNumber value="${v.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="acoes"><a class="btn btn-sec btn-peq" href="${ctx}/factura?id=${v.id}"><svg class="ic"><use href="#i-factura"/></svg>Ver factura</a></td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
