<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Confirmar compra"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<h1>Confirmar compra</h1>

<c:choose>
<c:when test="${resumo.vazio}">
    <section class="card vazio">
        <p>O carrinho está vazio: não há nada para comprar.</p>
        <a class="btn" href="${ctx}/catalogo">Ver catálogo</a>
    </section>
</c:when>
<c:otherwise>
    <div class="compra-grelha">
        <section class="card">
            <h2 class="sem-margem">Itens</h2>
            <div class="tabela-wrap">
            <table class="tabela tabela-cartoes">
                <thead><tr><th>Produto</th><th class="num">Qtd</th><th class="num">Preço unit.</th><th class="num">Subtotal</th></tr></thead>
                <tbody>
                <c:forEach var="l" items="${resumo.linhas}">
                    <tr class="${empty l.problema ? '' : 'linha-problema'}">
                        <td data-label="Produto">
                            <div>
                                <c:out value="${l.nome}"/>
                                <c:if test="${not empty l.problema}"><div class="texto-erro">⚠ Indisponível: <c:out value="${l.problema}"/>.</div></c:if>
                            </div>
                        </td>
                        <td data-label="Qtd" class="num">${l.quantidade}&nbsp;<c:out value="${l.unidade}"/></td>
                        <td data-label="Preço unit." class="num"><fmt:formatNumber value="${l.precoUnit}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                        <td data-label="Subtotal" class="num"><fmt:formatNumber value="${l.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            </div>
            <dl class="totais">
                <dt>Subtotal</dt><dd><fmt:formatNumber value="${resumo.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
                <dt>IVA 16%</dt><dd><fmt:formatNumber value="${resumo.iva}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
                <dt class="total">Total a pagar</dt><dd class="total"><fmt:formatNumber value="${resumo.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
            </dl>
        </section>

        <section class="card">
            <h2 class="sem-margem">Factura em nome de</h2>
            <dl class="dados">
                <dt>Nome</dt><dd><c:out value="${eu.nome}"/></dd>
                <dt>Email</dt><dd><c:out value="${eu.email}"/></dd>
                <dt>Telefone</dt><dd><c:out value="${eu.telefone}"/></dd>
                <dt>Endereço</dt><dd><c:out value="${eu.endereco}"/></dd>
            </dl>
            <p class="nota">Ao confirmar, as quantidades são descontadas do stock e a factura é emitida.</p>
        </section>
    </div>

    <div class="botoes-fim">
        <a class="btn btn-sec" href="${ctx}/carrinho">Voltar ao carrinho</a>
        <c:choose>
            <c:when test="${resumo.comProblemas}">
                <button class="btn" type="button" disabled>Confirmar compra</button>
            </c:when>
            <c:otherwise>
                <%-- desactiva o botão depois do 1.º clique: não envia a compra duas vezes --%>
                <form method="post" action="${ctx}/compra" onsubmit="this.querySelector('button').disabled = true">
                    <button class="btn" type="submit">Confirmar compra</button>
                </form>
            </c:otherwise>
        </c:choose>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
