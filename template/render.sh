#!/usr/bin/env bash
set -euo pipefail

# Machines and displays to generate. Edit these arrays to add/remove combinations.
MACHINES=(
  verdin-am62
  verdin-am62p
)

DISPLAYS=(
  5inch-SCX0500132GGC06
  7inch-SCX0700117GGC03
  10inch-SCX1001511GGC49
)

# Paths
TPL=${TPL:-template/torizon-dtb-overlay-ti.yaml.tpl}
OUTDIR=${OUTDIR:-.}

# Generate all combinations
for m in "${MACHINES[@]}"; do
  for d in "${DISPLAYS[@]}"; do
    out="$OUTDIR/${m}_optologic_panel-cap-touch-${d}-lvds.yaml"
    MACHINE="$m" DISPLAY="$d" envsubst '${MACHINE} ${DISPLAY}' < "$TPL" > "$out"
    echo "Rendered $out"
  done
done
