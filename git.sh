#!/usr/bin/env bash
# Menu git do grupo AgroGest. As regras vêm das tabelas do CLAUDE.md e do Docs/BRANCH.md
# (versão de origin/dev), lidas a cada arranque: muda a tabela, muda o menu.
# Acção fora das regras = recusada. Tabelas ilegíveis = o script não corre.
# macOS: ./git.sh · Windows: Git Bash (não PowerShell) · ./git.sh --regras mostra o que leu.
set -u
cd "$(dirname "$0")" || exit 1

REGRAS=origin/dev
URL=https://github.com/vritik246800/Trabalho-Pratico-SD

erro() { echo "✖ $*" >&2; }
ok()   { echo "✔ $*"; }
sair() { erro "$*"; exit 1; }
confirmar() { read -r -p "$1 [s/N] " r; [ "$r" = s ] || [ "$r" = S ]; }
contem() { case " $1 " in *" $2 "*) return 0 ;; esac; return 1; }
n() { git rev-list --count "$1..$2" 2>/dev/null || echo "?"; }   # commits em $2 que $1 não tem

# --- regras ------------------------------------------------------------------
case "$(git remote get-url origin 2>/dev/null)" in
  *vritik246800/Trabalho-Pratico-SD*) ;;
  *) sair "origin não é vritik246800/Trabalho-Pratico-SD." ;;
esac
git fetch -q origin || erro "Sem ligação ao GitHub: regras e estado podem estar desactualizados."

AWK_LIB='
function tick(s) { return match(s, /`[^`]+`/) ? substr(s, RSTART + 1, RLENGTH - 2) : "" }
function ticks(s, o) { while (match(s, /`[^`]+`/)) { o = o (o ? " " : "") substr(s, RSTART + 1, RLENGTH - 2); s = substr(s, RSTART + RLENGTH) } return o }
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
'
# CLAUDE.md "Pessoa | GitHub | SO | Branch própria | Pode fazer push para"
# → pessoa|users GitHub|SO|branch própria|push livre   (entrada com "(...)" não é push livre)
PESSOAS=$(git show "$REGRAS:CLAUDE.md" 2>/dev/null | awk -F'|' "$AWK_LIB"'
  /^\| *Pessoa *\| *GitHub *\| *SO *\|/ { t = 1; next }
  t && /^\|[-:| ]+$/ { next }
  t && /^\|/ {
    so = ($4 ~ /Windows/) ? "Windows" : (($4 ~ /macOS|Darwin/) ? "macOS" : "?")
    livre = ""; k = split($6, p, ",")
    for (i = 1; i <= k; i++) if (p[i] !~ /\(/) livre = livre (livre ? " " : "") tick(p[i])
    print trim($2) "|" ticks($3) "|" so "|" tick($5) "|" livre; next }
  t { exit }')
# Docs/BRANCH.md "Branch | Dono | Origem | Merge para" → branch|dono|origem|merge para|só quem
BRANCHES=$(git show "$REGRAS:Docs/BRANCH.md" 2>/dev/null | awk -F'|' "$AWK_LIB"'
  /^\| *Branch *\| *Dono *\| *Origem *\|/ { t = 1; next }
  t && /^\|[-:| ]+$/ { next }
  t && /^\|/ {
    so = ""; if (match($5, /\([^)]*\)/)) { so = substr($5, RSTART + 1, RLENGTH - 2); sub(/^só /, "", so) }
    print tick($2) "|" trim($3) "|" tick($4) "|" tick($5) "|" trim(so); next }
  t { exit }')
[ -n "$PESSOAS" ] && [ -n "$BRANCHES" ] ||
  sair "Não consegui ler as tabelas do CLAUDE.md / Docs/BRANCH.md em $REGRAS. Sem regras, nada corre."

campo() { printf '%s\n' "$BRANCHES" | awk -F'|' -v b="$1" -v k="$2" '$1 == b { print $k; exit }'; }
definir() {   # $1 = linha de PESSOAS
  IFS='|' read -r PESSOA GITHUB SO_ESPERADO MINHA LIVRE <<< "$1"
  ORIGEM=$(campo "$MINHA" 3); INTEG=$(campo "$MINHA" 4); REL=$(campo "$INTEG" 4); REL_SO=$(campo "$INTEG" 5)
}
so_ok() { [ -z "$1" ] || [ "$1" = "$PESSOA" ]; }

# Docs/TODO.md "ID | Tarefa | Pacote | Estado" (stdin) → id|tarefa|pacote|estado
tarefas() { awk -F'|' "$AWK_LIB"'
  /^\| *ID *\| *Tarefa *\| *Pacote *\| *Estado *\|/ { t = 1; next }
  t && /^\|[-:| ]+$/ { next }
  t && /^\|/ { print trim($2) "|" trim($3) "|" trim($4) "|" trim($5); next }
  t { exit }'; }
# README.md "Nome | GitHub | Branch | Tarefas" (stdin) → célula Tarefas da linha da tua branch; falha se não há
tarefas_readme() { awk -F'|' -v b="$MINHA" "$AWK_LIB"'
  /^\| *Nome *\| *GitHub *\| *Branch *\| *Tarefas *\|/ { t = 1; next }
  t && /^\|[-:| ]+$/ { next }
  t && /^\|/ { if (tick($4) == b) { print trim($5); f = 1; exit } next }
  t { exit }
  END { exit !f }'; }

# Única porta das acções: 0 se as regras deixam, senão MOTIVO diz porquê.
pode() {
  MOTIVO=
  case $1 in
    commit)     contem "$LIVRE" "$MINHA" || MOTIVO="CLAUDE.md: $MINHA não está na tua lista de push" ;;
    enviar)     contem "$LIVRE" "$INTEG" || MOTIVO="CLAUDE.md: $INTEG não está na tua lista de push" ;;
    actualizar) [ -n "$ORIGEM" ] || MOTIVO="Docs/BRANCH.md não diz de que branch vem a $MINHA" ;;
    pr_integ)   so_ok "$(campo "$MINHA" 5)" || MOTIVO="Docs/BRANCH.md: $MINHA → $INTEG só $(campo "$MINHA" 5)" ;;
    pr_rel)     if [ -z "$REL" ]; then MOTIVO="Docs/BRANCH.md: $INTEG não faz merge para nenhuma branch"
                elif ! so_ok "$REL_SO"; then MOTIVO="Docs/BRANCH.md: $INTEG → $REL só $REL_SO · pede-lhe"; fi ;;
    reservar)   if ! contem "$LIVRE" "$INTEG"; then MOTIVO="CLAUDE.md: a reserva é push para $INTEG, que não está na tua lista de push"
                elif ! git show "$REGRAS:README.md" 2>/dev/null | tarefas_readme >/dev/null; then
                  MOTIVO="README.md em $REGRAS sem coluna Tarefas com linha da $MINHA"
                elif [ -z "$(git show "$REGRAS:Docs/TODO.md" 2>/dev/null | tarefas)" ]; then
                  MOTIVO="Docs/TODO.md em $REGRAS sem tabela Estado"; fi ;;
    *)          MOTIVO="acção desconhecida" ;;
  esac
  [ -z "$MOTIVO" ]
}

if [ "${1:-}" = --regras ]; then
  printf '%s\n' "$PESSOAS" | while IFS= read -r l; do
    definir "$l"
    echo "$PESSOA · GitHub: $GITHUB · $SO_ESPERADO · branch $MINHA · push livre: $LIVRE"
    for a in commit enviar actualizar pr_integ pr_rel reservar; do
      if pode "$a"; then echo "  ✔ $a"; else echo "  ✖ $a — $MOTIVO"; fi
    done
  done
  exit 0
fi

# --- quem és (CLAUDE.md) -------------------------------------------------------
case "$(uname -s 2>/dev/null)" in Darwin) SO=macOS ;; *) SO=Windows ;; esac   # MINGW*/MSYS*/CYGWIN*
NOME=$(git config user.name)
[ -n "$NOME" ] || sair 'git user.name vazio. CLAUDE.md: configurar antes do primeiro commit:
  git config user.name "<o teu user do GitHub>"
  git config user.email "<email da conta GitHub>"'
EU=$(printf '%s\n' "$PESSOAS" | awk -F'|' -v u="$NOME" '
  { k = split($2, g, " "); for (i = 1; i <= k; i++) if (g[i] == u) { l = $0; c++ } }
  END { if (c == 1) print l }')
[ -n "$EU" ] || sair "user.name '$NOME' não está (uma só vez) na tabela de pessoas do CLAUDE.md. Configura o teu:
  git config user.name \"<o teu user do GitHub>\""
definir "$EU"
if [ "$SO" != "$SO_ESPERADO" ]; then
  erro "CLAUDE.md: $PESSOA usa $SO_ESPERADO, mas isto é $SO."
  confirmar "És mesmo $PESSOA ($NOME)?" || sair "Então configura a tua conta: git config user.name \"<o teu user do GitHub>\""
fi
[ -n "$MINHA" ] && [ "$(campo "$MINHA" 2)" = "$PESSOA" ] ||
  sair "CLAUDE.md dá a branch '$MINHA' a $PESSOA, mas o Docs/BRANCH.md diz que é de '$(campo "$MINHA" 2)'."
[ -n "$INTEG" ] || sair "Docs/BRANCH.md não diz para onde vai o merge da $MINHA."
git show-ref -q --verify "refs/heads/$MINHA" || git branch -q --track "$MINHA" "origin/$MINHA" 2>/dev/null

# --- acções (só chegam aqui depois de pode) ----------------------------------------
ir_para_minha() {
  ATUAL=$(git branch --show-current)
  [ "$ATUAL" = "$MINHA" ] && return 0
  echo "Estás em '${ATUAL:-HEAD solto}'. CLAUDE.md: commits só na tua branch, $MINHA."
  confirmar "Fazer checkout para $MINHA (alterações por commitar vão junto)?" || return 1
  git checkout "$MINHA" || { erro "Checkout falhou."; return 1; }
}

mensagem_auto() {   # padrão do repo: create:/update:/delete: <caminho>, uma linha por tipo
  git diff --cached --name-status | awk -F'\t' '
    $1=="A"{c=c (c?", ":"") $2} $1=="M"||$1=="T"{u=u (u?", ":"") $2} $1=="D"{d=d (d?", ":"") $2}
    $1 ~ /^R/{d=d (d?", ":"") $2; c=c (c?", ":"") $3}
    END{ if(c) print "create: " c; if(u) print "update: " u; if(d) print "delete: " d }'
}
msg_valida() { ! printf '%s\n' "$1" | grep -qvE '^(create|update|delete): [^ ]'; }

commit() {
  ir_para_minha || return
  if [ -n "$(git status --porcelain)" ]; then
    git status --short
    echo "Ficheiros a adicionar: um caminho por linha, linha vazia termina (Enter logo = todos)."
    IFS= read -r f
    if [ -z "$f" ]; then git add -A
    else while [ -n "$f" ]; do git add -- "$f" || return; IFS= read -r f; done; fi
    git diff --cached --quiet && { erro "Nada em stage."; return; }
    alheios=$(git diff --cached --name-only | grep '^Docs/CHANGELOG-.*\.md$' | grep -vxF "Docs/CHANGELOG-$MINHA.md")
    if [ -n "$alheios" ]; then
      erro "Recusado. CLAUDE.md: nunca editar o CHANGELOG de outra pessoa. Tira do stage e escolhe os ficheiros um a um:"
      printf '  git restore --staged %s\n' $alheios
      return
    fi
    msg=$(mensagem_auto)
    printf -- '--- mensagem ---\n%s\n----------------\n' "$msg"
    while read -r -p "Enter = usar esta · ou escreve outra (create:/update:/delete: <caminho>): " outra && [ -n "$outra" ]; do
      msg_valida "$outra" && { msg=$outra; break; }
      erro "Recusada: fora do padrão create:/update:/delete: <caminho> (CLAUDE.md)."
    done
    args=(); while IFS= read -r l; do args+=(-m "$l"); done <<< "$msg"
    git commit -q "${args[@]}" || return
    ok "Commit feito na $MINHA."
  fi
  [ "$(n "origin/$MINHA" "$MINHA")" = 0 ] && { ok "Nada para enviar: origin/$MINHA já tem tudo."; return; }
  git push -u origin "$MINHA" && ok "Push para origin/$MINHA." ||
    erro "Push recusado. Se o GitHub tem commits que não tens: git pull --no-rebase origin $MINHA (nunca --force)."
}

falta_changelog() {   # cabeçalhos "## " dos Docs/CHANGELOG-<branch>.md que faltam no Docs/CHANGELOG.md
  awk 'FILENAME == ARGV[1] { if (/^## /) tem[$0] = 1; next } /^## / && !($0 in tem)' \
    Docs/CHANGELOG.md Docs/CHANGELOG-*.md 2>/dev/null
}

enviar() {   # CLAUDE.md, ordem obrigatória: pull · merge · CHANGELOG.md · commit · push
  sujos=$(git status --porcelain -uno)
  # retomar a meio: em INTEG só o CHANGELOG.md pode estar por commitar
  [ "$(git branch --show-current)" = "$INTEG" ] && sujos=$(printf '%s\n' "$sujos" | grep -v ' Docs/CHANGELOG\.md$')
  [ -n "$sujos" ] && { erro "Tens alterações por commitar. Usa a opção 1 primeiro."; return; }
  git push -u origin "$MINHA" || return
  git checkout -q "$INTEG" || return
  git pull --no-rebase origin "$INTEG" ||
    { erro "Conflitos no pull de $INTEG: resolve, git add + git commit, e corre a opção 2 outra vez."; return; }
  git merge --no-edit "$MINHA" ||
    { erro "Conflitos no merge $MINHA → $INTEG: resolve, git add + git commit, e corre a opção 2 outra vez."; return; }
  while falta=$(falta_changelog); [ -n "$falta" ]; do
    echo "CLAUDE.md: junta no Docs/CHANGELOG.md estas entradas (texto igual, mais recente no topo):"
    printf '%s\n' "$falta" | sed 's/^/  /'
    read -r -p "Enter quando estiver gravado (a opção 2 retoma daqui se saíres) " _ ||
      { erro "Parado em $INTEG sem push. Corre a opção 2 outra vez para acabar."; return; }
  done
  outros=$(git status --porcelain -uno | grep -v ' Docs/CHANGELOG\.md$')
  [ -n "$outros" ] && { erro "Recusado: neste passo só o Docs/CHANGELOG.md pode mudar."; echo "$outros"; return; }
  if [ -n "$(git status --porcelain Docs/CHANGELOG.md)" ]; then
    git add Docs/CHANGELOG.md && git commit -q -m "update: Docs/CHANGELOG.md" || return
  fi
  git push origin "$INTEG" ||
    { erro "Push recusado (alguém enviou entretanto?). Corre a opção 2 outra vez. Nunca --force."; return; }
  ok "$MINHA entrou em $INTEG e o push está feito."
  git checkout -q "$MINHA"
}

actualizar() {
  ir_para_minha || return
  git fetch -q origin "$ORIGEM" && git merge --no-edit "origin/$ORIGEM" &&
    ok "$MINHA actualizada com $ORIGEM. O push faz-se na opção 1." ||
    erro "Merge falhou. Se há conflitos: resolve, git add + git commit, e volta ao menu."
}

abrir() {
  echo "Abrir no browser: $1"
  if [ "$SO" = macOS ]; then open "$1"; else start "$1" 2>/dev/null || explorer.exe "$1"; fi
}

pr_integ() {
  [ -n "$(git status --porcelain)" ] && echo "⚠ Alterações por commitar não vão no PR (opção 1 primeiro)."
  git push -u origin "$MINHA" || return
  [ "$(n "origin/$INTEG" "origin/$MINHA")" = 0 ] && { ok "$INTEG já tem tudo o que está em $MINHA: PR vazio, não abro."; return; }
  abrir "$URL/compare/$INTEG...$MINHA?expand=1"
}

pr_rel() {
  case $(n "origin/$INTEG" "$INTEG") in 0|\?) ;; *) echo "⚠ $INTEG no teu PC tem commits que o GitHub não tem: o PR usa origin/$INTEG." ;; esac
  [ "$(n "origin/$REL" "origin/$INTEG")" = 0 ] && { ok "$REL já tem tudo o que está em $INTEG."; return; }
  abrir "$URL/compare/$REL...$INTEG?expand=1"
  echo "O merge do PR fazes tu, no GitHub."
}

# Docs/TODO.md "Como escolher uma tarefa": pull dev · 🔒 no TODO + ID no README · um só commit
# · push dev · merge dev → tua branch. Vai directo para dev: o trabalho a meio na tua branch fica lá.
RESERVA="update: Docs/TODO.md, README.md"
reservar() {
  local lista pedidos id est novos='' recusa='' pend
  [ -n "$(git status --porcelain -uno)" ] &&
    { erro "Tens alterações por commitar. A reserva é um commit só com Docs/TODO.md + README.md: opção 1 primeiro."; return; }
  git checkout -q "$INTEG" || return
  git pull --no-rebase origin "$INTEG" ||
    { erro "Conflitos no pull de $INTEG: resolve, git add + git commit, e volta à opção 6."; return; }
  # por enviar em INTEG só podem estar reservas que ficaram a meio (Enter sem IDs envia-as)
  pend=$(git log --no-merges --format=%s "origin/$INTEG..$INTEG" | grep -vxF "$RESERVA")
  [ -n "$pend" ] && { erro "A $INTEG no teu PC tem commits por enviar que não são reservas: acaba primeiro a opção 2."; git checkout -q "$MINHA"; return; }

  lista=$(tarefas < Docs/TODO.md)
  echo "Tarefas livres no Docs/TODO.md:"
  printf '%s\n' "$lista" | awk -F'|' '$4 == "⬜ livre" { printf "  %-3s %s · pacote %s\n", $1, $2, $3 }'
  echo "Tuas no README.md: $(tarefas_readme < README.md)"
  read -r -p "IDs a reservar (ex. A1 A2 · letra sozinha = pacote inteiro · Enter = nenhum): " pedidos
  for id in $(printf '%s\n' "$lista" | awk -F'|' -v q="$pedidos" '
      BEGIN { k = split(toupper(q), w, /[ ,]+/) }
      { for (i = 1; i <= k; i++) if (w[i] != "" && (w[i] == $1 || w[i] == $3)) { print $1; achou[i] = 1 } }
      END { for (i = 1; i <= k; i++) if (w[i] != "" && !achou[i]) print "?" w[i] }' | sort -u); do
    case "$id" in \?*) recusa="$recusa ${id#?} (não existe)"; continue ;; esac
    est=$(printf '%s\n' "$lista" | awk -F'|' -v i="$id" '$1 == i { print $4 }')
    case "$est" in
      "⬜ livre")    novos="$novos $id" ;;
      "🔒 $PESSOA") echo "  $id já é tua." ;;
      *)            recusa="$recusa $id ($est)" ;;
    esac
  done
  if [ -n "$recusa" ]; then
    erro "Recusado:$recusa. CLAUDE.md: tarefa com dono (🔒) ou acabada (✅) não se reserva."
    git checkout -q "$MINHA"; return
  fi

  if [ -n "$novos" ]; then
    awk -F'|' -v OFS='|' -v ids="$novos " -v p="$PESSOA" "$AWK_LIB"'
      /^\| *ID *\| *Tarefa *\| *Pacote *\| *Estado *\|/ { t = 1 }
      t && !/^\|/ { t = 0 }
      t && index(ids, " " trim($2) " ") { $5 = " 🔒 " p " " }
      { print }' Docs/TODO.md > Docs/TODO.md.tmp && mv Docs/TODO.md.tmp Docs/TODO.md
    # shellcheck disable=SC2086 # $novos partido de propósito: " A1 A2" → "A1, A2"
    awk -F'|' -v OFS='|' -v b="$MINHA" -v ids="$(echo $novos | sed 's/ /, /g')" "$AWK_LIB"'
      /^\| *Nome *\| *GitHub *\| *Branch *\| *Tarefas *\|/ { t = 1 }
      t && !/^\|/ { t = 0 }
      t && tick($4) == b { c = trim($5); $5 = " " (c == "" || c == "—" ? ids : c ", " ids) " " }
      { print }' README.md > README.md.tmp && mv README.md.tmp README.md
    if git diff --quiet -- Docs/TODO.md || git diff --quiet -- README.md; then
      erro "Não consegui marcar no TODO e no README (tabelas mudaram?). Nada reservado."
      git checkout -q -- Docs/TODO.md README.md; git checkout -q "$MINHA"; return
    fi
    git --no-pager diff -- Docs/TODO.md README.md
    if ! confirmar "Reservar$novos para $PESSOA (commit \"$RESERVA\" + push $INTEG)?"; then
      git checkout -q -- Docs/TODO.md README.md; git checkout -q "$MINHA"; echo "Nada reservado."; return
    fi
    git add Docs/TODO.md README.md && git commit -q -m "$RESERVA" || return
  fi
  if [ "$(n "origin/$INTEG" "$INTEG")" = 0 ]; then echo "Nada para reservar."; git checkout -q "$MINHA"; return; fi
  git push origin "$INTEG" || { git pull --no-rebase origin "$INTEG" && git push origin "$INTEG"; } || {
    erro "Push recusado (alguém enviou entretanto?). A reserva ficou só no teu PC, em $INTEG."
    echo "  Se há conflitos: resolve, git add + git commit. Depois opção 6 com Enter sem IDs para a enviar."
    return
  }
  ok "Reserva enviada para origin/$INTEG."
  git checkout -q "$MINHA" && git merge --no-edit "$INTEG" && ok "$MINHA actualizada com $INTEG: podes começar." ||
    erro "Merge $INTEG → $MINHA com conflitos: resolve, git add + git commit."
}

# --- menu --------------------------------------------------------------------
opcao() {   # $1 tecla · $2 acção · $3 título · $4 o que faz
  if pode "$2"; then printf ' %s) %s\n      %s\n' "$1" "$3" "$4"
  else printf ' ✖  %s\n      recusado: %s\n' "$3" "$MOTIVO"; fi
}

aviso_branch() {
  local dono; dono=$(campo "$ATUAL" 2)
  if [ "$ATUAL" = "$MINHA" ]; then echo "         ✔ estás na tua branch"
  elif [ -z "$dono" ]; then echo "         ⚠ '${ATUAL:-HEAD solto}' não está no Docs/BRANCH.md · b) volta para $MINHA"
  elif [ "$dono" != todos ] && [ "$dono" != "$PESSOA" ]; then echo "         ✖ $ATUAL é do $dono: não commits nem push aqui · b) volta para $MINHA"
  elif ! contem "$LIVRE" "$ATUAL"; then echo "         ✖ $ATUAL: sem commit nem push directo (CLAUDE.md) · b) volta para $MINHA"
  else echo "         ⚠ commits só na $MINHA: as opções 1 e 3 fazem checkout para lá"; fi
}

bloqueados() {   # branches fora da tua lista de push no CLAUDE.md
  printf '%s\n' "$BRANCHES" | while IFS='|' read -r b dono _; do
    contem "$LIVRE" "$b" && continue
    de=$(printf '%s\n' "$BRANCHES" | awk -F'|' -v b="$b" '$4 == b { printf "%s%s", s, $1; s = ", " }')
    if [ -n "$de" ]; then echo " ✖  push $b — fora da tua lista de push (CLAUDE.md) · $b só recebe merge de $de, por PR"
    elif [ "$dono" != "$PESSOA" ]; then echo " ✖  push $b — branch do $dono"
    else echo " ✖  push $b — fora da tua lista de push (CLAUDE.md)"; fi
  done
}

menu() {
  ATUAL=$(git branch --show-current)
  echo
  echo "═══════════════════════════════════════════════════════════════════"
  echo " AgroGest · git · regras do CLAUDE.md + Docs/BRANCH.md ($REGRAS)"
  echo " Quem    $PESSOA · $NOME · $SO"
  echo " Branch  tua: $MINHA · estás em: ${ATUAL:-HEAD solto}"
  aviso_branch
  echo " Estado  $(git status --porcelain | wc -l | tr -d ' ') ficheiro(s) por commitar"
  echo "         $MINHA → origin/$MINHA : $(n "origin/$MINHA" "$MINHA") commit(s) por enviar"
  echo "         $MINHA → $INTEG : $(n "origin/$INTEG" "$MINHA") commit(s) que $INTEG ainda não tem"
  echo "         $INTEG → $MINHA : $(n "$MINHA" "origin/$INTEG") commit(s) novos em $INTEG por trazer"
  [ -n "$REL" ] && echo "         $INTEG → $REL : $(n "origin/$REL" "origin/$INTEG") commit(s) que $REL ainda não tem"
  echo "── PUSH · enviar commits para o GitHub ────────────────────────────"
  opcao 1 commit "commit + push $MINHA" "escolhes ficheiros → commit create:/update:/delete: → push origin/$MINHA"
  opcao 2 enviar "enviar $MINHA → $INTEG (ordem obrigatória do CLAUDE.md)" \
    "push $MINHA → pull $INTEG → merge $MINHA em $INTEG → CHANGELOG.md → push origin/$INTEG"
  bloqueados
  echo "── MERGE · juntar branches no teu PC ──────────────────────────────"
  opcao 3 actualizar "actualizar $MINHA com $ORIGEM" "merge origin/$ORIGEM → $MINHA: traz o que já está em $ORIGEM"
  echo "    merge $MINHA → $INTEG: é a opção 2"
  if [ -n "$REL" ] && ! contem "$LIVRE" "$REL"; then
    if pode pr_rel; then via="opção 5"; else via="feito por $REL_SO"; fi
    echo " ✖  merge $INTEG → $REL no PC — obrigava a push para $REL · só por PR ($via)"
  fi
  echo "── PULL REQUEST · abre o GitHub no browser ────────────────────────"
  opcao 4 pr_integ "PR $MINHA → $INTEG" "push $MINHA → abre \"Create pull request\" (base $INTEG ← $MINHA)"
  [ -n "$REL" ] && opcao 5 pr_rel "PR $INTEG → $REL" "abre o PR (base $REL ← $INTEG) · o merge fazes tu no GitHub"
  echo "── TAREFA · Docs/TODO.md + README.md ──────────────────────────────"
  opcao 6 reservar "reservar tarefa → push directo para $INTEG (sem levar a $MINHA)" \
    "pull $INTEG → 🔒 $PESSOA no TODO + ID no README → um commit → push $INTEG → merge $INTEG em $MINHA"
  if pode reservar; then
    todo=$(git show "$REGRAS:Docs/TODO.md" | tarefas)
    livres=$(printf '%s\n' "$todo" | awk -F'|' '$4 == "⬜ livre" { printf "%s%s", s, $1; s = " " }')
    tuas=$(printf '%s\n' "$todo" | awk -F'|' -v p="$PESSOA" '$4 == "🔒 " p || $4 == "✅ " p { printf "%s%s", s, $1; s = " " }')
    readme=$(git show "$REGRAS:README.md" | tarefas_readme | tr -d ','); [ "$readme" = "—" ] && readme=
    echo "      tuas: ${tuas:-nenhuma} · livres: ${livres:-nenhuma}"
    # shellcheck disable=SC2086 # listas partidas de propósito para comparar
    [ "$(printf '%s\n' $tuas | sort)" = "$(printf '%s\n' $readme | sort)" ] ||
      echo "      ⚠ TODO (${tuas:-—}) e README (${readme:-—}) não batem: CLAUDE.md manda corrigir antes de escrever código"
  fi
  echo "───────────────────────────────────────────────────────────────────"
  echo " s) git status · b) ir para $MINHA · 0) sair"
  echo " ✖ = fora das regras: o script recusa, mesmo que escrevas a tecla"
}

faz() { if pode "$1"; then "$1"; else erro "Recusado: $MOTIVO"; fi; }

principal() {
  while true; do
    menu
    read -r -p "> " op || exit 0
    case "$op" in
      1) faz commit ;;
      2) faz enviar ;;
      3) faz actualizar ;;
      4) faz pr_integ ;;
      5) faz pr_rel ;;
      6) faz reservar ;;
      s|S) git status ;;
      b|B) ir_para_minha ;;
      0) exit 0 ;;
      *) erro "Opção inválida." ;;
    esac
    git fetch -q origin 2>/dev/null
  done
}
principal; exit
