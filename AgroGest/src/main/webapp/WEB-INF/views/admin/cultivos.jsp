<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="titulo" value="Cultivos"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Cultivos</h1>

<%-- Selector de campanha --%>
<section class="card sel-campanha">
    <form method="get" action="${ctx}/admin/cultivos" class="form-inline-sel">
        <label><strong>Campanha:</strong>
            <select name="campanha" onchange="this.form.submit()" class="sel-campo">
                <option value="">— seleccionar —</option>
                <c:forEach var="camp" items="${campanhas}">
                    <option value="${camp.id}"
                            ${campanhaId == camp.id ? 'selected' : ''}>
                        <c:out value="${camp.nome}"/>
                        <c:if test="${camp.fechada}"> (fechada)</c:if>
                    </option>
                </c:forEach>
            </select>
        </label>
        <noscript><button class="btn btn-sec btn-peq" type="submit">Ir</button></noscript>
    </form>
</section>

<c:if test="${not empty campanhaId}">
    <%-- Formulário novo cultivo — só para campanhas abertas --%>
    <c:if test="${not empty campanhaSel && !campanhaSel.fechada}">
    <section class="card">
        <h2 class="sem-margem">Novo cultivo — <c:out value="${campanhaSel.nome}"/></h2>
        <form class="form" method="post" action="${ctx}/admin/cultivos">
            <input type="hidden" name="acao" value="criar">
            <input type="hidden" name="campanhaId" value="${campanhaId}">
            <div class="form-linha">
                <label>Cultura
                    <input name="cultura" required maxlength="80"
                           value="${param.acao == 'criar' ? fn:escapeXml(param.cultura) : ''}">
                </label>
                <label>Variedade
                    <input name="variedade" required maxlength="80"
                           value="${param.acao == 'criar' ? fn:escapeXml(param.variedade) : ''}">
                </label>
                <label>Hectares
                    <input type="number" step="0.01" min="0.01" name="hectares" required
                           value="${param.acao == 'criar' ? fn:escapeXml(param.hectares) : ''}">
                </label>
                <label>Data de plantio
                    <input type="date" name="plantio" required
                           value="${param.acao == 'criar' ? fn:escapeXml(param.plantio) : ''}">
                </label>
            </div>
            <div><button class="btn" type="submit">Registar cultivo</button></div>
        </form>
    </section>
    </c:if>
    <c:if test="${not empty campanhaSel && campanhaSel.fechada}">
        <div class="alerta alerta-ok">Campanha fechada — não é possível adicionar cultivos.</div>
    </c:if>

    <%-- Tabela de cultivos --%>
    <div class="tabela-wrap">
    <table class="tabela">
        <thead>
            <tr>
                <th>ID</th><th>Cultura</th><th>Variedade</th>
                <th class="num">Hectares</th><th>Plantio</th>
                <th class="num">Colheitas</th><th></th>
            </tr>
        </thead>
        <tbody>
        <c:forEach var="cv" items="${cultivos}">
            <tr>
                <td>${cv.id}</td>
                <td><c:out value="${cv.cultura}"/></td>
                <td><c:out value="${cv.variedade}"/></td>
                <td class="num">${cv.hectares}</td>
                <td>${cv.plantioFmt}</td>
                <td class="num">
                    <a href="${ctx}/admin/colheitas?cultivo=${cv.id}">${fn:length(cv.colheitas)}</a>
                </td>
                <td class="acoes">
                    <form method="post" action="${ctx}/admin/cultivos"
                          onsubmit="return confirm('Remover cultivo \'${fn:escapeXml(cv.cultura)}\'?')">
                        <input type="hidden" name="acao" value="remover">
                        <input type="hidden" name="id" value="${cv.id}">
                        <input type="hidden" name="campanhaId" value="${campanhaId}">
                        <button class="btn btn-danger btn-peq" type="submit"
                                ${not empty cv.colheitas ? 'title="Tem colheitas associadas" disabled' : ''}>Remover</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty cultivos}">
            <tr><td colspan="7" class="nota">Sem cultivos nesta campanha.</td></tr>
        </c:if>
        </tbody>
    </table>
    </div>
</c:if>

<%@ include file="../_footer.jspf" %>
