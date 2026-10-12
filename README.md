# AgroGest — Sistema de Gestão Agrícola

Trabalho prático de **Sistemas Distribuídos** · Engenharia Informática · 2026 · **Grupo 13**.

Aplicação web para um agricultor de Nampula: gere fornecedores, produtos, campanhas agrícolas,
cultivos e colheitas, e vende produtos em stock a clientes com emissão de factura.
Java + Servlets no Apache Tomcat, **sem base de dados** (listas em memória + serialização em ficheiro).

## Colaboradores

| Nome | GitHub | Branch | Tarefas |
|---|---|---|---|
| Vritik Valabdas | [@vritik246800](https://github.com/vritik246800) | `vd` | A1, A2, A3, A4, A5 |
| Yannis Chilundo | [@yannischilundo](https://github.com/yannischilundo) | `yc` | B1, B2, B3, B4, B5, B6 |
| Yasin Magno | [@yasinmagno](https://github.com/yasinmagno) | `ym` | C1, C2, C3, C4, C5, C6 |

Tarefas :: IDs do [Docs/TODO.md](Docs/TODO.md) reservados por cada um. Reservar = `🔒 <Nome>` no
TODO **e** ID na tua linha aqui, no mesmo commit (`update: Docs/TODO.md, README.md`).

## Funcionalidades

| Perfil | Módulos |
|---|---|
| Administrador | fornecedores · produtos (repor stock) · campanhas · cultivos · colheitas · listagens com ordenação · compras detalhadas · relatórios de clientes · dashboard · persistência manual |
| Cliente | auto-registo · catálogo com filtro por categoria · carrinho · compra · factura `FT-<ano>-<n>` com IVA 16 % · histórico |

Regras de negócio :: RN01 sem venda acima do stock · RN02 venda atómica (tudo ou nada) ·
RN03 cliente só vê as suas facturas · RN04 `/admin/*` só admin (HTTP 403) · RN05 rotas de
cliente exigem sessão · RN06 IDs sequenciais via `AtomicInteger`.

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Linguagem | Java 17+ |
| Servidor | Apache Tomcat 10.1 (porta **8081**) |
| Controladores / filtros / listeners | Jakarta Servlets 6.0 (`@WebServlet`, `@WebFilter`, `@WebListener`) |
| Vista | JSP + JSTL 3.0 + EL · HTML5 + CSS3 próprio |
| Dados | `ArrayList` / `Map` / `Collections.synchronizedList` |
| Persistência | `ObjectOutputStream` / `ObjectInputStream` → ficheiro `.ser` (escrita atómica) |
| Build | Apache Maven (WAR) |

## Arquitectura

```mermaid
graph TD
    B["Browser"] -->|"HTTP :8081"| F["AuthFilter · sessão + perfil"]
    F --> S["Servlets · Controllers"]
    S --> SV["Services · regras de negócio"]
    SV --> R["Repo · DataStore em memória"]
    R --> P["Persistencia · ficheiro .ser"]
    S -->|"forward"| V["JSP + JSTL + CSS"]
    L["AppListener"] -->|"arranque · carregar"| P
    L -->|"paragem · gravar"| P
```

```
AgroGest/src/main/
├── java/mz/agrogest/
│   ├── model/      POJOs Serializable + enums
│   ├── repo/       DataStore, Persistencia
│   ├── service/    regras de negócio
│   ├── servlet/    controllers (admin/ para /admin/*)
│   ├── filter/     AuthFilter
│   ├── listener/   AppListener
│   └── util/       PasswordUtil
└── webapp/
    ├── css/
    └── WEB-INF/views/   JSP
```

## Instalação e deploy

```bash
cd AgroGest
mvn package                                   # gera target/agrogest.war
cp target/agrogest.war $CATALINA_HOME/webapps/
$CATALINA_HOME/bin/startup.sh
```

Abrir `http://localhost:8081/agrogest/`.
Tomcat na porta 8081 e serviço systemd :: ver `Docs/deploy/` (a completar na tarefa C5).

## Credenciais de teste

| Perfil | Email | Password |
|---|---|---|
| Admin | `admin@agro.mz` | `admin234` |
| Cliente | `joao@teste.mz` | `1234` |

## Documentação

Índice de `Docs/` :: [[Docs/INDEX]].

| Ficheiro | Conteúdo |
|---|---|
| [Docs/Enunciado AgroGest 2026.pdf](Docs/Enunciado%20AgroGest%202026.pdf) | enunciado |
| [Docs/TODO.md](Docs/TODO.md) | divisão do trabalho e contratos comuns |
| [Docs/BRANCH.md](Docs/BRANCH.md) | regras de branch e merge |
| [Docs/CHANGELOG.md](Docs/CHANGELOG.md) | alterações (consolidado de `CHANGELOG-vd/yc/ym.md`) |
| `Docs/Manual AgroGest.pdf` | manual de utilização (tarefa C6) |
