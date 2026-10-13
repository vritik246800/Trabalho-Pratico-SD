<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="titulo" value="Campanhas"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Campanhas Agrícolas</h1>

<section class="card">
    <h2 class="sem-margem">Nova campanha</h2>
    <form class="form" method="post" action="${ctx}/admin/campanhas">
        <input type="hidden" name="acao" value="criar">
        <div class="form-linha">
            <label>Nome
                <input name="nome" required maxlength="120"
                       value="${param.acao == 'criar' ? fn:escapeXml(param.nome) : ''}">
            </label>
            <label>Início
                <input type="date" name="inicio" required
                       value="${param.acao == 'criar' ? fn:escapeXml(param.inicio) : ''}">
            </label>
            <label>Fim
                <input type="date" name="fim" required
                       value="${param.acao == 'criar' ? fn:escapeXml(param.fim) : ''}">
            </label>
        </div>
        <div><button class="btn" type="submit">Criar campanha</button></div>
    </form>
</section>

<div class="tabela-wrap">
<table class="tabela">
    <thead>
        <tr>
            <th>ID</th><th>Nome</th><th>Início</th><th>Fim</th>
            <th>Estado</th><th class="num">Cultivos</th><th></th>
        </tr>
    </thead>
    <tbody>
    <c:forEach var="camp" items="${campanhas}">
        <tr>
            <td>${camp.id}</td>
            <td><c:out value="${camp.nome}"/></td>
            <td>${camp.inicioFmt}</td>
            <td>${camp.fimFmt}</td>
            <td>
                <c:choose>
                    <c:when test="${camp.fechada}">
                        <span class="etiqueta estado-fechada">Fechada</span>
                    </c:when>
                    <c:otherwise>
                        <span class="etiqueta estado-aberta">Aberta</span>
                    </c:otherwise>
                </c:choose>
            </td>
            <td class="num">
                <a href="${ctx}/admin/cultivos?campanha=${camp.id}">${fn:length(camp.cultivos)}</a>
            </td>
            <td class="acoes">
                <c:choose>
                    <c:when test="${camp.fechada}">
                        <form method="post" action="${ctx}/admin/campanhas">
                            <input type="hidden" name="acao" value="reabrir">
                            <input type="hidden" name="id" value="${camp.id}">
                            <button class="btn btn-sec btn-peq" type="submit">Reabrir</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <form method="post" action="${ctx}/admin/campanhas">
                            <input type="hidden" name="acao" value="fechar">
                            <input type="hidden" name="id" value="${camp.id}">
                            <button class="btn btn-sec btn-peq" type="submit">Fechar</button>
                        </form>
                    </c:otherwise>
                </c:choose>
                <form method="post" action="${ctx}/admin/campanhas"
                      onsubmit="return confirm('Remover campanha \'${fn:escapeXml(camp.nome)}\'?')">
                    <input type="hidden" name="acao" value="remover">
                    <input type="hidden" name="id" value="${camp.id}">
                    <button class="btn btn-danger btn-peq" type="submit"
                            ${not empty camp.cultivos ? 'title="Tem cultivos associados" disabled' : ''}>Remover</button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty campanhas}">
        <tr><td colspan="7" class="nota">Sem campanhas registadas.</td></tr>
    </c:if>
    </tbody>
</table>
</div>
<%@ include file="../_footer.jspf" %>
