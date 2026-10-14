<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Persistência"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<h1>Persistência de Dados</h1>

<div class="card aviso-persistencia">
    <p>Os dados da aplicação são mantidos em memória e gravados automaticamente no ficheiro
    <code>data/agrogest.ser</code> quando o Tomcat é parado.</p>
    <p>Pode forçar a gravação agora (útil antes de operações de manutenção) ou apagar o ficheiro
    para que a próxima reinicialização comece com os dados de exemplo (<em>seed</em>).</p>
</div>

<div class="acoes-persistencia">
    <section class="card">
        <h2 class="sem-margem">Gravar agora</h2>
        <p>Guarda o estado actual em disco imediatamente, sem reiniciar o servidor.</p>
        <form method="post" action="${ctx}/admin/persistencia">
            <input type="hidden" name="acao" value="gravar">
            <button class="btn" type="submit">Gravar dados agora</button>
        </form>
    </section>

    <section class="card card-perigo">
        <h2 class="sem-margem">Apagar ficheiro</h2>
        <p>Remove o ficheiro <code>.ser</code> do disco.
           Os dados actuais <strong>permanecem em memória</strong> até ao próximo reinício.
           Na próxima inicialização do Tomcat, os dados de exemplo (<em>seed</em>) serão carregados.</p>
        <form method="post" action="${ctx}/admin/persistencia"
              onsubmit="return confirm('Apagar o ficheiro de dados? O sistema voltará ao estado inicial no próximo reinício.')">
            <input type="hidden" name="acao" value="apagar">
            <button class="btn btn-danger" type="submit">Apagar ficheiro .ser</button>
        </form>
    </section>
</div>

<%@ include file="../_footer.jspf" %>
