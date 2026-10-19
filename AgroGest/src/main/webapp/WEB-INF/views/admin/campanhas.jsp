<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="titulo" value="Campanhas"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-campanha"/></svg>Produção</p>
        <h1>Campanhas agrícolas</h1>
        <p>Cada época de produção. Campanha fechada não aceita cultivos; com cultivos não pode ser removida.</p>
    </div>
</header>

<div class="dividido">
    <section class="card ficha">
        <h2><svg class="ic"><use href="#i-mais"/></svg>Nova campanha</h2>
        <form class="form" method="post" action="${ctx}/admin/campanhas">
            <input type="hidden" name="acao" value="criar">
            <label>Nome
                <input name="nome" required maxlength="120" placeholder="Campanha 2026/2027"
                       value="${param.acao == 'criar' ? fn:escapeXml(param.nome) : ''}">
            </label>
            <div class="form-linha">
                <label>Início
                    <input type="date" name="inicio" required value="${param.acao == 'criar' ? fn:escapeXml(param.inicio) : ''}">
                </label>
                <label>Fim
                    <input type="date" name="fim" required value="${param.acao == 'criar' ? fn:escapeXml(param.fim) : ''}">
                </label>
            </div>
            <button class="btn btn-acento" type="submit"><svg class="ic"><use href="#i-mais"/></svg>Criar campanha</button>
        </form>
    </section>

    <div class="campanhas">
    <c:forEach var="camp" items="${campanhas}">
        <article class="card campanha ${camp.fechada ? 'fechada' : ''}">
            <div class="campanha-topo">
                <div>
                    <h2><c:out value="${camp.nome}"/></h2>
                    <p class="nota"><svg class="ic"><use href="#i-calendario"/></svg>${camp.inicioFmt} a ${camp.fimFmt} <span class="id">#${camp.id}</span></p>
                </div>
                <c:choose>
                    <c:when test="${camp.fechada}"><span class="etiqueta etiqueta-neutra"><svg class="ic"><use href="#i-cadeado"/></svg>Fechada</span></c:when>
                    <c:otherwise><span class="etiqueta etiqueta-ok"><span class="ponto-vivo"></span>Aberta</span></c:otherwise>
                </c:choose>
            </div>
            <div class="campanha-fim">
                <a class="campanha-n" href="${ctx}/admin/cultivos?campanha=${camp.id}"><svg class="ic"><use href="#i-cultivo"/></svg><strong>${fn:length(camp.cultivos)}</strong> cultivo(s)</a>
                <div class="campanha-accoes">
                    <form method="post" action="${ctx}/admin/campanhas">
                        <input type="hidden" name="acao" value="${camp.fechada ? 'reabrir' : 'fechar'}">
                        <input type="hidden" name="id" value="${camp.id}">
                        <button class="btn btn-sec btn-peq" type="submit"><svg class="ic"><use href="#${camp.fechada ? 'i-repor' : 'i-cadeado'}"/></svg>${camp.fechada ? 'Reabrir' : 'Fechar'}</button>
                    </form>
                    <form method="post" action="${ctx}/admin/campanhas"
                          onsubmit="return confirm('Remover campanha \'${fn:escapeXml(camp.nome)}\'?')">
                        <input type="hidden" name="acao" value="remover">
                        <input type="hidden" name="id" value="${camp.id}">
                        <button class="btn-icone btn-peq perigo" type="submit" aria-label="Remover campanha"
                                ${not empty camp.cultivos ? 'title="Tem cultivos associados" disabled' : 'title="Remover"'}><svg class="ic"><use href="#i-remover"/></svg></button>
                    </form>
                </div>
            </div>
        </article>
    </c:forEach>
    <c:if test="${empty campanhas}">
        <section class="card vazio"><%@ include file="../_broto.jspf" %><p>Ainda não há campanhas. Crie a primeira época na ficha ao lado.</p></section>
    </c:if>
    </div>
</div>
<%@ include file="../_footer.jspf" %>
