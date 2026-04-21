#!/usr/bin/env bash
set -euo pipefail

CLASSES=(deathknight demonhunter druid evoker hunter mage monk paladin priest rogue shaman warlock warrior)
OUT_DIR="${OUT_DIR:-/out}"

mkdir -p "${OUT_DIR}"

# simc always prints a banner on stdout with the WoW version it was built
# against, e.g.:
#   SimulationCraft 1107-01 for World of Warcraft 11.0.7.58900 Live (...)
# We parse that once so the marketing surface can show an accurate patch
# instead of a hand-maintained string.
BUILD_BANNER="$(simc 2>&1 | head -3 || true)"
WOW_PATCH="$(echo "${BUILD_BANNER}" | grep -oE 'World of Warcraft [0-9]+(\.[0-9]+){2,3}' | head -1 | sed 's/World of Warcraft //' || true)"

{
    echo "simc_sha=${SIMC_SHA:-unknown}"
    date -u '+generated_at=%Y-%m-%dT%H:%M:%SZ'
    echo "wow_patch=${WOW_PATCH:-unknown}"
} > "${OUT_DIR}/.metadata"

for class in "${CLASSES[@]}"; do
    xml_path="${OUT_DIR}/${class}.xml"
    echo "[extract] ${class} -> ${xml_path}"
    simc \
        display_build=0 \
        spell_query="spell.class=${class}" \
        spell_query_xml_output_file="${xml_path}" \
        > /dev/null
done

echo "[extract] done. files:"
ls -lh "${OUT_DIR}"
cat "${OUT_DIR}/.metadata"
