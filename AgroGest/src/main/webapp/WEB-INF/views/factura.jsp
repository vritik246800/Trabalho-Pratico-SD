<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="${empty venda ? 'Factura' : venda.numeroFactura}"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%-- antes do cabeçalho apagar o flash: veio agora do POST /compra → mostra os passos da compra --%>
<c:set var="acabouDeComprar" value="${not empty sessionScope.flash}"/>
<%@ include file="_header.jspf" %>
<c:set var="voltar" value="${eu.admin ? '/factura' : '/minhas-compras'}"/>
<c:set var="passoCompra" value="3"/>

<c:choose>
<c:when test="${empty venda}">
    <%-- 403 (RN03: factura de outro cliente) ou 404 --%>
    <section class="card card-estreito negado">
        <svg class="negado-ic" viewBox="0 0 24 24" aria-hidden="true"><use href="#${negado ? 'i-cadeado' : 'i-factura'}"/></svg>
        <c:choose>
            <c:when test="${negado}">
                <p class="olho">Erro 403</p>
                <h1>Acesso negado</h1>
                <p>Esta factura não é sua. Cada cliente só pode ver as suas facturas.</p>
            </c:when>
            <c:otherwise>
                <h1>Factura não encontrada</h1>
                <p>Não existe nenhuma factura com esse número.</p>
            </c:otherwise>
        </c:choose>
        <a class="btn" href="${ctx}${voltar}">${eu.admin ? 'Ver todas as facturas' : 'Ver as minhas compras'}</a>
    </section>
</c:when>
<c:otherwise>
    <c:if test="${not eu.admin and acabouDeComprar}"><%@ include file="_fluxo.jspf" %></c:if>
    <div class="botoes-topo nao-imprimir">
        <a class="btn btn-sec" href="${ctx}${voltar}"><svg class="ic"><use href="#i-seta-esq"/></svg>${eu.admin ? 'Todas as facturas' : 'Minhas compras'}</a>
        <button class="btn btn-acento" type="button" onclick="window.print()"><svg class="ic"><use href="#i-imprimir"/></svg>Imprimir</button>
    </div>

    <article class="card factura">
        <header class="factura-topo">
            <div>
                <div class="factura-marca"><svg class="marca-logo" aria-hidden="true"><use href="#i-logo"/></svg><span>Agro<em>Gest</em></span></div>
                <div class="nota">Sistema de Gestão Agrícola · Nampula, Moçambique</div>
            </div>
            <div class="factura-num">
                <div class="nota">Factura n.º</div>
                <strong>${venda.numeroFactura}</strong>
                <div class="nota">Data: ${venda.dataFmt}</div>
            </div>
        </header>

        <section class="factura-cliente">
            <h2>Cliente</h2>
            <c:choose>
                <c:when test="${empty cliente}"><p class="nota">Cliente n.º ${venda.clienteId} (conta já não existe)</p></c:when>
                <c:otherwise>
                    <p><strong><c:out value="${cliente.nome}"/></strong><br>
                        <c:out value="${cliente.endereco}"/><br>
                        Tel.: <c:out value="${cliente.telefone}"/> · <c:out value="${cliente.email}"/></p>
                </c:otherwise>
            </c:choose>
        </section>

        <div class="tabela-wrap">
        <table class="tabela tabela-cartoes">
            <thead><tr><th>#</th><th>Produto</th><th class="num">Qtd</th><th class="num">Preço unit.</th><th class="num">Subtotal</th></tr></thead>
            <tbody>
            <c:forEach var="i" items="${venda.itens}" varStatus="st">
                <tr>
                    <td data-label="#">${st.count}</td>
                    <td data-label="Produto"><c:out value="${i.nomeProduto}"/></td>
                    <td data-label="Qtd" class="num">${i.quantidade}&nbsp;<c:out value="${unidades[i.produtoId]}"/></td>
                    <td data-label="Preço unit." class="num"><fmt:formatNumber value="${i.precoUnit}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                    <td data-label="Subtotal" class="num"><fmt:formatNumber value="${i.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>

        <dl class="totais">
            <dt>Subtotal</dt><dd><fmt:formatNumber value="${venda.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
            <dt>IVA 16%</dt><dd><fmt:formatNumber value="${venda.iva}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
            <dt class="total">Total</dt><dd class="total"><fmt:formatNumber value="${venda.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
        </dl>

        <p class="nota factura-rodape">Documento processado por computador · AgroGest. Obrigado pela preferência.</p>
    </article>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
