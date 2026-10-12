<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Carrinho"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<h1>Carrinho</h1>

<c:choose>
<c:when test="${resumo.vazio}">
    <section class="card vazio">
        <p>O carrinho está vazio.</p>
        <a class="btn" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
</c:when>
<c:otherwise>
    <c:if test="${resumo.comProblemas}">
        <div class="alerta alerta-erro">Há produtos indisponíveis no carrinho (assinalados em baixo).
            Ajuste a quantidade ou remova-os para poder finalizar a compra.</div>
    </c:if>

    <div class="tabela-wrap">
    <table class="tabela tabela-cartoes">
        <thead><tr><th>Produto</th><th class="num">Preço unit.</th><th>Quantidade</th><th class="num">Subtotal</th><th></th></tr></thead>
        <tbody>
        <c:forEach var="l" items="${resumo.linhas}">
            <tr class="${empty l.problema ? '' : 'linha-problema'}">
                <td data-label="Produto">
                    <div>
                        <strong><c:out value="${l.nome}"/></strong>
                        <c:if test="${not empty l.problema}"><div class="texto-erro">⚠ Indisponível: <c:out value="${l.problema}"/>.</div></c:if>
                    </div>
                </td>
                <td data-label="Preço unit." class="num"><fmt:formatNumber value="${l.precoUnit}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td data-label="Quantidade">
                    <c:choose>
                        <c:when test="${l.disponivel > 0}">
                            <form class="qtd" method="post" action="${ctx}/carrinho/update">
                                <input type="hidden" name="produtoId" value="${l.produtoId}">
                                <input type="number" name="qtd" value="${l.quantidade}" min="1" max="${l.disponivel}" step="1" required aria-label="Quantidade">
                                <span class="nota"><c:out value="${l.unidade}"/></span>
                                <button class="btn btn-sec btn-peq" type="submit">Actualizar</button>
                            </form>
                        </c:when>
                        <c:otherwise>${l.quantidade}&nbsp;<c:out value="${l.unidade}"/></c:otherwise>
                    </c:choose>
                </td>
                <td data-label="Subtotal" class="num"><fmt:formatNumber value="${l.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="acoes">
                    <form method="post" action="${ctx}/carrinho/remove">
                        <input type="hidden" name="produtoId" value="${l.produtoId}">
                        <button class="btn btn-danger btn-peq" type="submit">Remover</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
    </div>

    <dl class="totais">
        <dt>Subtotal</dt><dd><fmt:formatNumber value="${resumo.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
        <dt>IVA 16%</dt><dd><fmt:formatNumber value="${resumo.iva}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
        <dt class="total">Total</dt><dd class="total"><fmt:formatNumber value="${resumo.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
    </dl>

    <div class="botoes-fim">
        <a class="btn btn-sec" href="${ctx}/catalogo">Continuar a comprar</a>
        <form method="post" action="${ctx}/carrinho/limpar" onsubmit="return confirm('Esvaziar o carrinho?')">
            <button class="btn btn-danger" type="submit">Esvaziar carrinho</button>
        </form>
        <c:choose>
            <c:when test="${resumo.comProblemas}"><button class="btn" type="button" disabled>Finalizar compra</button></c:when>
            <c:otherwise><a class="btn" href="${ctx}/compra">Finalizar compra</a></c:otherwise>
        </c:choose>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
