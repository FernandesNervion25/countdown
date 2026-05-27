#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
#  GENERADOR DE STORIES — cuenta atrás escolar
#  Uso: bash generar_stories.sh
#  Genera: stories/story_1_fin.png  story_2_eval.png  story_3_clases.png
# ═══════════════════════════════════════════════════════

# ───────────────────────────────────────────────────────
#  CONFIG
# ───────────────────────────────────────────────────────

DATE_A="2026-06-17"
DATE_B="2026-06-22"

CUTOFF_HOUR=14
CUTOFF_MIN=45

HOLIDAYS=(
  "2026-06-04"
)

SCHEDULE=(
  "1:EF,Inglés,Geografía,Biología,Francés,Lengua"
  "2:Biología,Inglés,Geografía,Mates,Lengua,EF"
  "3:Música,Inglés,Computación,Lengua,Mates,Francés"
  "4:Plástica,Lengua,Mates,EF,Geografía,Tutoría"
  "5:Biología,Inglés,Computación,Mates,Música,Alternativa"
)

SUBJECT_ORDER=(
  "Inglés" "Lengua" "Mates" "Biología" "Geografía"
  "Francés" "Computación" "Música" "EF" "Plástica"
  "Tutoría" "Alternativa"
)

OUTPUT_DIR="$(pwd)/stories"
mkdir -p "$OUTPUT_DIR"

# ───────────────────────────────────────────────────────
#  LÓGICA
# ───────────────────────────────────────────────────────

declare -A HOLIDAY_SET
for h in "${HOLIDAYS[@]}"; do HOLIDAY_SET["$h"]=1; done

declare -A DAY_SCHEDULE
for entry in "${SCHEDULE[@]}"; do
  DAY_SCHEDULE["${entry%%:*}"]="${entry#*:}"
done

NOW_HOUR=$(date +%-H)
NOW_MIN=$(date +%-M)

if (( NOW_HOUR > CUTOFF_HOUR || (NOW_HOUR == CUTOFF_HOUR && NOW_MIN >= CUTOFF_MIN) )); then
  START=$(date -d "tomorrow" +%Y-%m-%d)
else
  START=$(date +%Y-%m-%d)
fi

count_between() {
  local from="$1" to="$2"
  local -n _days="$3" _counts="$4"
  _days=0
  local cur="$from"
  while [[ "$cur" < "$to" || "$cur" == "$to" ]]; do
    local dow=$(date -d "$cur" +%u)
    local is_hol=${HOLIDAY_SET["$cur"]:-0}
    if (( dow < 6 )) && [[ "$is_hol" != "1" ]]; then
      (( _days++ ))
      IFS=',' read -ra cls <<< "${DAY_SCHEDULE[$dow]:-}"
      for c in "${cls[@]}"; do _counts["$c"]=$(( ${_counts["$c"]:-0} + 1 )); done
    fi
    cur=$(date -d "$cur + 1 day" +%Y-%m-%d)
  done
}

declare -A COUNTS_A
count_between "$START" "$DATE_A" DAYS_A COUNTS_A

DATE_A_NEXT=$(date -d "$DATE_A + 1 day" +%Y-%m-%d)
declare -A COUNTS_EXTRA
count_between "$DATE_A_NEXT" "$DATE_B" DAYS_EXTRA COUNTS_EXTRA

DAYS_B=$(( DAYS_A + DAYS_EXTRA ))

DATE_B_NICE=$(LC_TIME=es_ES.UTF-8 date -d "$DATE_B" '+%d de %B de %Y')
DATE_A_NICE=$(LC_TIME=es_ES.UTF-8 date -d "$DATE_A" '+%d de %B de %Y')
TODAY_NICE=$(LC_TIME=es_ES.UTF-8 date '+%d de %B, %Y' | sed 's/./\u&/')

# ───────────────────────────────────────────────────────
#  CSS COMPARTIDO
# ───────────────────────────────────────────────────────

CSS='
* { margin: 0; padding: 0; box-sizing: border-box; }

:root {
  --beige:   #F0EAE0;
  --beige-2: #E2D9CC;
  --beige-3: #C8BFB0;
  --ink:     #191714;
  --ink-2:   #3A3730;
  --ink-3:   #7A7468;
}

html, body {
  width: 1080px;
  height: 1920px;
  background: var(--beige);
  overflow: hidden;
  font-family: "Poppins", sans-serif;
  color: var(--ink);
}

.page {
  width: 1080px;
  height: 1920px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  padding: 100px;
}

/* grid sutil de fondo */
.page::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(var(--beige-2) 1px, transparent 1px),
    linear-gradient(90deg, var(--beige-2) 1px, transparent 1px);
  background-size: 54px 54px;
  opacity: 0.6;
  pointer-events: none;
}

/* esquinas decorativas */
.c { position: absolute; width: 56px; height: 56px; border: 1.5px solid var(--beige-3); }
.c-tl { top: 64px; left: 64px; border-right: none; border-bottom: none; }
.c-tr { top: 64px; right: 64px; border-left: none; border-bottom: none; }
.c-bl { bottom: 64px; left: 64px; border-right: none; border-top: none; }
.c-br { bottom: 64px; right: 64px; border-left: none; border-top: none; }

/* número gigante */
.big {
  font-family: "Lora", serif;
  font-size: 380px;
  font-weight: 700;
  line-height: 0.82;
  letter-spacing: -0.05em;
  color: var(--ink);
  position: relative;
  z-index: 1;
}

/* sombra de número decorativa */
.big-shadow {
  font-family: "Lora", serif;
  font-size: 380px;
  font-weight: 700;
  line-height: 0.82;
  letter-spacing: -0.05em;
  color: transparent;
  -webkit-text-stroke: 1.5px var(--beige-3);
  position: absolute;
  top: 18px;
  left: 18px;
  z-index: 0;
}

.number-wrap {
  position: relative;
  display: inline-block;
  margin-bottom: 8px;
}

.eyebrow {
  font-family: "Poppins", sans-serif;
  font-size: 22px;
  font-weight: 500;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--ink-3);
  margin-bottom: 52px;
  position: relative;
  z-index: 1;
}

.unit {
  font-family: "Poppins", sans-serif;
  font-size: 26px;
  font-weight: 300;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--ink-2);
  margin-top: 40px;
  position: relative;
  z-index: 1;
}

.rule {
  width: 64px;
  height: 1.5px;
  background: var(--ink-3);
  margin: 60px auto;
  position: relative;
  z-index: 1;
}

.footnote {
  font-family: "Poppins", sans-serif;
  font-size: 24px;
  font-weight: 400;
  color: var(--ink-3);
  letter-spacing: 0.04em;
  text-align: center;
  line-height: 1.6;
  position: relative;
  z-index: 1;
}

.today {
  position: absolute;
  bottom: 100px;
  left: 0; right: 0;
  text-align: center;
  font-family: "Poppins", sans-serif;
  font-size: 20px;
  font-weight: 300;
  color: var(--beige-3);
  letter-spacing: 0.12em;
  text-transform: uppercase;
  z-index: 1;
}

/* ── story 3 ── */
.s3-page {
  justify-content: flex-start;
  padding-top: 130px;
}

.s3-head {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding-bottom: 36px;
  border-bottom: 1.5px solid var(--ink);
  margin-bottom: 12px;
  position: relative;
  z-index: 1;
}

.s3-title {
  font-family: "Lora", serif;
  font-size: 76px;
  font-weight: 700;
  line-height: 0.95;
  letter-spacing: -0.02em;
}

.s3-sub {
  font-family: "Poppins", sans-serif;
  font-size: 21px;
  font-weight: 300;
  color: var(--ink-3);
  text-align: right;
  line-height: 1.7;
  letter-spacing: 0.03em;
}

table {
  width: 100%;
  border-collapse: collapse;
  position: relative;
  z-index: 1;
}

tr { border-bottom: 1px solid var(--beige-2); }
tr:last-child { border-bottom: none; }

td { padding: 20px 0; vertical-align: middle; }

.td-name {
  font-family: "Poppins", sans-serif;
  font-size: 28px;
  font-weight: 400;
  color: var(--ink-2);
  text-align: left;
}

.td-num {
  font-family: "Lora", serif;
  font-size: 48px;
  font-weight: 700;
  color: var(--ink);
  text-align: right;
  letter-spacing: -0.02em;
  width: 90px;
}

.td-extra {
  font-family: "Poppins", sans-serif;
  font-size: 22px;
  font-weight: 300;
  color: var(--beige-3);
  text-align: right;
  padding-left: 12px;
  white-space: nowrap;
  width: 80px;
}
'

# ───────────────────────────────────────────────────────
#  STORY 1 — Último día
# ───────────────────────────────────────────────────────

cat > /tmp/story1.html << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>${CSS}</style></head><body>
<div class="page">
  <div class="c c-tl"></div><div class="c c-tr"></div>
  <div class="c c-bl"></div><div class="c c-br"></div>

  <div class="eyebrow">último día</div>

  <div class="number-wrap">
    <div class="big-shadow">$(printf '%02d' $DAYS_B)</div>
    <div class="big">$(printf '%02d' $DAYS_B)</div>
  </div>

  <div class="unit">días laborables</div>
  <div class="rule"></div>
  <div class="footnote">${DATE_B_NICE}</div>

  <div class="today">${TODAY_NICE}</div>
</div>
</body></html>
HTML

# ───────────────────────────────────────────────────────
#  STORY 2 — Evaluaciones
# ───────────────────────────────────────────────────────

cat > /tmp/story2.html << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>${CSS}</style></head><body>
<div class="page">
  <div class="c c-tl"></div><div class="c c-tr"></div>
  <div class="c c-bl"></div><div class="c c-br"></div>

  <div class="eyebrow">evaluaciones</div>

  <div class="number-wrap">
    <div class="big-shadow">$(printf '%02d' $DAYS_A)</div>
    <div class="big">$(printf '%02d' $DAYS_A)</div>
  </div>

  <div class="unit">días laborables</div>
  <div class="rule"></div>
  <div class="footnote">${DATE_A_NICE}</div>

  <div class="today">${TODAY_NICE}</div>
</div>
</body></html>
HTML

# ───────────────────────────────────────────────────────
#  STORY 3 — Clases por asignatura
# ───────────────────────────────────────────────────────

ROWS=""
for s in "${SUBJECT_ORDER[@]}"; do
  va=$(printf '%02d' "${COUNTS_A[$s]:-0}")
  vb=$(printf '%02d' "${COUNTS_EXTRA[$s]:-0}")
  ROWS+="<tr>
    <td class='td-name'>${s}</td>
    <td class='td-num'>${va}</td>
    <td class='td-extra'>+${vb}</td>
  </tr>"
done

cat > /tmp/story3.html << HTML
<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>${CSS}</style></head><body>
<div class="page s3-page">
  <div class="c c-tl"></div><div class="c c-tr"></div>
  <div class="c c-bl"></div><div class="c c-br"></div>

  <div class="s3-head">
    <div class="s3-title">Clases<br>restantes</div>
    <div class="s3-sub">hasta eval. · +hasta fin<br>${DATE_A_NICE}</div>
  </div>

  <table>${ROWS}</table>

  <div class="today">${TODAY_NICE}</div>
</div>
</body></html>
HTML

# ───────────────────────────────────────────────────────
#  RENDER
# ───────────────────────────────────────────────────────

echo ""
echo "  Generando stories..."
echo ""

OPTS="--quiet --width 1080 --height 1920"

wkhtmltoimage $OPTS /tmp/story1.html "$OUTPUT_DIR/story_1_fin.png"    && echo "  ✓  story_1_fin.png"
wkhtmltoimage $OPTS /tmp/story2.html "$OUTPUT_DIR/story_2_eval.png"   && echo "  ✓  story_2_eval.png"
wkhtmltoimage $OPTS /tmp/story3.html "$OUTPUT_DIR/story_3_clases.png" && echo "  ✓  story_3_clases.png"

echo ""
echo "  Guardadas en: ${OUTPUT_DIR}"
echo ""
