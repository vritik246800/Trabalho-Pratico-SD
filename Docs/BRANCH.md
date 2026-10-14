# Branches

| Branch | Dono   | Origem | Merge para         |
| ------ | ------ | ------ | ------------------ |
| `main` | Vritik | —      | —                  |
| `dev`  | todos  | `main` | `main` (só Vritik) |
| `vd`   | Vritik | `dev`  | `dev`              |
| `yc`   | Yannis | `dev`  | `dev`              |
| `ym`   | Yasin  | `dev`  | `dev`              |

```mermaid
gitGraph
    commit id: "init"
    branch dev
    checkout dev
    commit id: "dev"
    branch vd
    checkout vd
    commit id: "Vritik"
    checkout dev
    branch yc
    checkout yc
    commit id: "Yannis"
    checkout dev
    branch ym
    checkout ym
    commit id: "Yasin"
    checkout dev
    merge vd
    merge yc
    merge ym
    checkout main
    merge dev tag: "release"
```

## Regras

- Ninguém faz push directo para `main`.
- `main` só recebe PR com origem `dev` (workflow `main-only-from-dev`).
- PR `dev` → `main` só merge pelo Vritik (`CODEOWNERS` + ruleset).
- Yannis/Yasin: push **só** na própria branch (`yc`/`ym`). Entram em `dev` por PR, merge pelo Vritik.
- Yannis/Yasin nunca saem da própria branch :: proibido checkout de `dev`, `main`, `vd` ou
  `yc`↔`ym`, e proibido criar branches (locais ou remotas).
- `CLAUDE.md` e `Docs/BRANCH.md` só o Vritik altera. Mudança vinda de `yc`/`ym` não entra em `dev`.

```bash
git pull origin dev                # actualizar a tua branch, sem sair dela
git push origin yc                 # depois abrir PR yc -> dev no GitHub
```
