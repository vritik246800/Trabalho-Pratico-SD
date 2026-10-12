<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Acesso negado"/>
<%@ include file="_header.jspf" %>
<section class="card card-estreito">
    <h1>403 · Acesso negado</h1>
    <p>Esta página é exclusiva do administrador.</p>
    <c:choose>
        <c:when test="${empty eu}"><a class="btn" href="${ctx}/login">Entrar</a></c:when>
        <c:otherwise><a class="btn" href="${ctx}/">Voltar ao início</a></c:otherwise>
    </c:choose>
</section>
<%@ include file="_footer.jspf" %>
