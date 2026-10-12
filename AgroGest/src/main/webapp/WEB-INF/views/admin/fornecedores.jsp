<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Fornecedores"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Fornecedores</h1>

<section class="card">
    <h2 class="sem-margem">Novo fornecedor</h2>
    <%-- valores de param.* voltam ao formulário quando há erro --%>
    <form class="form" method="post" action="${ctx}/admin/fornecedores">
        <input type="hidden" name="acao" value="criar">
        <div class="form-linha">
            <label>Nome <input name="nome" value="${param.acao == 'criar' ? fn:escapeXml(param.nome) : ''}" required maxlength="100"></label>
            <label>Tipo
                <select name="tipo" required>
                    <c:forEach var="t" items="${tipos}">
                        <option value="${t}" ${param.acao == 'criar' && param.tipo == t ? 'selected' : ''}>${t}</option>
                    </c:forEach>
                </select>
            </label>
            <label>Contacto <input name="contacto" value="${param.acao == 'criar' ? fn:escapeXml(param.contacto) : ''}" required maxlength="60" placeholder="+258 84 000 0000"></label>
            <label>Província <input name="provincia" list="provincias" value="${param.acao == 'criar' ? fn:escapeXml(param.provincia) : ''}" required maxlength="60"></label>
        </div>
        <datalist id="provincias">
            <option>Cabo Delgado</option><option>Gaza</option><option>Inhambane</option><option>Manica</option>
            <option>Maputo</option><option>Maputo Cidade</option><option>Nampula</option><option>Niassa</option>
            <option>Sofala</option><option>Tete</option><option>Zambézia</option>
        </datalist>
        <div><button class="btn" type="submit">Criar fornecedor</button></div>
    </form>
</section>

<div class="tabela-wrap">
<table class="tabela">
    <thead><tr><th>ID</th><th>Nome</th><th>Tipo</th><th>Contacto</th><th>Província</th><th class="num">Produtos</th><th></th></tr></thead>
    <tbody>
    <c:forEach var="f" items="${fornecedores}">
        <c:set var="n" value="${empty nProdutos[f.id] ? 0 : nProdutos[f.id]}"/>
        <tr>
            <td>${f.id}</td>
            <td><c:out value="${f.nome}"/></td>
            <td><span class="etiqueta">${f.tipo}</span></td>
            <td><c:out value="${f.contacto}"/></td>
            <td><c:out value="${f.provincia}"/></td>
            <td class="num">${n}</td>
            <td class="acoes">
                <form method="post" action="${ctx}/admin/fornecedores" onsubmit="return confirm('Remover este fornecedor?')">
                    <input type="hidden" name="acao" value="remover">
                    <input type="hidden" name="id" value="${f.id}">
                    <button class="btn btn-danger btn-peq" type="submit" ${n > 0 ? 'title="Tem produtos associados"' : ''}>Remover</button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty fornecedores}"><tr><td colspan="7" class="nota">Sem fornecedores.</td></tr></c:if>
    </tbody>
</table>
</div>
<%@ include file="../_footer.jspf" %>
