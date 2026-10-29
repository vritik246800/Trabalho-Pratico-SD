/* AgroGest · A11 — menu lateral, wizard de formulários, botões de envio. Sem bibliotecas (o movimento A14 está em motion.js).
   Tudo funciona sem JS: menu aberto, passos do wizard todos visíveis. */
(function () {
    'use strict';
    var html = document.documentElement;
    var pequeno = window.matchMedia('(max-width: 1000px)');

    function guardar(v) {
        try { localStorage.setItem('agro-menu', v); } catch (e) { /* privado: fica só nesta página */ }
    }

    // --- menu: desktop recolhe para ícones, ecrã pequeno abre como gaveta ---
    document.addEventListener('click', function (e) {
        if (!e.target.closest('[data-menu]')) return;
        if (pequeno.matches) {
            html.classList.toggle('menu-aberto');
        } else {
            guardar(html.classList.toggle('menu-recolhido') ? 'recolhido' : 'aberto');
        }
    });
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        html.classList.remove('menu-aberto');
        var fechar = document.querySelector('.painel [data-fechar]'); // painel de formulário aberto
        if (fechar) fechar.click();
    });
    pequeno.addEventListener('change', function () { html.classList.remove('menu-aberto'); });

    // --- mostrar/esconder palavra-passe ---
    document.addEventListener('click', function (e) {
        var b = e.target.closest('[data-ver-pass]');
        if (!b) return;
        var i = b.parentNode.querySelector('input');
        var ver = i.type === 'password';
        i.type = ver ? 'text' : 'password';
        i.setAttribute('data-pass', '');
        b.textContent = ver ? 'Esconder' : 'Mostrar';
        b.setAttribute('aria-pressed', ver);
    });

    // --- botões de envio: gira e não envia duas vezes ---
    document.addEventListener('submit', function (e) {
        var form = e.target;
        if (e.defaultPrevented || form.method.toLowerCase() !== 'post') return;
        var b = e.submitter || form.querySelector('[type=submit]');
        if (!b) return;
        setTimeout(function () { b.classList.add('a-enviar'); b.disabled = true; }, 0); // depois do envio sair
    });

    // --- wizard: <form class="wizard"> com <fieldset class="passo"><legend>Título</legend>…</fieldset> ---
    function wizard(form) {
        var passos = Array.prototype.slice.call(form.querySelectorAll('.passo'));
        var ol = form.querySelector('.passos');
        var anterior = form.querySelector('[data-anterior]');
        var seguinte = form.querySelector('[data-seguinte]');
        var concluir = form.querySelector('[data-concluir]');
        var actual = 0;

        passos.forEach(function (p, i) {
            var li = document.createElement('li');
            li.innerHTML = '<span class="passo-marca"><b>' + (i + 1) + '</b>'
                + '<svg class="ic" aria-hidden="true"><use href="#i-ok"/></svg></span>';
            li.appendChild(document.createTextNode(p.querySelector('legend').textContent));
            ol.appendChild(li);
        });

        function campos(p) {
            return Array.prototype.slice.call(p.querySelectorAll('input, select, textarea'));
        }

        function valido(p) {
            var mau = campos(p).filter(function (c) { return !c.checkValidity(); })[0];
            if (mau) { mau.reportValidity(); mau.focus(); return false; }
            return true;
        }

        // passo "rever": lista o que foi escrito, com o rótulo de cada campo
        function rever() {
            var dl = form.querySelector('.rever');
            if (!dl) return;
            dl.innerHTML = '';
            passos.forEach(function (p) {
                campos(p).forEach(function (c) {
                    if (c.type === 'hidden' || !c.name || c.dataset.naoRever !== undefined) return;
                    var rotulo = c.closest('label');
                    var nome = rotulo ? rotulo.firstChild.textContent.trim() : c.name;
                    var v = c.tagName === 'SELECT' ? c.options[c.selectedIndex].text : c.value.trim();
                    if (c.type === 'password' || c.hasAttribute('data-pass')) v = v ? 'definida' : '';
                    if (c.type === 'date' && v) v = v.split('-').reverse().join('/');
                    var dt = document.createElement('dt');
                    var dd = document.createElement('dd');
                    dt.textContent = nome;
                    dd.textContent = v || 'não indicado';
                    if (!v) dd.className = 'vazio-valor';
                    dl.appendChild(dt);
                    dl.appendChild(dd);
                });
            });
        }

        function ir(n, voltar) {
            actual = n;
            passos.forEach(function (p, i) {
                p.classList.toggle('actual', i === n);
                p.classList.toggle('volta', i === n && !!voltar);
            });
            Array.prototype.forEach.call(ol.children, function (li, i) {
                li.classList.toggle('actual', i === n);
                li.classList.toggle('feito', i < n);
            });
            anterior.hidden = n === 0;
            seguinte.hidden = n === passos.length - 1;
            concluir.hidden = n !== passos.length - 1;
            if (passos[n].classList.contains('passo-rever')) rever();
            var primeiro = campos(passos[n]).filter(function (c) { return c.type !== 'hidden'; })[0];
            if (primeiro && n > 0) primeiro.focus({ preventScroll: true });
        }

        seguinte.addEventListener('click', function () {
            if (valido(passos[actual])) ir(actual + 1);
        });
        anterior.addEventListener('click', function () { ir(actual - 1, true); });
        // Enter num campo avança em vez de enviar a meio
        form.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && e.target.tagName === 'INPUT' && actual < passos.length - 1) {
                e.preventDefault();
                seguinte.click();
            }
        });
        form.addEventListener('submit', function (e) {
            for (var i = 0; i < passos.length; i++) {
                if (!valido(passos[i])) { e.preventDefault(); ir(i); valido(passos[i]); return; }
            }
        });
        ir(0);
    }

    Array.prototype.forEach.call(document.querySelectorAll('form.wizard'), wizard);

    // --- A14: foto do produto por URL — pré-visualização; sem foto válida o catálogo mostra o modelo 3D ---
    var foto = document.querySelector('input[name=foto]');
    if (foto) {
        var previa = document.createElement('span');
        previa.className = 'foto-previa';
        previa.setAttribute('aria-live', 'polite');
        previa.innerHTML = '<img alt="" hidden><span class="ajuda"></span>';
        foto.after(previa);
        var img = previa.firstChild, msg = previa.lastChild, espera;
        var mostrar = function (texto, ok) { msg.textContent = texto; img.hidden = !ok; };
        img.onload = function () { mostrar('Pré-visualização da foto.', true); };
        img.onerror = function () { mostrar('Não foi possível carregar a imagem deste URL. Sem foto, o catálogo mostra o modelo 3D da categoria.', false); };
        var ver = function () {
            var v = foto.value.trim();
            if (!v) return mostrar('Sem foto: o catálogo mostra o modelo 3D da categoria.', false);
            if (!/^https?:\/\/\S+$/i.test(v)) return mostrar('O URL tem de começar por http:// ou https://.', false);
            mostrar('A carregar a imagem…', false);
            img.src = v;
        };
        foto.addEventListener('input', function () { clearTimeout(espera); espera = setTimeout(ver, 400); });
        ver();
    }
})();
