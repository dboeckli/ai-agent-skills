#!/usr/bin/env bash
#
# Claude Code statusLine: zeigt Modell, Kontext-/Gesamt-Tokens, Kosten,
# geaenderte Zeilen und Session-Dauer.
# Bekommt bei jeder Aktualisierung ein JSON per stdin. Benoetigt: jq
#
set -euo pipefail

input="$(cat)"

# --- Werte aus dem stdin-JSON lesen ---
model="$(jq -r '.model.display_name // "unknown"' <<<"$input")"
model_id="$(jq -r '.model.id // ""' <<<"$input")"
cost="$(jq -r '.cost.total_cost_usd // 0' <<<"$input")"
transcript="$(jq -r '.transcript_path // ""' <<<"$input")"
added="$(jq -r '.cost.total_lines_added // 0' <<<"$input")"
removed="$(jq -r '.cost.total_lines_removed // 0' <<<"$input")"
duration_ms="$(jq -r '.cost.total_duration_ms // 0' <<<"$input")"

# --- Kontextlimit je nach Modell (1M-Varianten erkennen) ---
if [[ "$model_id" == *"[1m]"* ]]; then
    limit=1000000
    limit_label="1M"
else
    limit=200000
    limit_label="200k"
fi

# --- Tokens aus dem Transcript ---
# ctx = aktuelle Kontext-Belegung (letzte Assistant-Nachricht: input + cache_read + cache_creation)
# tot = kumulierte Gesamt-Tokens der Session (alle Nachrichten, alle Felder)
ctx=0
tot=0
if [[ -n "$transcript" && -f "$transcript" ]]; then
    ctx="$(tac "$transcript" 2>/dev/null \
        | jq -R 'fromjson? | .message.usage // empty
                 | ((.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))' \
              2>/dev/null \
        | head -n1)"
    [[ -z "$ctx" ]] && ctx=0

    tot="$(jq -R 'fromjson? | .message.usage // empty
                  | ((.input_tokens // 0) + (.output_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' \
              "$transcript" 2>/dev/null \
        | awk '{s+=$1} END {print s+0}')"
    [[ -z "$tot" ]] && tot=0
fi

# --- Hilfsfunktionen ---
human() {
    awk -v n="$1" 'BEGIN {
        if (n >= 1000000) printf "%.1fM", n/1000000;
        else if (n >= 1000) printf "%.1fk", n/1000;
        else printf "%d", n;
    }'
}

fmt_dur() {
    awk -v ms="$1" 'BEGIN {
        s = int(ms/1000); h = int(s/3600); m = int((s%3600)/60); sec = s%60;
        if (h > 0) printf "%dh%dm", h, m;
        else if (m > 0) printf "%dm%ds", m, sec;
        else printf "%ds", sec;
    }'
}

pct="$(awk -v c="$ctx" -v l="$limit" 'BEGIN { printf "%.0f", (l>0 ? c*100/l : 0) }')"
cost_fmt="$(awk -v c="$cost" 'BEGIN { printf "%.2f", c }')"

# --- Farb-Warnung fuer die Kontext-Belegung (gelb ab 60 %, rot ab 80 %) ---
if [[ "$pct" -ge 80 ]]; then
    ctx_color=$'\033[31m'   # rot
    RESET=$'\033[0m'
elif [[ "$pct" -ge 60 ]]; then
    ctx_color=$'\033[33m'   # gelb
    RESET=$'\033[0m'
else
    ctx_color=""
    RESET=""
fi

printf '🤖 %s  |  🧠 %s%s/%s (%s%%)%s  |  📊 %s total  |  💰 $%s  |  📝 +%s/-%s  |  ⏱ %s' \
    "$model" \
    "$ctx_color" "$(human "$ctx")" "$limit_label" "$pct" "$RESET" \
    "$(human "$tot")" \
    "$cost_fmt" \
    "$added" "$removed" \
    "$(fmt_dur "$duration_ms")"
