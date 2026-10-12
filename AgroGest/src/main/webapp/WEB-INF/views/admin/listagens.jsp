<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Listagens"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<c:set var="rotTipo" value="${{'produtos':'Produtos', 'fornecedores':'Fornecedores', 'clientes':'Clientes', 'armazem':'Armazém', 'compras':'Compras detalhadas'}}"/>
<c:set var="rotOrdem" value="${{'nome':'Nome', 'preco':'Preço', 'stock':'Stock', 'data':'Data', 'valor':'Valor'}}"/>
<c:if test="${tipo == 'produtos' or tipo == 'armazem'}"><c:set target="${rotOrdem}" property="data" value="Validade"/></c:if>
<c:if test="${tipo == 'clientes'}"><c:set target="${rotOrdem}" property="data" value="Última compra"/><c:set target="${rotOrdem}" property="valor" value="Total comprado"/></c:if>
<c:if test="${tipo == 'compras'}"><c:set target="${rotOrdem}" property="nome" value="Cliente"/></c:if>

<h1>Listagens</h1>
<nav class="separadores">
    <c:forEach var="t" items="${tipos}">
        <a class="${t == tipo ? 'activo' : ''}" href="${ctx}/admin/listagens?tipo=${t}">${rotTipo[t]}</a>
    </c:forEach>
</nav>

<div class="ordenar">
    <span class="nota">Ordenar por:</span>
    <c:forEach var="o" items="${ordens}">
        <c:set var="esta" value="${o == ordem}"/>
        <a class="btn btn-peq ${esta ? '' : 'btn-sec'}"
           href="${ctx}/admin/listagens?tipo=${tipo}&amp;ordem=${o}&amp;dir=${esta and not desc ? 'desc' : 'asc'}">
            ${rotOrdem[o]}<c:if test="${esta}"> ${desc ? '↓' : '↑'}</c:if>
        </a>
    </c:forEach>
    <span class="nota">${fn:length(linhas)} registo(s)</span>
</div>

<c:choose>
<c:when test="${tipo == 'produtos' or tipo == 'armazem'}">
    <c:if test="${tipo == 'armazem'}"><p class="nota">Só produtos com stock &gt; 0.</p></c:if>
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>ID</th><th>Nome</th><th>Categoria</th><th>Fornecedor</th><th class="num">Preço</th><th class="num">Stock</th><th>Validade</th></tr></thead>
        <tbody>
        <c:forEach var="p" items="${linhas}">
            <tr class="${p.quantidade == 0 ? 'sem-stock' : ''}">
                <td>${p.id}</td>
                <td><c:out value="${p.nome}"/></td>
                <td><span class="etiqueta">${p.categoria}</span></td>
                <td><c:out value="${fornecedorPorId[p.fornecedorId].nome}" default="—"/></td>
                <td class="num"><fmt:formatNumber value="${p.preco}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td class="num">${p.quantidade} <c:out value="${p.unidade}"/></td>
                <td>${empty p.validade ? '—' : p.validadeFmt}</td>
            </tr>
        </c:forEach>
        </tbody>
    </table></div>
</c:when>

<c:when test="${tipo == 'fornecedores'}">
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>ID</th><th>Nome</th><th>Tipo</th><th>Contacto</th><th>Província</th></tr></thead>
        <tbody>
        <c:forEach var="f" items="${linhas}">
            <tr>
                <td>${f.id}</td>
                <td><c:out value="${f.nome}"/></td>
                <td><span class="etiqueta">${f.tipo}</span></td>
                <td><c:out value="${f.contacto}"/></td>
                <td><c:out value="${f.provincia}"/></td>
            </tr>
        </c:forEach>
        </tbody>
    </table></div>
</c:when>

<c:when test="${tipo == 'clientes'}">
    <div class="tabela-wrap"><table class="tabela">
        <thead><tr><th>ID</th><th>Nome</th><th>Email</th><th>Telefone</th><th>Endereço</th><th class="num">Compras</th><th class="num">Total comprado</th><th>Última compra</th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${linhas}">
            <tr>
                <td>${s.cliente.id}</td>
                <td><c:out value="${s.cliente.nome}"/></td>
                <td><c:out value="${s.cliente.email}"/></td>
                <td><c:out value="${s.cliente.telefone}"/></td>
                <td><c:out value="${s.cliente.endereco}"/></td>
                <td class="num">${s.compras}</td>
                <td class="num"><fmt:formatNumber value="${s.volume}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                <td>${empty s.ultimaCompra ? '—' : s.ultimaCompraFmt}</td>
            </tr>
        </c:forEach>
        </tbody>
    </table></div>
</c:when>

<c:otherwise>
    <%-- compras detalhadas: cliente, endereço, telefone, produtos, qtd, preço unit., subtotal, total, data --%>
    <c:forEach var="v" items="${linhas}">
        <c:set var="cli" value="${clientePorId[v.clienteId]}"/>
        <article class="card compra">
            <header class="compra-topo">
                <div>
                    <strong>${v.numeroFactura}</strong> · ${v.dataFmt}
                    <div><c:out value="${cli.nome}" default="Cliente removido"/></div>
                    <div class="nota"><c:out value="${cli.endereco}"/> · <c:out value="${cli.telefone}"/></div>
                </div>
                <a class="btn btn-sec btn-peq" href="${ctx}/factura?id=${v.id}">Ver factura</a>
            </header>
            <div class="tabela-wrap"><table class="tabela">
                <thead><tr><th>Produto</th><th class="num">Qtd</th><th class="num">Preço unit.</th><th class="num">Subtotal</th></tr></thead>
                <tbody>
                <c:forEach var="i" items="${v.itens}">
                    <tr>
                        <td><c:out value="${i.nomeProduto}"/></td>
                        <td class="num">${i.quantidade}</td>
                        <td class="num"><fmt:formatNumber value="${i.precoUnit}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                        <td class="num"><fmt:formatNumber value="${i.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
                    </tr>
                </c:forEach>
                </tbody>
                <tfoot>
                    <tr><td colspan="3" class="num">Subtotal</td><td class="num"><fmt:formatNumber value="${v.subtotal}" minFractionDigits="2" maxFractionDigits="2"/> MT</td></tr>
                    <tr><td colspan="3" class="num">IVA 16%</td><td class="num"><fmt:formatNumber value="${v.iva}" minFractionDigits="2" maxFractionDigits="2"/> MT</td></tr>
                    <tr class="total"><td colspan="3" class="num">Total</td><td class="num"><fmt:formatNumber value="${v.total}" minFractionDigits="2" maxFractionDigits="2"/> MT</td></tr>
                </tfoot>
            </table></div>
        </article>
    </c:forEach>
</c:otherwise>
</c:choose>
<c:if test="${empty linhas}"><p class="nota">Sem registos.</p></c:if>
<%@ include file="../_footer.jspf" %>
