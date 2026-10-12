<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Registar"/>
<c:set var="estilos" value="${['cliente-b.css']}"/>
<%@ include file="_header.jspf" %>
<section class="card card-registo">
    <h1>Criar conta de cliente</h1>
    <%-- com erro, os campos voltam preenchidos (menos as palavras-passe) --%>
    <form class="form" method="post" action="${ctx}/registo">
        <label>Nome completo
            <input name="nome" value="${fn:escapeXml(param.nome)}" required maxlength="100" autocomplete="name" autofocus>
        </label>
        <div class="form-linha">
            <label>Email
                <input type="email" name="email" value="${fn:escapeXml(param.email)}" required maxlength="100" autocomplete="email">
            </label>
            <label>Telefone
                <input type="tel" name="telefone" value="${fn:escapeXml(param.telefone)}" required maxlength="30"
                       pattern="[0-9 +\(\)\-]{9,30}" title="Só dígitos, espaços e +, com pelo menos 9 dígitos"
                       placeholder="+258 84 000 0000" autocomplete="tel">
            </label>
        </div>
        <label>Endereço
            <input name="endereco" value="${fn:escapeXml(param.endereco)}" required maxlength="200"
                   placeholder="Av. Eduardo Mondlane, Nampula" autocomplete="street-address">
        </label>
        <div class="form-linha">
            <label>Palavra-passe
                <input type="password" name="pass" required minlength="4" maxlength="100" autocomplete="new-password">
            </label>
            <label>Confirmar palavra-passe
                <input type="password" name="pass2" required minlength="4" maxlength="100" autocomplete="new-password">
            </label>
        </div>
        <button class="btn" type="submit">Criar conta</button>
    </form>
    <p class="nota">Já tem conta? <a href="${ctx}/login">Entrar</a></p>
</section>
<%@ include file="_footer.jspf" %>
