<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="titulo" value="Persistência"/>
<c:set var="estilos" value="${['admin-c.css']}"/>
<%@ include file="../_header.jspf" %>
<header class="cabeca">
    <div class="cabeca-texto">
        <p class="olho"><svg class="ic"><use href="#i-persistencia"/></svg>Sistema</p>
        <h1>Persistência de dados</h1>
        <p>Os dados vivem em memória e são gravados no ficheiro <code>agrogest.ser</code> quando o Tomcat pára.
            Aqui pode gravar já ou apagar o ficheiro para o próximo arranque começar com os dados de exemplo.</p>
    </div>
</header>

<section class="card ficheiro">
    <svg class="ficheiro-ic" viewBox="0 0 24 24" aria-hidden="true"><use href="#i-persistencia"/></svg>
    <div>
        <p class="olho">Ficheiro de dados</p>
        <code class="caminho">${fn:escapeXml(caminho)}</code>
    </div>
    <form method="post" action="${ctx}/admin/persistencia">
        <input type="hidden" name="acao" value="abrir">
        <button class="btn btn-sec" type="submit"><svg class="ic"><use href="#i-pasta"/></svg>Abrir pasta</button>
    </form>
</section>

<div class="acoes-persistencia">
    <section class="card">
        <h2 class="titulo-ic"><svg class="ic"><use href="#i-gravar"/></svg>Gravar agora</h2>
        <p class="nota">Guarda o estado actual em disco, sem reiniciar o servidor. Útil antes de manutenção.</p>
        <form method="post" action="${ctx}/admin/persistencia">
            <input type="hidden" name="acao" value="gravar">
            <button class="btn" type="submit"><svg class="ic"><use href="#i-gravar"/></svg>Gravar dados agora</button>
        </form>
    </section>

    <section class="card card-perigo">
        <h2 class="titulo-ic"><svg class="ic"><use href="#i-remover"/></svg>Apagar ficheiro</h2>
        <p class="nota">Remove o <code>.ser</code> do disco. Os dados actuais <strong>ficam em memória</strong> até ao próximo
            reinício; aí arrancam os dados de exemplo.</p>
        <form method="post" action="${ctx}/admin/persistencia"
              onsubmit="return confirm('Apagar o ficheiro de dados? O sistema voltará ao estado inicial no próximo reinício.')">
            <input type="hidden" name="acao" value="apagar">
            <button class="btn btn-danger" type="submit"><svg class="ic"><use href="#i-remover"/></svg>Apagar ficheiro .ser</button>
        </form>
    </section>
</div>
<%@ include file="../_footer.jspf" %>
