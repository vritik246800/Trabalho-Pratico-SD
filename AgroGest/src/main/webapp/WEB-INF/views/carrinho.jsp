<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Carrinho"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<c:set var="passoCompra" value="1"/>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-carrinho"/></svg>Loja</p>
        <h1>Carrinho</h1>
        <p>Ajuste as quantidades antes de confirmar. O stock só é descontado na confirmação.</p>
    </div>
</header>
<%@ include file="_fluxo.jspf" %>

<c:choose>
<c:when test="${resumo.vazio}">
    <section class="card vazio">
        <%@ include file="_broto.jspf" %>
        <p>O carrinho está vazio. Escolha produtos no catálogo.</p>
        <a class="btn btn-acento" href="${ctx}/catalogo"><svg class="ic"><use href="#i-catalogo"/></svg>Ver catálogo</a>
    </section>
</c:when>
<c:otherwise>
    <c:if test="${resumo.comProblemas}">
        <div class="alerta alerta-erro"><svg class="ic"><use href="#i-alerta"/></svg>
            <div>Há produtos indisponíveis no carrinho (assinalados em baixo). Ajuste a quantidade ou remova-os para poder finalizar a compra.</div></div>
    </c:if>

    <div class="compra-grelha">
        <div class="tabela-wrap">
        <table class="tabela tabela-cartoes">
            <thead><tr><th>Produto</th><th class="num">Preço unit.</th><th>Quantidade</th><th class="num">Subtotal</th><th class="acoes"><span class="visualmente-oculto">Remover</span></th></tr></thead>
            <tbody>
            <c:forEach var="l" items="${resumo.linhas}">
                <tr class="${empty l.problema ? '' : 'linha-problema'}">
                    <td data-label="Produto">
                        <div>
                            <strong><c:out value="${l.nome}"/></strong>
                            <c:if test="${not empty l.problema}"><div class="texto-erro texto-ic"><svg class="ic"><use href="#i-alerta"/></svg>Indisponível: <c:out value="${l.problema}"/>.</div></c:if>
                        </div>
                    </td>
                    <td data-label="Preço unit." class="num"><fmt:formatNumber value="${l.precoUnit}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                    <td data-label="Quantidade">
                        <c:choose>
                            <c:when test="${l.disponivel > 0}">
                                <form class="qtd" method="post" action="${ctx}/carrinho/update">
                                    <input type="hidden" name="produtoId" value="${l.produtoId}">
                                    <input type="number" name="qtd" value="${l.quantidade}" min="1" max="${l.disponivel}" step="1" required aria-label="Quantidade de ${fn:escapeXml(l.nome)}">
                                    <span class="nota"><c:out value="${l.unidade}"/></span>
                                    <button class="btn-icone btn-peq" type="submit" title="Actualizar quantidade" aria-label="Actualizar quantidade"><svg class="ic"><use href="#i-repor"/></svg></button>
                                </form>
                            </c:when>
                            <c:otherwise>${l.quantidade}&nbsp;<c:out value="${l.unidade}"/></c:otherwise>
                        </c:choose>
                    </td>
                    <td data-label="Subtotal" class="num"><strong><fmt:formatNumber value="${l.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</strong></td>
                    <td class="acoes">
                        <form method="post" action="${ctx}/carrinho/remove">
                            <input type="hidden" name="produtoId" value="${l.produtoId}">
                            <button class="btn-icone btn-peq perigo" type="submit" title="Remover do carrinho" aria-label="Remover ${fn:escapeXml(l.nome)} do carrinho"><svg class="ic"><use href="#i-remover"/></svg></button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        </div>

        <aside class="card resumo">
            <h2>Resumo</h2>
            <dl class="totais">
                <dt>Subtotal</dt><dd><fmt:formatNumber value="${resumo.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
                <dt>IVA 16%</dt><dd><fmt:formatNumber value="${resumo.iva}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
                <dt class="total">Total</dt><dd class="total"><fmt:formatNumber value="${resumo.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</dd>
            </dl>
            <c:choose>
                <c:when test="${resumo.comProblemas}"><button class="btn btn-largo" type="button" disabled>Continuar para confirmar</button></c:when>
                <c:otherwise><a class="btn btn-acento btn-largo" href="${ctx}/compra">Continuar para confirmar<svg class="ic"><use href="#i-seta-dir"/></svg></a></c:otherwise>
            </c:choose>
            <div class="resumo-mais">
                <a class="btn btn-sec btn-peq" href="${ctx}/catalogo"><svg class="ic"><use href="#i-seta-esq"/></svg>Continuar a comprar</a>
                <form method="post" action="${ctx}/carrinho/limpar" onsubmit="return confirm('Esvaziar o carrinho?')">
                    <button class="btn btn-danger btn-peq" type="submit"><svg class="ic"><use href="#i-remover"/></svg>Esvaziar</button>
                </form>
            </div>
        </aside>
    </div>
</c:otherwise>
</c:choose>
<%@ include file="_footer.jspf" %>
