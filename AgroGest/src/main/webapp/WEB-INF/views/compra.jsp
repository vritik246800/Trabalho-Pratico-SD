<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Confirmar compra"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<c:set var="passoCompra" value="2"/>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-factura"/></svg>Loja</p>
        <h1>Confirmar compra</h1>
        <p>Reveja os itens e os dados da factura. Ao confirmar, o stock é descontado e a factura é emitida.</p>
    </div>
</header>
<%@ include file="_fluxo.jspf" %>

<c:choose>
<c:when test="${resumo.vazio}">
    <section class="card vazio">
        <%@ include file="_broto.jspf" %>
        <p>O carrinho está vazio: não há nada para confirmar.</p>
        <a class="btn btn-acento" href="${ctx}/catalogo"><svg class="ic"><use href="#i-catalogo"/></svg>Ver catálogo</a>
    </section>
</c:when>
<c:otherwise>
    <div class="compra-grelha">
        <section class="card">
            <h2>Itens</h2>
            <div class="tabela-wrap">
            <table class="tabela tabela-cartoes">
                <thead><tr><th>Produto</th><th class="num">Qtd</th><th class="num">Preço unit.</th><th class="num">Subtotal</th></tr></thead>
                <tbody>
                <c:forEach var="l" items="${resumo.linhas}">
                    <tr class="${empty l.problema ? '' : 'linha-problema'}">
                        <td data-label="Produto">
                            <div>
                                <c:out value="${l.nome}"/>
                                <c:if test="${not empty l.problema}"><div class="texto-erro texto-ic"><svg class="ic"><use href="#i-alerta"/></svg>Indisponível: <c:out value="${l.problema}"/>.</div></c:if>
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

        <aside class="card resumo">
            <h2>Factura em nome de</h2>
            <dl class="dados">
                <dt>Nome</dt><dd><c:out value="${eu.nome}"/></dd>
                <dt>Email</dt><dd><c:out value="${eu.email}"/></dd>
                <dt>Telefone</dt><dd><c:out value="${eu.telefone}"/></dd>
                <dt>Endereço</dt><dd><c:out value="${eu.endereco}"/></dd>
            </dl>
            <c:choose>
                <c:when test="${resumo.comProblemas}"><button class="btn btn-largo" type="button" disabled>Confirmar compra</button></c:when>
                <c:otherwise>
                    <%-- app.js desactiva o botão depois do 1.º clique: não envia a compra duas vezes --%>
                    <form method="post" action="${ctx}/compra">
                        <button class="btn btn-acento btn-largo" type="submit"><svg class="ic"><use href="#i-ok"/></svg>Confirmar e emitir factura</button>
                    </form>
                </c:otherwise>
            </c:choose>
            <div class="resumo-mais"><a class="btn btn-sec btn-peq" href="${ctx}/carrinho"><svg class="ic"><use href="#i-seta-esq"/></svg>Voltar ao carrinho</a></div>
        </aside>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
