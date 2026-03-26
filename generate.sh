#!/usr/bin/env zsh
# generate.sh — Interactive CV generator
# Pick sections from bank/snippets/ using fzf, assemble a targeted .tex / PDF.

BANK="${0:A:h}/bank"
SNIPPETS="$BANK/snippets"
TEMPLATES="$BANK/templates"

# ── Colors ─────────────────────────────────────────────────────────────────────
BOLD=$'\033[1m'; DIM=$'\033[2m'; NC=$'\033[0m'
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'
BLUE=$'\033[34m'; CYAN=$'\033[36m'

# ── Utilities ──────────────────────────────────────────────────────────────────

check_dep() {
  if ! command -v "$1" &>/dev/null; then
    echo "  ${RED}Error:${NC} $1 is required — install: $2" && exit 1
  fi
}

ok()   { printf "  ${GREEN}✓${NC}  %s\n" "$*"; }
info() { printf "  ${BLUE}→${NC}  %s\n" "$*"; }
warn() { printf "  ${YELLOW}⚠${NC}  %s\n" "$*" >&2; }

spinner() {
  local msg="$1" pid="$2"
  local -a F=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  tput civis 2>/dev/null
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}%s${NC}  %s  " "${F[$((i % 10 + 1))]}" "$msg"
    sleep 0.08
    i=$(( i + 1 ))
  done
  tput cnorm 2>/dev/null
  wait "$pid" 2>/dev/null
  local rc=$?
  if (( rc == 0 )); then
    printf "\r  ${GREEN}✓${NC}  %s      \n" "$msg"
  else
    printf "\r  ${RED}✗${NC}  %s failed\n" "$msg"
    return $rc
  fi
}

section_hdr() {
  echo ""
  printf "${CYAN}${BOLD}  %s${NC}\n" "$1"
  printf "${DIM}  ──────────────────────────────────────${NC}\n"
}

pick() {
  local dir="$1" prompt="$2" mode="${3:-single}"
  local -a files
  while IFS= read -r f; do
    files+=("$(basename "$f" .tex)")
  done < <(find "$dir" -name "*.tex" | sort)
  (( ${#files[@]} == 0 )) && return

  # Use bat for syntax-highlighted preview if available, fall back to cat
  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="bat --color=always --language=tex --style=plain '${dir}/{}.tex' 2>/dev/null"
  else
    preview_cmd="cat '${dir}/{}.tex' 2>/dev/null"
  fi

  local -a opts=(
    --height=80% --border=rounded --ansi
    --prompt="  ${prompt} › "
    --pointer="▸" --marker="●"
    --color="prompt:cyan,pointer:cyan,marker:green,border:blue,header:yellow"
    --preview="$preview_cmd"
    --preview-window="right:55%:wrap:hidden"
    --bind="right:toggle-preview,left:toggle-preview"
  )
  if [[ "$mode" == "multi" ]]; then
    opts+=(--multi --bind="tab:toggle"
           --header="  TAB select  ·  ENTER confirm  ·  → preview  ·  ESC skip")
  else
    opts+=(--header="  ENTER select  ·  → preview  ·  ESC skip")
  fi

  printf '%s\n' "${files[@]}" | fzf "${opts[@]}" || true
}

append_section() {
  local title="$1" dir="$2"; shift 2
  local -a items=("$@")
  local wrote=false

  for item in "${items[@]}"; do
    [[ -z "$item" ]] && continue
    local f="$dir/$item.tex"
    if [[ ! -f "$f" ]]; then warn "Missing snippet: $item"; continue; fi
    if [[ "$wrote" == "false" ]]; then
      printf '\n\\section{%s}\n' "$title" >> "$OUTPUT"
      wrote=true
    else
      printf '\n\\vspace{4pt}\n' >> "$OUTPUT"
    fi
    cat "$f" >> "$OUTPUT"
  done
  [[ "$wrote" == "true" ]] && printf '\n\\vspace{2pt}\n' >> "$OUTPUT"
}

_count() {
  local c=0
  for x in "$@"; do [[ -n "$x" ]] && c=$(( c + 1 )); done
  echo $c
}

# ── Banner ─────────────────────────────────────────────────────────────────────

clear
echo ""
printf "${BOLD}${BLUE}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       CV Generator — Resume Bank       ║"
echo "  ╚═══════════════════════════════════════╝"
printf "${NC}\n"
info "TAB multi-select  ·  ENTER confirm  ·  ESC skip section"
echo ""

check_dep fzf "brew install fzf"

# ── Output name ────────────────────────────────────────────────────────────────

printf "  ${BOLD}Output filename${NC} ${DIM}(without .tex)${NC} [jaspermayone-cv-custom]: "
read -r OUT_NAME
OUT_NAME="${OUT_NAME:-jaspermayone-cv-custom}"
OUTPUT="${PWD}/$OUT_NAME.tex"

# ── Section selections ─────────────────────────────────────────────────────────

section_hdr "Education"
EDU=("${(@f)$(pick "$SNIPPETS/education" "Education" "multi")}")

section_hdr "Skills"
SKILLS=("${(@f)$(pick "$SNIPPETS/skills" "Skills" "multi")}")

section_hdr "Experience"
EXP=("${(@f)$(pick "$SNIPPETS/experience" "Experience" "multi")}")

section_hdr "Projects"
PROJ=("${(@f)$(pick "$SNIPPETS/projects" "Projects" "multi")}")

section_hdr "Activities"
ACT=("${(@f)$(pick "$SNIPPETS/activities" "Activities" "multi")}")

# ── Summary ────────────────────────────────────────────────────────────────────

echo ""
printf "${BOLD}${BLUE}  ──────────────────── Summary ─────────────────────${NC}\n"
(( $(_count "${EDU[@]}") > 0 ))  && printf "  ${GREEN}Education:${NC}   $(_count "${EDU[@]}") selected\n"
(( $(_count "${SKILLS[@]}") > 0 )) && printf "  ${GREEN}Skills:${NC}      $(_count "${SKILLS[@]}") selected\n"
(( $(_count "${EXP[@]}") > 0 ))  && printf "  ${GREEN}Experience:${NC}  $(_count "${EXP[@]}") selected\n"
(( $(_count "${PROJ[@]}") > 0 )) && printf "  ${GREEN}Projects:${NC}    $(_count "${PROJ[@]}") selected\n"
(( $(_count "${ACT[@]}") > 0 ))  && printf "  ${GREEN}Activities:${NC}  $(_count "${ACT[@]}") selected\n"
printf "${BOLD}${BLUE}  ───────────────────────────────────────────────────${NC}\n"
echo ""

printf "  Write to ${CYAN}${BOLD}%s.tex${NC}? [Y/n]: " "$OUT_NAME"
read -r CONFIRM
[[ "${CONFIRM:l}" == "n" ]] && { echo "  Aborted."; exit 0; }
echo ""

# ── Assemble ───────────────────────────────────────────────────────────────────

printf "  ${CYAN}⠿${NC}  Assembling …"

cat "$TEMPLATES/header.tex" > "$OUTPUT"

append_section "Education"  "$SNIPPETS/education"  "${EDU[@]:-}"

append_section "Skills" "$SNIPPETS/skills" "${SKILLS[@]:-}"

append_section "Projects"   "$SNIPPETS/projects"   "${PROJ[@]:-}"
append_section "Experience" "$SNIPPETS/experience" "${EXP[@]:-}"
append_section "Activities" "$SNIPPETS/activities" "${ACT[@]:-}"

cat "$TEMPLATES/footer.tex" >> "$OUTPUT"

printf "\r  ${GREEN}✓${NC}  Assembled ${CYAN}%s.tex${NC}      \n" "$OUT_NAME"

# ── Compile ────────────────────────────────────────────────────────────────────

if command -v latexmk &>/dev/null; then
  echo ""
  printf "  Compile to PDF now? [y/N]: "
  read -r COMPILE
  if [[ "${COMPILE:l}" == "y" ]]; then
    echo ""
    latexmk -pdf -quiet -interaction=nonstopmode "$OUTPUT" &>/tmp/latexmk_cv.log &
    spinner "Compiling PDF" $!
    if [[ -f "${OUTPUT:r}.pdf" ]]; then
      ok "PDF ready: ${CYAN}${OUTPUT:r}.pdf${NC}"
      # Page count check
      if command -v pdfinfo &>/dev/null; then
        local PAGES
        PAGES=$(pdfinfo "${OUTPUT:r}.pdf" 2>/dev/null | grep -m1 "^Pages:" | awk '{print $2}')
        if [[ -n "$PAGES" && "$PAGES" -gt 1 ]]; then
          echo ""
          printf "  ${YELLOW}⚠  CV is ${BOLD}${PAGES} pages${NC}${YELLOW} — consider trimming to fit one page${NC}\n"
        fi
      fi
    else
      warn "Compile error — see /tmp/latexmk_cv.log"
    fi
  fi
else
  info "Run ${CYAN}latexmk -pdf $OUT_NAME.tex${NC} to compile"
fi

echo ""
