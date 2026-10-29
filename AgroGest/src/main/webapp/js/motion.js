/* AgroGest · A14 — movimento com GSAP (js/vendor/gsap.min.js).
   Entrada de cada página, cortina entre painéis, entrada depois do login, contadores, barras, gestos.
   Sem GSAP ou com "reduzir movimento" no SO: nada fica escondido, a página é a de A11. */
(function () {
    'use strict';
    var html = document.documentElement;
    var gsap = window.gsap;
    var veio = null; // como se chegou aqui: 'painel' (cortina) · 'entrada' (login/registo) · 'leve' (mesma página, formulário)
    try { veio = sessionStorage.getItem('agro-nav'); sessionStorage.removeItem('agro-nav'); } catch (e) { /* privado */ }

    function limpar() { html.classList.remove('a-entrar', 'nav-painel', 'nav-entrada', 'nav-leve'); }
    function marcar(v) { try { sessionStorage.setItem('agro-nav', v); } catch (e) { /* privado */ } }

    if (!gsap || matchMedia('(prefers-reduced-motion: reduce)').matches) { limpar(); return; }
    html.classList.add('motion');

    var cortina = document.querySelector('.cortina');
    var publico = document.body.classList.contains('publico');
    var pequeno = matchMedia('(max-width: 1000px)').matches;
    var lista = function (sel, max) { return gsap.utils.toArray(sel).slice(0, max || 30); };
    var limpo = 'transform,opacity,visibility'; // devolve o elemento ao CSS (hover, transições)

    // ---------------------------------------------------------------- entrada
    var tl = gsap.timeline({ defaults: { ease: 'power3.out', duration: 0.6 } });
    var leve = veio === 'leve';

    // a cortina chegou fechada pelo CSS (.nav-*): o GSAP fica com ela antes de limpar() tirar a classe
    if (veio === 'painel' || veio === 'entrada') {
        gsap.set(cortina, { autoAlpha: 1 });
        if (veio === 'entrada') html.classList.add('cortina-tudo', 'com-ola');
        tl.eventCallback('onComplete', function () { html.classList.remove('cortina-tudo', 'com-ola'); });
    }

    if (veio === 'entrada' && !publico) {
        // depois do login: logo + "Olá, Nome", a cortina sobe e o menu entra
        tl.from('.cortina-logo', { scale: 0.5, rotation: -40, autoAlpha: 0, duration: 0.55, ease: 'back.out(2)' })
          .from('.cortina-ola', { y: 14, autoAlpha: 0, duration: 0.45 }, '-=.25')
          .to(cortina, { yPercent: -100, duration: 0.85, ease: 'expo.inOut', delay: 0.35 })
          .set(cortina, { autoAlpha: 0, yPercent: 0 });
        if (!pequeno) {
            tl.from('.lateral', { xPercent: -100, duration: 0.7, ease: 'expo.out', clearProps: 'transform' }, '-=.5')
              .from('.lateral .nav > *, .lateral-fim > *', { x: -18, autoAlpha: 0, stagger: 0.03, duration: 0.4, clearProps: limpo }, '-=.45');
        }
        tl.from('.barra', { y: -24, autoAlpha: 0, duration: 0.5, clearProps: limpo }, '<');
    } else if (veio === 'painel' || veio === 'entrada') {
        tl.to(cortina, { yPercent: -100, duration: 0.5, ease: 'power3.inOut' })
          .set(cortina, { autoAlpha: 0, yPercent: 0 });
    }

    if (publico) {
        tl.from('.auth-arte-texto > *', { y: 20, autoAlpha: 0, stagger: 0.08, clearProps: limpo }, '-=.25')
          .from('.auth-caixa > *', { y: 18, autoAlpha: 0, stagger: 0.06, clearProps: limpo }, '<.1');
        if (veio === 'entrada') tl.fromTo('.auth-caixa', { x: -10 }, { x: 0, duration: 0.5, ease: 'elastic.out(1.4, .25)', clearProps: 'transform' }); // login falhou
    } else if (!leve) {
        var blocos = lista('.conteudo > :not(.cabeca):not(.painel):not(.painel-fundo):not([role=status])', 10);
        tl.from('.cabeca-texto > *, .cabeca-accoes', { y: 16, autoAlpha: 0, stagger: 0.06, clearProps: limpo }, '-=.3')
          .from(blocos, { y: 22, autoAlpha: 0, stagger: 0.06, clearProps: limpo }, '-=.45')
          .from(lista('.razao > a, .modulos > .card, .catalogo > .produto, .filtros > a, .separadores > a, .tabela tbody tr', 28),
                { y: 14, autoAlpha: 0, stagger: 0.025, duration: 0.45, clearProps: limpo }, '-=.5');
    }
    limpar(); // o from() já pôs o estado inicial: o CSS pode largar o "esconder"

    // ---------------------------------------------------------------- por painel
    // painel: contagens sobem de 0
    lista('.razao strong').forEach(function (el) {
        var fim = parseInt(el.textContent, 10);
        if (!(fim > 0)) return;
        var o = { v: 0 };
        gsap.to(o, { v: fim, duration: 1.2, ease: 'power2.out', delay: leve ? 0 : 0.4, onUpdate: function () { el.textContent = Math.round(o.v); } });
    });

    // relatórios: barra do volume comprado proporcional ao maior
    var celulas = lista('#volume tbody td.num:nth-child(3)', 200);
    var valores = celulas.map(function (c) { return parseFloat(c.textContent.replace(/[^\d,]/g, '').replace(',', '.')) || 0; });
    var maior = Math.max.apply(null, valores.concat(1));
    celulas.forEach(function (c, i) {
        var b = document.createElement('span');
        b.className = 'barra-valor';
        b.setAttribute('aria-hidden', 'true');
        c.appendChild(b);
        gsap.fromTo(b, { scaleX: 0 }, { scaleX: valores[i] / maior, duration: 1, ease: 'power3.out', delay: 0.5 + i * 0.06 });
    });

    // produtos fora da validade e alertas de erro chamam a atenção uma vez
    gsap.from('.linha-expirado td', { backgroundColor: 'rgba(163, 56, 31, .22)', duration: 1.4, delay: 0.8, ease: 'power1.out', clearProps: 'backgroundColor' });
    gsap.fromTo('.conteudo .alerta-erro, .auth-caixa .alerta-erro', { x: -8 }, { x: 0, duration: 0.6, delay: 0.5, ease: 'elastic.out(1.4, .25)', clearProps: 'transform' });

    // cartões inclinam-se para o rato (só rato/trackpad)
    if (matchMedia('(hover: hover) and (pointer: fine)').matches) {
        lista('.razao > a, .modulo, .catalogo > .produto:not(.indisponivel)', 60).forEach(function (el) {
            gsap.set(el, { transformPerspective: 800 });
            var rx = gsap.quickTo(el, 'rotationX', { duration: 0.5, ease: 'power3' });
            var ry = gsap.quickTo(el, 'rotationY', { duration: 0.5, ease: 'power3' });
            var forte = el.classList.contains('produto') ? 5 : 8;
            el.addEventListener('pointermove', function (e) {
                var r = el.getBoundingClientRect();
                ry(((e.clientX - r.left) / r.width - 0.5) * forte);
                rx(-((e.clientY - r.top) / r.height - 0.5) * forte);
            });
            el.addEventListener('pointerleave', function () { rx(0); ry(0); });
        });
    }

    // ---------------------------------------------------------------- saída
    function sair(url, tudo) {
        marcar('painel');
        html.classList.toggle('cortina-tudo', !!tudo);
        gsap.fromTo(cortina, { yPercent: 100, autoAlpha: 1 },
            { yPercent: 0, duration: 0.32, ease: 'power3.in', onComplete: function () { location.href = url; } });
    }

    document.addEventListener('click', function (e) {
        if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
        var a = e.target.closest('a[href]');
        if (!a || (a.target && a.target !== '_self') || a.hasAttribute('download') || a.origin !== location.origin) return;
        if (a.pathname === location.pathname) { // filtro, ordenar, painel de formulário, âncora: sem cortina
            if (!a.hash) marcar('leve');
            return;
        }
        e.preventDefault();
        sair(a.href, /\/logout$/.test(a.pathname));
    });

    // login/registo: a caixa sai, a cortina fecha com o logo e só depois envia
    function entrarNaApp(f) {
        marcar('entrada');
        html.classList.add('cortina-tudo');
        gsap.timeline({ onComplete: function () { f.submit(); } })
            .to('.auth-caixa', { y: -14, autoAlpha: 0, duration: 0.3, ease: 'power2.in' })
            .fromTo(cortina, { xPercent: 100, autoAlpha: 1 }, { xPercent: 0, duration: 0.55, ease: 'expo.inOut' }, '-=.1')
            .from('.cortina-logo', { scale: 0.4, rotation: -40, duration: 0.45, ease: 'back.out(2)' }, '-=.2');
    }

    // catálogo: a foto do produto voa até ao carrinho e só depois envia
    function voarParaCarrinho(f) {
        var foto = f.closest('.produto') && f.closest('.produto').querySelector('.produto-foto');
        var alvo = document.querySelector('.barra-carrinho');
        marcar('leve');
        if (!foto || !alvo || !alvo.offsetParent) { f.submit(); return; }
        var a = foto.getBoundingClientRect(), b = alvo.getBoundingClientRect();
        var c = foto.cloneNode(true);
        var tela = foto.querySelector('canvas'), copia = c.querySelector('canvas');
        if (tela && copia) { copia.width = tela.width; copia.height = tela.height; copia.getContext('2d').drawImage(tela, 0, 0); }
        c.classList.add('produto-voa');
        gsap.set(c, { left: a.left, top: a.top, width: a.width, height: a.height });
        document.body.appendChild(c);
        gsap.timeline({ onComplete: function () { f.submit(); } })
            .to(c, { x: b.left + b.width / 2 - (a.left + a.width / 2), y: b.top + b.height / 2 - (a.top + a.height / 2),
                     scale: 0.1, rotation: 14, borderRadius: '50%', duration: 0.6, ease: 'power2.in' })
            .to(alvo, { scale: 1.15, duration: 0.12, yoyo: true, repeat: 1, ease: 'power1.out' });
    }

    document.addEventListener('submit', function (e) {
        if (e.defaultPrevented) return; // wizard inválido, confirm() cancelado
        var f = e.target;
        marcar('leve'); // resposta do formulário: entrada discreta, o utilizador quer ver o resultado
        if (f.method.toLowerCase() !== 'post') return;
        var caminho = new URL(f.action, location.href).pathname;
        if (/\/(login|registo)$/.test(caminho)) { e.preventDefault(); entrarNaApp(f); return; }
        if (f.classList.contains('adicionar')) { e.preventDefault(); voarParaCarrinho(f); }
    });

    // voltar atrás (bfcache): a página volta como ficou, com a cortina fechada
    window.addEventListener('pageshow', function (e) {
        if (!e.persisted) return;
        html.classList.remove('cortina-tudo');
        gsap.set(cortina, { autoAlpha: 0, xPercent: 0, yPercent: 0 });
        gsap.set('.auth-caixa', { clearProps: 'all' });
        lista('.produto-voa', 50).forEach(function (c) { c.remove(); });
        lista('button.a-enviar', 50).forEach(function (b) { b.classList.remove('a-enviar'); b.disabled = false; });
    });
})();
