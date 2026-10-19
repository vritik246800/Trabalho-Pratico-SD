<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Fornecedores"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<c:set var="rotTipo" value="${{'SEMENTES':'Sementes', 'MAQUINARIA':'Maquinaria', 'FERTILIZANTES':'Fertilizantes'}}"/>
<c:set var="icTipo" value="${{'SEMENTES':'i-semente', 'MAQUINARIA':'i-maquinaria', 'FERTILIZANTES':'i-fertilizante'}}"/>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-fornecedor"/></svg>Catálogo</p>
        <h1>Fornecedores</h1>
        <p>Quem fornece sementes, adubos e maquinaria. Um fornecedor com produtos não pode ser removido.</p>
    </div>
</header>

<div class="dividido">
    <section class="card ficha">
        <h2><svg class="ic"><use href="#i-mais"/></svg>Novo fornecedor</h2>
        <%-- valores de param.* voltam ao formulário quando há erro --%>
        <form class="form" method="post" action="${ctx}/admin/fornecedores">
            <input type="hidden" name="acao" value="criar">
            <label>Nome <input name="nome" value="${param.acao == 'criar' ? fn:escapeXml(param.nome) : ''}" required maxlength="100" placeholder="Sementes do Norte, Lda."></label>
            <label>Tipo
                <select name="tipo" required>
                    <c:forEach var="t" items="${tipos}">
                        <option value="${t}" ${param.acao == 'criar' && param.tipo == t ? 'selected' : ''}>${rotTipo[t.name()]}</option>
                    </c:forEach>
                </select>
            </label>
            <label>Contacto <input name="contacto" value="${param.acao == 'criar' ? fn:escapeXml(param.contacto) : ''}" required maxlength="60" placeholder="+258 84 000 0000"></label>
            <label>Província <input name="provincia" list="provincias" value="${param.acao == 'criar' ? fn:escapeXml(param.provincia) : ''}" required maxlength="60" placeholder="Nampula"></label>
            <datalist id="provincias">
                <option>Cabo Delgado</option><option>Gaza</option><option>Inhambane</option><option>Manica</option>
                <option>Maputo</option><option>Maputo Cidade</option><option>Nampula</option><option>Niassa</option>
                <option>Sofala</option><option>Tete</option><option>Zambézia</option>
            </datalist>
            <button class="btn btn-acento" type="submit"><svg class="ic"><use href="#i-mais"/></svg>Criar fornecedor</button>
        </form>
    </section>

    <div class="tabela-wrap">
    <table class="tabela">
        <thead><tr><th>Fornecedor</th><th>Tipo</th><th>Contacto</th><th>Província</th><th class="num">Produtos</th><th class="acoes"><span class="visualmente-oculto">Acções</span></th></tr></thead>
        <tbody>
        <c:forEach var="f" items="${fornecedores}">
            <c:set var="n" value="${empty nProdutos[f.id] ? 0 : nProdutos[f.id]}"/>
            <tr>
                <td><strong><c:out value="${f.nome}"/></strong> <span class="id">#${f.id}</span></td>
                <td><span class="etiqueta"><svg class="ic"><use href="#${icTipo[f.tipo.name()]}"/></svg>${rotTipo[f.tipo.name()]}</span></td>
                <td><c:out value="${f.contacto}"/></td>
                <td><c:out value="${f.provincia}"/></td>
                <td class="num">${n}</td>
                <td class="acoes">
                    <form method="post" action="${ctx}/admin/fornecedores" onsubmit="return confirm('Remover este fornecedor?')">
                        <input type="hidden" name="acao" value="remover">
                        <input type="hidden" name="id" value="${f.id}">
                        <button class="btn-icone btn-peq perigo" type="submit" aria-label="Remover ${fn:escapeXml(f.nome)}" title="${n > 0 ? 'Tem produtos associados' : 'Remover'}"><svg class="ic"><use href="#i-remover"/></svg></button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty fornecedores}"><tr><td colspan="6" class="vazio-linha"><%@ include file="../_broto.jspf" %>Ainda não há fornecedores. Crie o primeiro na ficha ao lado.</td></tr></c:if>
        </tbody>
    </table>
    </div>
</div>
<%@ include file="../_footer.jspf" %>
