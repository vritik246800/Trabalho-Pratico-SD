<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Entrar"/>
<%@ include file="_header.jspf" %>
<section class="card card-estreito">
    <h1>Entrar</h1>
    <form class="form" method="post" action="${ctx}/login">
        <label>Email
            <input type="email" name="email" value="${fn:escapeXml(param.email)}" required autofocus>
        </label>
        <label>Palavra-passe
            <input type="password" name="pass" required>
        </label>
        <button class="btn" type="submit">Entrar</button>
    </form>
    <p class="nota">Ainda não tem conta? <a href="${ctx}/registo">Registar</a></p>
</section>
<%@ include file="_footer.jspf" %>
