/* AgroGest · A14 — modelos 3D low-poly (.glb feitos no Blender, ver blender/modelos.py) com three.js.
   Cabeçalho de cada página: o modelo do módulo (arrastar roda, clique dá uma volta).
   Produto sem foto, ou com URL que não carrega: o modelo da categoria em vez do ícone.
   Um só WebGLRenderer desenha todas as vistas e copia cada uma para o seu <canvas> 2D —
   o browser só aceita ~16 contextos WebGL e o catálogo pode ter dezenas de cartões.
   Sem WebGL fica o ícone SVG de sempre. */
import {
    WebGLRenderer, Scene, PerspectiveCamera, HemisphereLight, DirectionalLight, Box3, Vector3, Group,
    NeutralToneMapping, GLTFLoader
} from './vendor/three-agro.min.js';

const PASTA = new URL('../modelos/', import.meta.url);
const PAGINA = {
    '/login': 'trator', '/registo': 'semente',
    '/admin': 'celeiro', '/admin/fornecedores': 'camiao', '/admin/produtos': 'fertilizante',
    '/admin/campanhas': 'trator', '/admin/cultivos': 'planta', '/admin/colheitas': 'milho',
    '/admin/listagens': 'caixa', '/admin/relatorios': 'moedas', '/admin/persistencia': 'silo',
    '/factura': 'moedas', '/catalogo': 'planta', '/carrinho': 'carrinho', '/compra': 'moedas',
    '/minhas-compras': 'caixa'
};
// o ícone SVG da categoria já está no HTML: é dele que se tira o modelo
const CATEGORIA = { 'i-semente': 'semente', 'i-fertilizante': 'fertilizante', 'i-maquinaria': 'trator', 'i-ferramenta': 'enxada' };
const parado = matchMedia('(prefers-reduced-motion: reduce)').matches;
const FOV = 30, ELEVACAO = 0.32;

let gl = null;
try { gl = new WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'low-power' }); } catch (e) { /* sem WebGL */ }

if (gl) {
    gl.setPixelRatio(1);
    gl.toneMapping = NeutralToneMapping;
    gl.setClearColor(0x000000, 0);
    let gw = 1, gh = 1;

    const cena = new Scene();
    cena.add(new HemisphereLight(0xfff4e0, 0x3c4a2a, 2.4));
    const sol = new DirectionalLight(0xffffff, 2.6);
    sol.position.set(3, 5, 4);
    cena.add(sol);
    const camara = new PerspectiveCamera(FOV, 1, 0.1, 50);

    const cache = new Map();
    const loader = new GLTFLoader();
    const carregar = (nome) => {
        if (!cache.has(nome)) cache.set(nome, loader.loadAsync(new URL(nome + '.glb', PASTA).href).then((g) => g.scene));
        return cache.get(nome);
    };

    const vistas = [];
    const porCanvas = new Map();
    const olho = new IntersectionObserver((es) => es.forEach((e) => {
        const v = porCanvas.get(e.target);
        v.visivel = e.isIntersecting;
        v.sujo = true;
    }), { rootMargin: '120px' });
    const medida = new ResizeObserver((es) => es.forEach((e) => { porCanvas.get(e.target).sujo = true; }));

    // tipo :: 'heroi' (cabeçalho, gira sempre) · 'cartao' (catálogo) · 'mini' (tabela) — estes dois só giram com o rato por cima
    function vista(caixa, nome, tipo) {
        const canvas = document.createElement('canvas');
        canvas.className = 'cena-canvas';
        canvas.setAttribute('aria-hidden', 'true');
        if (tipo === 'heroi') caixa.appendChild(canvas); else caixa.prepend(canvas); // selos por cima
        const v = {
            canvas, ctx: canvas.getContext('2d'), tipo, raiz: new Group(), giro: new Group(),
            ang: -0.55, vel: 0, alvoVel: tipo === 'heroi' && !parado ? 0.35 : 0, visivel: false, sujo: true, arrastar: false
        };
        v.raiz.add(v.giro);
        carregar(nome).then((modelo) => {
            const m = modelo.clone();
            const caixaM = new Box3().setFromObject(m);
            m.position.sub(caixaM.getCenter(new Vector3()));
            v.giro.add(m);
            v.giro.scale.setScalar(2 / caixaM.getSize(new Vector3()).length()); // esfera envolvente de raio 1
            caixa.classList.add('tem-3d');
            if (window.gsap && !parado) {
                window.gsap.from(v.raiz.scale, { x: 0.01, y: 0.01, z: 0.01, duration: 0.9, ease: 'back.out(1.6)', delay: tipo === 'heroi' ? 0.3 : 0, onUpdate: () => { v.sujo = true; } });
            }
            v.sujo = true;
        }).catch(() => canvas.remove()); // modelo em falta: fica o ícone
        porCanvas.set(canvas, v);
        olho.observe(canvas);
        medida.observe(canvas);
        vistas.push(v);
        return v;
    }

    function desenhar(v) {
        v.sujo = false;
        const dpr = Math.min(window.devicePixelRatio || 1, 2);
        const cw = Math.round(v.canvas.clientWidth * dpr), ch = Math.round(v.canvas.clientHeight * dpr);
        if (!cw || !ch) return;
        if (v.canvas.width !== cw || v.canvas.height !== ch) { v.canvas.width = cw; v.canvas.height = ch; }
        if (cw > gw || ch > gh) { gw = Math.max(gw, cw); gh = Math.max(gh, ch); gl.setSize(gw, gh, false); }
        gl.setViewport(0, 0, cw, ch);
        const aspecto = cw / ch, meia = FOV * Math.PI / 360;
        const d = 1.06 / Math.sin(Math.min(meia, Math.atan(Math.tan(meia) * aspecto))); // cabe na vertical e na horizontal
        camara.aspect = aspecto;
        camara.position.set(0, Math.sin(ELEVACAO) * d, Math.cos(ELEVACAO) * d);
        camara.lookAt(0, 0, 0);
        camara.updateProjectionMatrix();
        v.giro.rotation.y = v.ang;
        cena.add(v.raiz);
        gl.render(cena, camara);
        cena.remove(v.raiz);
        v.ctx.clearRect(0, 0, cw, ch);
        v.ctx.drawImage(gl.domElement, 0, gh - ch, cw, ch, 0, 0, cw, ch); // viewport GL começa em baixo
    }

    let antes = performance.now();
    function quadro(agora) {
        requestAnimationFrame(quadro);
        const dt = Math.min(0.05, (agora - antes) / 1000);
        antes = agora;
        for (const v of vistas) {
            if (!v.visivel || !v.giro.children.length) continue;
            if (!v.arrastar) v.vel += (v.alvoVel - v.vel) * Math.min(1, dt * 3); // inércia depois de largar
            if (Math.abs(v.vel) > 1e-3) { v.ang += v.vel * dt; v.sujo = true; }
            if (v.tipo === 'heroi' && !parado) { v.raiz.position.y = Math.sin(agora / 700) * 0.04; v.sujo = true; }
            if (v.sujo) desenhar(v);
        }
    }
    requestAnimationFrame(quadro);

    // arrastar roda o modelo; clique sem arrastar dá uma volta inteira
    function interagir(v) {
        let x0 = 0, xa = 0, ta = 0;
        v.canvas.addEventListener('pointerdown', (e) => {
            v.arrastar = true; x0 = xa = e.clientX; ta = e.timeStamp;
            v.canvas.setPointerCapture(e.pointerId);
        });
        v.canvas.addEventListener('pointermove', (e) => {
            if (!v.arrastar) return;
            const dx = e.clientX - xa, dtm = Math.max(1, e.timeStamp - ta);
            v.ang += dx * 0.012;
            v.vel = Math.max(-12, Math.min(12, dx * 0.012 / (dtm / 1000)));
            xa = e.clientX; ta = e.timeStamp; v.sujo = true;
        });
        const largar = (e) => {
            if (!v.arrastar) return;
            v.arrastar = false;
            if (Math.abs(e.clientX - x0) < 4 && window.gsap) {
                v.vel = 0;
                window.gsap.to(v, { ang: v.ang + Math.PI * 2, duration: 1.1, ease: 'power3.inOut', onUpdate: () => { v.sujo = true; } });
            }
        };
        v.canvas.addEventListener('pointerup', largar);
        v.canvas.addEventListener('pointercancel', largar);
    }

    // cabeçalho da página
    const pagina = document.body.dataset.pagina || '';
    const nome = PAGINA[pagina];
    const ancora = document.querySelector('.conteudo .cabeca') || document.querySelector('.auth-arte');
    if (nome && ancora) {
        const caixa = document.createElement('div');
        caixa.className = 'cena-3d';
        const texto = ancora.querySelector('.cabeca-texto');
        if (texto) texto.after(caixa); else ancora.appendChild(caixa);
        interagir(vista(caixa, nome, 'heroi'));
    }

    // fotos de produto: sem URL, ou URL que falha → modelo da categoria
    for (const caixa of document.querySelectorAll('.produto-foto, .prod-foto')) {
        const uso = caixa.querySelector('svg use');
        const modelo = uso && CATEGORIA[(uso.getAttribute('href') || '').slice(1)];
        if (!modelo) continue;
        const tipo = caixa.classList.contains('prod-foto') ? 'mini' : 'cartao';
        const ligar = () => {
            const v = vista(caixa, modelo, tipo);
            const zona = caixa.closest(tipo === 'mini' ? 'tr' : '.produto');
            if (zona && !parado) {
                zona.addEventListener('pointerenter', () => { v.alvoVel = 1.6; });
                zona.addEventListener('pointerleave', () => { v.alvoVel = 0; });
            }
        };
        const img = caixa.querySelector('img');
        if (!img || (img.complete && !img.naturalWidth)) ligar(); else img.addEventListener('error', ligar);
    }
}
