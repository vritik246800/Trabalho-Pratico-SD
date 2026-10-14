<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="titulo" value="Colheitas"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Colheitas</h1>

<%-- Selector de cultivo agrupado por campanha --%>
<section class="card sel-cultivo">
    <form method="get" action="${ctx}/admin/colheitas" class="form-inline-sel">
        <label><strong>Cultivo:</strong>
            <select name="cultivo" onchange="this.form.submit()" class="sel-campo">
                <option value="">— seleccionar —</option>
                <c:forEach var="camp" items="${campanhas}">
                    <c:if test="${not empty camp.cultivos}">
                        <optgroup label="${fn:escapeXml(camp.nome)}${camp.fechada ? ' (fechada)' : ''}">
                            <c:forEach var="cv" items="${camp.cultivos}">
                                <option value="${cv.id}"
                                        ${cultivoId == cv.id ? 'selected' : ''}>
                                    #${cv.id} — <c:out value="${cv.cultura}"/> (<c:out value="${cv.variedade}"/>)
                                </option>
                            </c:forEach>
                        </optgroup>
                    </c:if>
                </c:forEach>
            </select>
        </label>
        <noscript><button class="btn btn-sec btn-peq" type="submit">Ir</button></noscript>
    </form>
</section>

<c:if test="${not empty cultivoId && not empty cultivoSel}">
    <%-- Formulário nova colheita --%>
    <section class="card">
        <h2 class="sem-margem">
            Nova colheita — <c:out value="${cultivoSel.cultura}"/> (<c:out value="${cultivoSel.variedade}"/>)
        </h2>
        <form class="form" method="post" action="${ctx}/admin/colheitas">
            <input type="hidden" name="acao" value="criar">
            <input type="hidden" name="cultivoId" value="${cultivoId}">
            <div class="form-linha">
                <label>Data da colheita
                    <input type="date" name="data" required
                           value="${param.acao == 'criar' ? fn:escapeXml(param.data) : ''}">
                </label>
                <label>Quantidade (kg)
                    <input type="number" step="0.1" min="0.1" name="kg" required
                           placeholder="ex: 1200.5"
                           value="${param.acao == 'criar' ? fn:escapeXml(param.kg) : ''}">
                </label>
                <label>Preço por kg (MT)
                    <input type="number" step="0.01" min="0.01" name="precoKg" required
                           placeholder="ex: 15.00"
                           value="${param.acao == 'criar' ? fn:escapeXml(param.precoKg) : ''}">
                </label>
            </div>
            <div><button class="btn" type="submit">Registar colheita</button></div>
        </form>
    </section>

    <%-- Tabela de colheitas --%>
    <div class="tabela-wrap">
    <c:set var="totalKg" value="0"/>
    <c:set var="totalVal" value="0"/>
    <table class="tabela">
        <thead>
            <tr>
                <th>ID</th><th>Data</th>
                <th class="num">Kg</th>
                <th class="num">Preço/kg (MT)</th>
                <th class="num">Valor Total (MT)</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <c:forEach var="col" items="${colheitas}">
            <c:set var="totalKg" value="${totalKg + col.kg}"/>
            <c:set var="totalVal" value="${totalVal + col.valorTotal}"/>
            <tr>
                <td>${col.id}</td>
                <td>${col.dataFmt}</td>
                <td class="num"><fmt:formatNumber value="${col.kg}" minFractionDigits="1" maxFractionDigits="1"/></td>
                <td class="num"><fmt:formatNumber value="${col.precoKg}" minFractionDigits="2" maxFractionDigits="2"/></td>
                <td class="num valor-total"><fmt:formatNumber value="${col.valorTotal}" minFractionDigits="2" maxFractionDigits="2"/></td>
                <td class="acoes">
                    <form method="post" action="${ctx}/admin/colheitas"
                          onsubmit="return confirm('Remover esta colheita?')">
                        <input type="hidden" name="acao" value="remover">
                        <input type="hidden" name="id" value="${col.id}">
                        <input type="hidden" name="cultivoId" value="${cultivoId}">
                        <button class="btn btn-danger btn-peq" type="submit">Remover</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty colheitas}">
            <tr><td colspan="6" class="nota">Sem colheitas registadas para este cultivo.</td></tr>
        </c:if>
        </tbody>
        <c:if test="${not empty colheitas}">
        <tfoot>
            <tr class="total">
                <td colspan="2"><strong>Total</strong></td>
                <td class="num"><fmt:formatNumber value="${totalKg}" minFractionDigits="1" maxFractionDigits="1"/> kg</td>
                <td></td>
                <td class="num valor-total">
                    <strong><fmt:formatNumber value="${totalVal}" minFractionDigits="2" maxFractionDigits="2"/> MT</strong>
                </td>
                <td></td>
            </tr>
        </tfoot>
        </c:if>
    </table>
    </div>
</c:if>

<%@ include file="../_footer.jspf" %>
