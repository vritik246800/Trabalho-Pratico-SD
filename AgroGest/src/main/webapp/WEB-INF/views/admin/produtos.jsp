<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Produtos"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<c:set var="rotCat" value="${{'SEMENTE':'Semente', 'FERTILIZANTE':'Fertilizante', 'MAQUINARIA':'Maquinaria', 'FERRAMENTA':'Ferramenta'}}"/>
<c:set var="icCat" value="${{'SEMENTE':'i-semente', 'FERTILIZANTE':'i-fertilizante', 'MAQUINARIA':'i-maquinaria', 'FERRAMENTA':'i-ferramenta'}}"/>
<%-- painel do formulário: ?novo=1, ?editar=id, ou um POST criar/editar que falhou (voltou = valores escritos) --%>
<c:set var="voltou" value="${param.acao == 'criar' or param.acao == 'editar'}"/>
<c:set var="editando" value="${not empty emEdicao}"/>
<c:set var="abrir" value="${not empty param.novo or editando or param.acao == 'criar'}"/>
<c:set var="f" value="${editando and not voltou ? emEdicao : null}"/>

<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-produto"/></svg>Catálogo</p>
        <h1>Produtos</h1>
        <p>${fn:length(produtos)} produto(s) à venda no catálogo dos clientes.</p>
    </div>
    <div class="cabeca-accoes">
        <c:choose>
            <c:when test="${empty fornecedores}"><a class="btn btn-sec" href="${ctx}/admin/fornecedores"><svg class="ic"><use href="#i-fornecedor"/></svg>Criar primeiro um fornecedor</a></c:when>
            <c:otherwise><a class="btn btn-acento" href="${ctx}/admin/produtos?novo=1"><svg class="ic"><use href="#i-mais"/></svg>Novo produto</a></c:otherwise>
        </c:choose>
    </div>
</header>

<c:if test="${not empty expirados}">
    <div class="alerta alerta-aviso">
        <svg class="ic"><use href="#i-alerta"/></svg>
        <div><strong>${fn:length(expirados)} produto(s) fora da validade</strong> (a vermelho na tabela). Os clientes já não os podem comprar:
            edite a validade do lote novo ou remova-os.</div>
    </div>
</c:if>

<div class="tabela-wrap">
<table class="tabela">
    <thead><tr><th>Produto</th><th>Categoria</th><th>Fornecedor</th><th class="num">Preço</th><th class="num">Stock</th><th>Validade</th><th>Repor stock</th><th class="acoes"><span class="visualmente-oculto">Acções</span></th></tr></thead>
    <tbody>
    <c:forEach var="p" items="${produtos}">
        <tr class="${p.expirado ? 'linha-expirado' : ''}">
            <td>
                <div class="prod">
                    <span class="prod-foto">
                        <svg class="ic"><use href="#${icCat[p.categoria.name()]}"/></svg>
                        <c:if test="${not empty p.foto}"><img src="${fn:escapeXml(p.foto)}" alt="" loading="lazy" onerror="this.remove()"></c:if>
                    </span>
                    <span><strong><c:out value="${p.nome}"/></strong><span class="id"> #${p.id}</span>
                        <c:if test="${not empty p.descricao}"><br><span class="nota"><c:out value="${p.descricao}"/></span></c:if></span>
                </div>
            </td>
            <td><span class="etiqueta"><svg class="ic"><use href="#${icCat[p.categoria.name()]}"/></svg>${rotCat[p.categoria.name()]}</span></td>
            <td><c:out value="${fornecedorPorId[p.fornecedorId].nome}" default="—"/></td>
            <td class="num"><fmt:formatNumber value="${p.preco}" minFractionDigits="2" maxFractionDigits="2"/> MT</td>
            <td class="num">
                <c:choose>
                    <c:when test="${p.quantidade == 0}"><span class="etiqueta etiqueta-erro">Esgotado</span></c:when>
                    <c:otherwise>${p.quantidade}&nbsp;<c:out value="${p.unidade}"/></c:otherwise>
                </c:choose>
            </td>
            <td>
                <c:choose>
                    <c:when test="${empty p.validade}"><span class="nota">sem validade</span></c:when>
                    <c:when test="${p.expirado}"><span class="etiqueta etiqueta-expirado"><svg class="ic"><use href="#i-alerta"/></svg>${p.validadeFmt}</span></c:when>
                    <c:otherwise>${p.validadeFmt}</c:otherwise>
                </c:choose>
            </td>
            <td>
                <form class="repor" method="post" action="${ctx}/admin/produtos">
                    <input type="hidden" name="acao" value="repor">
                    <input type="hidden" name="id" value="${p.id}">
                    <input class="campo-solto" type="number" name="qtd" min="1" step="1" required aria-label="Quantidade a repor de ${fn:escapeXml(p.nome)}" placeholder="+ qtd">
                    <button class="btn-icone btn-peq" type="submit" title="Repor stock" aria-label="Repor stock"><svg class="ic"><use href="#i-repor"/></svg></button>
                </form>
            </td>
            <td class="acoes">
                <a class="btn-icone btn-peq" href="${ctx}/admin/produtos?editar=${p.id}" title="Editar" aria-label="Editar ${fn:escapeXml(p.nome)}"><svg class="ic"><use href="#i-editar"/></svg></a>
                <form method="post" action="${ctx}/admin/produtos" onsubmit="return confirm('Remover este produto?')">
                    <input type="hidden" name="acao" value="remover">
                    <input type="hidden" name="id" value="${p.id}">
                    <button class="btn-icone btn-peq perigo" type="submit" title="Remover" aria-label="Remover ${fn:escapeXml(p.nome)}"><svg class="ic"><use href="#i-remover"/></svg></button>
                </form>
            </td>
        </tr>
    </c:forEach>
    <c:if test="${empty produtos}"><tr><td colspan="8" class="vazio-linha"><%@ include file="../_broto.jspf" %>Ainda não há produtos. Use “Novo produto”.</td></tr></c:if>
    </tbody>
</table>
</div>

<c:if test="${abrir and not empty fornecedores}">
<a class="painel-fundo" href="${ctx}/admin/produtos" tabindex="-1" aria-hidden="true"></a>
<aside class="painel" role="dialog" aria-modal="true" aria-labelledby="painel-titulo">
    <div class="painel-topo">
        <div>
            <p class="olho"><svg class="ic"><use href="#${editando ? 'i-editar' : 'i-mais'}"/></svg>${editando ? 'Editar' : 'Novo'}</p>
            <h2 id="painel-titulo">${editando ? fn:escapeXml(emEdicao.nome) : 'Novo produto'}</h2>
        </div>
        <a class="btn-icone" href="${ctx}/admin/produtos" data-fechar aria-label="Fechar"><svg class="ic"><use href="#i-fechar"/></svg></a>
    </div>
    <c:if test="${not empty erro}"><div class="alerta alerta-erro" role="alert"><svg class="ic"><use href="#i-erro"/></svg><div><c:out value="${erro}"/></div></div></c:if>

    <form class="form wizard" method="post" action="${ctx}/admin/produtos">
        <input type="hidden" name="acao" value="${editando ? 'editar' : 'criar'}">
        <c:if test="${editando}"><input type="hidden" name="id" value="${emEdicao.id}"></c:if>
        <c:set var="vCat" value="${voltou ? param.categoria : f.categoria}"/>
        <c:set var="vForn" value="${voltou ? param.fornecedorId : f.fornecedorId}"/>
        <ol class="passos" aria-hidden="true"></ol>

        <fieldset class="passo">
            <legend>Identificação</legend>
            <label>Nome <input name="nome" value="${voltou ? fn:escapeXml(param.nome) : fn:escapeXml(f.nome)}" required maxlength="100" placeholder="Semente de milho Matuba"></label>
            <label>Categoria
                <select name="categoria" required>
                    <c:forEach var="cat" items="${categorias}">
                        <option value="${cat}" ${vCat == cat ? 'selected' : ''}>${rotCat[cat.name()]}</option>
                    </c:forEach>
                </select>
            </label>
            <label>Fornecedor
                <select name="fornecedorId" required>
                    <c:forEach var="fo" items="${fornecedores}">
                        <option value="${fo.id}" ${vForn == fo.id ? 'selected' : ''}><c:out value="${fo.nome}"/></option>
                    </c:forEach>
                </select>
            </label>
        </fieldset>

        <fieldset class="passo">
            <legend>Preço e stock</legend>
            <label>Preço (MT) <input type="number" name="preco" min="0.01" step="0.01" value="${voltou ? fn:escapeXml(param.preco) : f.preco}" required></label>
            <div class="form-linha">
                <label>Quantidade em stock <input type="number" name="quantidade" min="0" step="1" value="${voltou ? fn:escapeXml(param.quantidade) : f.quantidade}" required></label>
                <label>Unidade <input name="unidade" list="unidades" value="${voltou ? fn:escapeXml(param.unidade) : fn:escapeXml(f.unidade)}" required maxlength="30" placeholder="kg, saco, unidade"></label>
            </div>
            <datalist id="unidades"><option>kg</option><option>saco</option><option>litro</option><option>unidade</option></datalist>
        </fieldset>

        <fieldset class="passo">
            <legend>Validade e apresentação</legend>
            <label>Validade <input type="date" name="validade" value="${voltou ? fn:escapeXml(param.validade) : f.validade}">
                <span class="ajuda">Vazio = sem validade (ferramentas, maquinaria). Data passada = fora de venda.</span></label>
            <label>Foto (URL) <input type="url" name="foto" value="${voltou ? fn:escapeXml(param.foto) : fn:escapeXml(f.foto)}" maxlength="500" placeholder="https://..."></label>
            <label>Descrição <textarea name="descricao" rows="3" maxlength="500">${voltou ? fn:escapeXml(param.descricao) : fn:escapeXml(f.descricao)}</textarea></label>
        </fieldset>

        <fieldset class="passo passo-rever">
            <legend>Rever</legend>
            <dl class="rever"></dl>
        </fieldset>

        <div class="wizard-nav">
            <button class="btn btn-sec" type="button" data-anterior><svg class="ic"><use href="#i-seta-esq"/></svg>Anterior</button>
            <div class="depois">
                <button class="btn" type="button" data-seguinte>Seguinte<svg class="ic"><use href="#i-seta-dir"/></svg></button>
                <button class="btn btn-acento" type="submit" data-concluir><svg class="ic"><use href="#i-gravar"/></svg>${editando ? 'Guardar alterações' : 'Criar produto'}</button>
            </div>
        </div>
        <div class="form-fim"><button class="btn btn-acento" type="submit">${editando ? 'Guardar alterações' : 'Criar produto'}</button></div>
    </form>
</aside>
</c:if>
<%@ include file="../_footer.jspf" %>
