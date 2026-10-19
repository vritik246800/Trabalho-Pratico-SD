<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Acesso negado"/>
<%@ include file="_header.jspf" %>
<section class="card card-estreito negado">
    <svg class="negado-ic" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-cadeado"/></svg>
    <p class="olho">Erro 403</p>
    <h1>Esta área é do administrador</h1>
    <p class="nota">A sua conta não tem acesso a esta página.</p>
    <c:choose>
        <c:when test="${empty eu}"><a class="btn btn-acento" href="${ctx}/login"><svg class="ic"><use href="#i-entrar"/></svg>Entrar</a></c:when>
        <c:otherwise><a class="btn" href="${ctx}/"><svg class="ic"><use href="#i-seta-esq"/></svg>Voltar ao início</a></c:otherwise>
    </c:choose>
</section>
<%@ include file="_footer.jspf" %>
