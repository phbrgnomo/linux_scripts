#!/usr/bin/env bash
set -euo pipefail

# Sincroniza arquivos .md (stories) com issues no GitHub usando o `gh` CLI.
# Propósito: para cada arquivo .md em um diretório local, criar/atualizar uma
# issue correspondente no repositório remoto e inserir/atualizar o link da
# issue no final do arquivo local.
# Este script é interativo: pergunta pelo diretório contendo os arquivos .md.

DEFAULT_REPO="phbrgnomo/Analise-financeira-B3"
DEFAULT_DIR="docs/implementation-artifacts"

# Valores podem vir do ambiente ou de flags (veja abaixo)
REPO="${REPO:-$DEFAULT_REPO}"
DIR="${DIR:-}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI não encontrado. Autentique e instale gh antes de executar." >&2
  exit 1
fi

usage() {
  cat <<EOF
Uso: $0 [OPÇÕES]
  -r, --repo REPO    Repositório destino (ex: owner/repo). Pode vir também da var REPO
  -d, --dir DIR      Diretório com arquivos .md. Pode vir também da var DIR
  -y, --yes          Não interativo (usa valores padrão/fornecidos)
  -h, --help         Mostrar esta ajuda
EOF
}

# Parse args simples (suporta long opts)
NONINTERACTIVE=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    -r|--repo)
      REPO="$2"
      shift 2
      ;;
    -d|--dir)
      DIR="$2"
      shift 2
      ;;
    -y|--yes)
      NONINTERACTIVE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

# Se DIR não veio por env/flag, perguntar (salvo modo non-interactive)
if [ -z "${DIR:-}" ]; then
  if [ "$NONINTERACTIVE" -eq 1 ]; then
    DIR="$DEFAULT_DIR"
  else
    printf "Diretório com arquivos .md para sincronizar (padrão: %s): " "$DEFAULT_DIR"
    read -r DIR_INPUT
    DIR="${DIR_INPUT:-$DEFAULT_DIR}"
  fi
fi

# Se REPO não definido, usar padrão
REPO="${REPO:-$DEFAULT_REPO}"

if [ ! -d "$DIR" ]; then
  echo "Diretório '$DIR' não encontrado. Verifique o caminho e tente novamente." >&2
  exit 1
fi

echo "Iniciando sincronização de issues para $DIR -> $REPO"

# arquivo temporário para registrar issues encontradas fechadas
CLOSED_TMP=$(mktemp)
: > "$CLOSED_TMP"

# garantir cleanup do temp file em qualquer saída
cleanup() {
  rm -f "${CLOSED_TMP:-}"
}
trap cleanup EXIT

for f in "$DIR"/*.md; do
  [ -e "$f" ] || continue
  printf '\nProcessando: %s\n' "$f"

  # usar o nome do arquivo como título do issue: <epic>-<story>-<nome-do-issue>
  issue_title=$(basename "$f" .md)
  echo "Issue title: $issue_title"

  issue_number=""
  issue_url=""

  # 1) procurar issue existente com título exato via GitHub Search API (usando o nome do arquivo)
  search_issue_by_title() {
    local T="$1"
    local sj
    sj=$(gh api -X GET /search/issues -f q="repo:$REPO in:title \"$T\"" 2>/dev/null || true)
    if [ -n "$sj" ]; then
      printf '%s' "$sj" | TITLE="$T" python3 -c '
  import sys, json, os
  txt = sys.stdin.read()
  try:
    j = json.loads(txt)
  except Exception:
    sys.exit(1)
  T = os.environ.get("TITLE", "")
  for it in j.get("items", []):
    if it.get("title", "") == T:
      # output: number\thtml_url\tstate
      print(str(it.get("number")) + "\t" + it.get("html_url", "") + "\t" + it.get("state", ""))
      sys.exit(0)
  sys.exit(1)
  '
    fi
  }

  match=$(search_issue_by_title "$issue_title" ) || true
  if [ -n "$match" ]; then
    issue_number=$(echo "$match" | cut -f1)
    issue_url=$(echo "$match" | cut -f2)
    issue_state=$(echo "$match" | cut -f3)
  fi

  # 2) se não existir, criar e capturar o URL retornado pelo gh
  if [ -z "$issue_number" ]; then
    echo "Issue não encontrada — criando..."
    create_out=$(gh issue create --repo "$REPO" --title "$issue_title" --body-file "$f" 2>/dev/null || true)
    # extrair URL da saída (linha contendo .../issues/N)
    issue_url=$(printf '%s' "$create_out" | grep -Eo 'https://github.com/[^ ]+/issues/[0-9]+' | head -n1 || true)
    if [ -n "$issue_url" ]; then
      issue_number=$(basename "$issue_url")
      issue_state="open"
      echo "Criada: $issue_url (#$issue_number)"
    else
      # fallback: procurar novamente via search e extrair correspondência exata
      echo "Aviso: não consegui capturar URL da criação; buscando por título..."
      match2=$(search_issue_by_title "$issue_title" ) || true
      if [ -n "$match2" ]; then
        issue_number=$(echo "$match2" | cut -f1)
        issue_url=$(echo "$match2" | cut -f2)
        issue_state=$(echo "$match2" | cut -f3)
        echo "Encontrada após criação: $issue_url (#$issue_number) state=$issue_state"
      fi
    fi
  else
    # se encontrou issue remota inicialmente, verificar estado (se não veio no search)
    if [ -z "${issue_state:-}" ]; then
      issue_state=$(gh issue view "$issue_number" --repo "$REPO" --json state -q .state 2>/dev/null || true)
    fi
    if [ "$issue_state" = "closed" ]; then
      echo "Issue #$issue_number está fechada — adiando ação até o fim"
      printf "%s||%s||%s\n" "$issue_number" "$issue_url" "$f" >> "$CLOSED_TMP"
    else
      echo "Issue encontrada e aberta: #$issue_number — atualizando corpo..."
      gh issue edit "$issue_number" --repo "$REPO" --body-file "$f" >/dev/null 2>&1 || true
      if [ -z "$issue_url" ]; then
        issue_url="https://github.com/$REPO/issues/$issue_number"
      fi
      echo "Atualizada: $issue_url (#$issue_number)"
    fi
  fi

  if [ -z "$issue_url" ]; then
    echo "Aviso: não foi possível determinar URL da issue para '$issue_title'" >&2
    continue
  fi

  # inserir ou atualizar linha Issue: <url> no final do arquivo
  if grep -qE '^Issue:\s*https?://' "$f"; then
    sed -i "0,/^Issue:\s*https?:\/\//s|^Issue:.*|Issue: $issue_url|" "$f"
    echo "Link da issue atualizado no arquivo."
  else
    printf "\nIssue: %s\n" "$issue_url" >> "$f"
    echo "Link da issue adicionado ao final do arquivo."
  fi
done

echo "Sincronização concluída."

# Se houver correspondências fechadas coletadas, oferecer opção interativo ao usuário
if [ -s "$CLOSED_TMP" ]; then
  printf '\nForam encontradas issues remotas que estão fechadas e têm correspondência com arquivos locais:\n'
  i=0
  while IFS= read -r l; do
    i=$((i+1))
    num=${l%%||*}
    rest=${l#*||}
    url=${rest%%||*}
    file=${rest#*||}
    echo "[$i] Issue #$num — $url  -> arquivo: $file"
  done < "$CLOSED_TMP"

  printf '\nEscolha a ação para todas as issues fechadas listadas:\n'
  echo "  r) Reabrir e atualizar com o conteúdo local"
  echo "  n) Criar nova issue para cada arquivo (mantendo as remotas fechadas)"
  echo "  k) Manter fechadas (nenhuma ação)"
  printf "Escolha [r/n/k]: "
  read -r action_choice

  case "$action_choice" in
    r)
      echo "Reabrindo e atualizando issues..."
      while IFS= read -r l; do
        num=${l%%||*}
        rest=${l#*||}
        url=${rest%%||*}
        file=${rest#*||}
        echo "Reabrindo #$num and atualizando corpo..."
        gh issue reopen "$num" --repo "$REPO" >/dev/null 2>&1 || true
        gh issue edit "$num" --repo "$REPO" --body-file "$file" >/dev/null 2>&1 || true
        echo "Atualizada: https://github.com/$REPO/issues/$num (#$num)"
      done < "$CLOSED_TMP"
      ;;
    n)
      echo "Criando novas issues..."
      while IFS= read -r l; do
        num=${l%%||*}
        rest=${l#*||}
        url=${rest%%||*}
        file=${rest#*||}
        title=$(basename "$file" .md)
        new_out=$(gh issue create --repo "$REPO" --title "$title (reopened)" --body-file "$file" 2>/dev/null || true)
        new_url=$(printf '%s' "$new_out" | grep -Eo 'https://github.com/[^ ]+/issues/[0-9]+' | head -n1 || true)
        if [ -n "$new_url" ]; then
          # Atualiza a primeira linha "Issue:" existente (se houver) em vez de acumular
          if grep -qE '^Issue:\s*https?://' "$file"; then
            sed -i "0,/^Issue:\s*https?:\/\//s|^Issue:.*|Issue: $new_url|" "$file"
          else
            printf "\nIssue: %s\n" "$new_url" >> "$file"
          fi
          echo "Criada: $new_url for $file"
        else
          echo "Falha ao criar nova issue para $file" >&2
        fi
      done < "$CLOSED_TMP"
      ;;
    *)
      echo "Nenhuma ação tomada para issues fechadas."
      ;;
  esac

  rm -f "$CLOSED_TMP"
fi
