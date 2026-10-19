<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Entrar"/>
<%@ include file="_header.jspf" %>
<div class="auth">
    <section class="auth-arte">
        <%@ include file="_campo.jspf" %>
        <div class="auth-arte-texto">
            <a class="marca" href="${ctx}/"><svg class="marca-logo" aria-hidden="true"><use href="#i-logo"/></svg><span class="marca-nome">Agro<em>Gest</em></span></a>
            <p class="olho">Nampula · Moçambique</p>
            <h2>Da semente à factura, <em>a machamba inteira</em> num só lugar.</h2>
            <p>Fornecedores, stock, campanhas e colheitas para quem gere a produção. Catálogo e compras para quem compra.</p>
        </div>
    </section>

    <section class="auth-forma">
        <div class="auth-caixa">
            <h1>Entrar</h1>
            <p>Use o email e a palavra-passe da sua conta.</p>
            <%@ include file="_alertas.jspf" %>
            <form class="form" method="post" action="${ctx}/login">
                <label>Email
                    <span class="campo-ic"><svg class="ic"><use href="#i-utilizador"/></svg>
                        <input type="email" name="email" value="${fn:escapeXml(param.email)}" required autofocus autocomplete="username" placeholder="nome@exemplo.mz"></span>
                </label>
                <label>Palavra-passe
                    <span class="campo-ic"><svg class="ic"><use href="#i-cadeado"/></svg>
                        <input type="password" name="pass" required autocomplete="current-password">
                        <button class="ver-pass" type="button" data-ver-pass aria-pressed="false">Mostrar</button></span>
                </label>
                <button class="btn btn-acento" type="submit"><svg class="ic"><use href="#i-entrar"/></svg>Entrar</button>
            </form>
            <p class="auth-troca">Ainda não tem conta? <a href="${ctx}/registo">Criar conta de cliente</a></p>
        </div>
    </section>
</div>
<%@ include file="_footer.jspf" %>
