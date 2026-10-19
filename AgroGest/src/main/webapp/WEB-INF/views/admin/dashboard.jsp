<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Painel"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-painel"/></svg>Painel</p>
        <h1>A exploração em números</h1>
        <p>Contagens de agora. Cada número abre a lista correspondente.</p>
    </div>
</header>

<section class="razao" aria-label="Contagens">
    <a href="${ctx}/admin/fornecedores"><svg class="ic"><use href="#i-fornecedor"/></svg><span class="razao-rotulo">Fornecedores</span><strong>${contagens.fornecedores}</strong></a>
    <a href="${ctx}/admin/produtos"><svg class="ic"><use href="#i-produto"/></svg><span class="razao-rotulo">Produtos</span><strong>${contagens.produtos}</strong></a>
    <a href="${ctx}/admin/listagens?tipo=clientes"><svg class="ic"><use href="#i-utilizador"/></svg><span class="razao-rotulo">Clientes</span><strong>${contagens.clientes}</strong></a>
    <a href="${ctx}/admin/listagens?tipo=compras"><svg class="ic"><use href="#i-factura"/></svg><span class="razao-rotulo">Vendas</span><strong>${contagens.vendas}</strong></a>
    <a href="${ctx}/admin/campanhas"><svg class="ic"><use href="#i-campanha"/></svg><span class="razao-rotulo">Campanhas</span><strong>${contagens.campanhas}</strong></a>
</section>

<c:if test="${not empty expirados}">
    <section class="alerta alerta-aviso">
        <svg class="ic"><use href="#i-alerta"/></svg>
        <div>
            <strong>${fn:length(expirados)} produto(s) fora da validade.</strong> Os clientes já não os podem comprar.
            <ul class="lista-alerta">
                <c:forEach var="p" items="${expirados}">
                    <li><a href="${ctx}/admin/produtos?editar=${p.id}"><c:out value="${p.nome}"/></a> · expirou a ${p.validadeFmt} · ${p.quantidade}&nbsp;<c:out value="${p.unidade}"/> em stock</li>
                </c:forEach>
            </ul>
        </div>
    </section>
</c:if>

<h2>Módulos</h2>
<div class="grid modulos">
    <a class="card modulo" href="${ctx}/admin/fornecedores"><span class="modulo-ic"><svg class="ic"><use href="#i-fornecedor"/></svg></span><strong>Fornecedores</strong><span>Criar, listar e remover</span></a>
    <a class="card modulo" href="${ctx}/admin/produtos"><span class="modulo-ic"><svg class="ic"><use href="#i-produto"/></svg></span><strong>Produtos</strong><span>Criar, editar, repor stock e remover</span></a>
    <a class="card modulo" href="${ctx}/admin/campanhas"><span class="modulo-ic"><svg class="ic"><use href="#i-campanha"/></svg></span><strong>Campanhas</strong><span>Abrir, fechar e acompanhar épocas</span></a>
    <a class="card modulo" href="${ctx}/admin/colheitas"><span class="modulo-ic"><svg class="ic"><use href="#i-colheita"/></svg></span><strong>Cultivos e colheitas</strong><span>Hectares plantados e kg colhidos</span></a>
    <a class="card modulo" href="${ctx}/admin/listagens"><span class="modulo-ic"><svg class="ic"><use href="#i-listagem"/></svg></span><strong>Listagens</strong><span>Produtos, fornecedores, clientes, armazém, compras</span></a>
    <a class="card modulo" href="${ctx}/admin/relatorios"><span class="modulo-ic"><svg class="ic"><use href="#i-relatorio"/></svg></span><strong>Relatórios</strong><span>Clientes por nome, volume e assiduidade</span></a>
    <a class="card modulo" href="${ctx}/factura"><span class="modulo-ic"><svg class="ic"><use href="#i-factura"/></svg></span><strong>Facturas</strong><span>Todas as facturas emitidas</span></a>
    <a class="card modulo" href="${ctx}/admin/persistencia"><span class="modulo-ic"><svg class="ic"><use href="#i-persistencia"/></svg></span><strong>Persistência</strong><span>Gravar ou apagar o ficheiro de dados</span></a>
</div>
<%@ include file="../_footer.jspf" %>
