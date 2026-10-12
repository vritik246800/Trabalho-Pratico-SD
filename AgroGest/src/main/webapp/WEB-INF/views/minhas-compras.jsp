<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- B6 histórico do cliente · também a lista de todas as facturas do admin (FacturaServlet, todas=true) --%>
<c:set var="titulo" value="${todas ? 'Facturas' : 'Minhas compras'}"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<h1>${titulo}</h1>

<c:choose>
<c:when test="${empty vendas}">
    <section class="card vazio">
        <c:choose>
            <c:when test="${todas}"><p>Ainda não há facturas emitidas.</p></c:when>
            <c:otherwise>
                <p>Ainda não fez nenhuma compra.</p>
                <a class="btn" href="${ctx}/catalogo">Ver catálogo</a>
            </c:otherwise>
        </c:choose>
    </section>
</c:when>
<c:otherwise>
    <p class="nota">
        <c:choose>
            <c:when test="${todas}">${fn:length(vendas)} factura(s) emitida(s), mais recente primeiro.</c:when>
            <c:otherwise>${fn:length(vendas)} compra(s) · total gasto
                <fmt:formatNumber value="${totalGasto}" minFractionDigits="2" maxFractionDigits="2"/> MT</c:otherwise>
        </c:choose>
    </p>
    <div class="tabela-wrap">
    <table class="tabela tabela-cartoes">
        <thead><tr>
            <th>Factura</th><th>Data</th><c:if test="${todas}"><th>Cliente</th></c:if><th>Produtos</th><th class="num">Total</th><th></th>
        </tr></thead>
        <tbody>
        <c:forEach var="v" items="${vendas}">
            <tr>
                <td data-label="Factura"><strong>${v.numeroFactura}</strong></td>
                <td data-label="Data">${v.dataFmt}</td>
                <c:if test="${todas}">
                    <td data-label="Cliente"><c:out value="${clientePorId[v.clienteId].nome}" default="Cliente n.º ${v.clienteId}"/></td>
                </c:if>
                <td data-label="Produtos">
                    <c:forEach var="i" items="${v.itens}" varStatus="st"><c:out value="${i.nomeProduto}"/> × ${i.quantidade}<c:if test="${not st.last}">, </c:if></c:forEach>
                </td>
                <td data-label="Total" class="num"><fmt:formatNumber value="${v.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="acoes"><a class="btn btn-sec btn-peq" href="${ctx}/factura?id=${v.id}">Ver factura</a></td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
