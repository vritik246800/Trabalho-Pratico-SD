<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Criar conta"/>
<%@ include file="_header.jspf" %>
<div class="auth">
    <section class="auth-arte">
        <%@ include file="_campo.jspf" %>
        <div class="auth-arte-texto">
            <a class="marca" href="${ctx}/"><svg class="marca-logo" aria-hidden="true"><use href="#i-logo"/></svg><span class="marca-nome">Agro<em>Gest</em></span></a>
            <p class="olho">Conta de cliente</p>
            <h2>Sementes, adubo e ferramentas <em>com factura</em> no fim.</h2>
            <p>Três passos: quem é, onde o encontramos e a palavra-passe. Entra logo a seguir.</p>
        </div>
    </section>

    <section class="auth-forma">
        <div class="auth-caixa auth-largo">
            <h1>Criar conta</h1>
            <p>Os dados ficam na factura de cada compra.</p>
            <%@ include file="_alertas.jspf" %>
            <%-- com erro, os campos voltam preenchidos (menos as palavras-passe) --%>
            <form class="form wizard" method="post" action="${ctx}/registo">
                <ol class="passos" aria-hidden="true"></ol>
                <fieldset class="passo">
                    <legend>Quem é</legend>
                    <label>Nome completo
                        <input name="nome" value="${fn:escapeXml(param.nome)}" required maxlength="100" autocomplete="name" autofocus>
                    </label>
                    <label>Email
                        <input type="email" name="email" value="${fn:escapeXml(param.email)}" required maxlength="100" autocomplete="email" placeholder="nome@exemplo.mz">
                    </label>
                </fieldset>
                <fieldset class="passo">
                    <legend>Contacto</legend>
                    <label>Telefone
                        <input type="tel" name="telefone" value="${fn:escapeXml(param.telefone)}" required maxlength="30"
                               pattern="[0-9 +\(\)\-]{9,30}" title="Só dígitos, espaços e +, com pelo menos 9 dígitos"
                               placeholder="+258 84 000 0000" autocomplete="tel">
                    </label>
                    <label>Endereço
                        <input name="endereco" value="${fn:escapeXml(param.endereco)}" required maxlength="200"
                               placeholder="Av. Eduardo Mondlane, Nampula" autocomplete="street-address">
                    </label>
                </fieldset>
                <fieldset class="passo">
                    <legend>Palavra-passe</legend>
                    <label>Palavra-passe
                        <span class="campo-ic"><svg class="ic"><use href="#i-cadeado"/></svg>
                            <input type="password" name="pass" required minlength="4" maxlength="100" autocomplete="new-password">
                            <button class="ver-pass" type="button" data-ver-pass aria-pressed="false">Mostrar</button></span>
                        <span class="ajuda">Pelo menos 4 caracteres.</span>
                    </label>
                    <label>Confirmar palavra-passe
                        <span class="campo-ic"><svg class="ic"><use href="#i-cadeado"/></svg>
                            <input type="password" name="pass2" required minlength="4" maxlength="100" autocomplete="new-password" data-nao-rever></span>
                    </label>
                </fieldset>
                <fieldset class="passo passo-rever">
                    <legend>Rever</legend>
                    <dl class="rever"></dl>
                </fieldset>
                <div class="wizard-nav">
                    <button class="btn btn-sec" type="button" data-anterior><svg class="ic"><use href="#i-seta-esq"/></svg>Anterior</button>
                    <div class="depois">
                        <button class="btn" type="button" data-seguinte>Seguinte<svg class="ic"><use href="#i-seta-dir"/></svg></button>
                        <button class="btn btn-acento" type="submit" data-concluir><svg class="ic"><use href="#i-ok"/></svg>Criar conta</button>
                    </div>
                </div>
                <div class="form-fim"><button class="btn btn-acento" type="submit">Criar conta</button></div>
            </form>
            <p class="auth-troca">Já tem conta? <a href="${ctx}/login">Entrar</a></p>
        </div>
    </section>
</div>
<%@ include file="_footer.jspf" %>
