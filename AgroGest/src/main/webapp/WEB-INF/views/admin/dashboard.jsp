<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Dashboard"/>
<c:set var="estilos" value="${['admin-a.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Dashboard</h1>
<div class="grid">
    <a class="card kpi" href="${ctx}/admin/fornecedores"><span class="kpi-num">${contagens.fornecedores}</span><span class="kpi-rotulo">Fornecedores</span></a>
    <a class="card kpi" href="${ctx}/admin/produtos"><span class="kpi-num">${contagens.produtos}</span><span class="kpi-rotulo">Produtos</span></a>
    <a class="card kpi" href="${ctx}/admin/listagens?tipo=clientes"><span class="kpi-num">${contagens.clientes}</span><span class="kpi-rotulo">Clientes</span></a>
    <a class="card kpi" href="${ctx}/admin/listagens?tipo=compras"><span class="kpi-num">${contagens.vendas}</span><span class="kpi-rotulo">Vendas</span></a>
    <a class="card kpi" href="${ctx}/admin/campanhas"><span class="kpi-num">${contagens.campanhas}</span><span class="kpi-rotulo">Campanhas</span></a>
</div>

<h2>Módulos</h2>
<div class="grid">
    <a class="card atalho" href="${ctx}/admin/fornecedores"><strong>Fornecedores</strong><span>Criar, listar e remover</span></a>
    <a class="card atalho" href="${ctx}/admin/produtos"><strong>Produtos</strong><span>Criar, repor stock e remover</span></a>
    <a class="card atalho" href="${ctx}/admin/campanhas"><strong>Campanhas</strong><span>Campanhas, cultivos e colheitas</span></a>
    <a class="card atalho" href="${ctx}/admin/listagens"><strong>Listagens</strong><span>Produtos, fornecedores, clientes, armazém, compras</span></a>
    <a class="card atalho" href="${ctx}/admin/relatorios"><strong>Relatórios</strong><span>Clientes por nome, volume e assiduidade</span></a>
    <a class="card atalho" href="${ctx}/admin/persistencia"><strong>Persistência</strong><span>Gravar ou apagar o ficheiro de dados</span></a>
</div>
<%@ include file="../_footer.jspf" %>
