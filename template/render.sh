#!/usr/bin/env bash
set -euo pipefail

# Machines and displays to generate. Edit these arrays to add/remove combinations.
MACHINES=(
  verdin-imx8mp
)

DISPLAYS=(
  5inch
  7inch
  10inch
)

# Paths
TPL=${TPL:-template/torizon-dtb-overlay-nxp.yaml.tpl}
OUTDIR=${OUTDIR:-.}

# Generate all combinations
for m in "${MACHINES[@]}"; do
  for d in "${DISPLAYS[@]}"; do
    out="$OUTDIR/${m}_optologic_panel-cap-touch-${d}-lvds.yaml"
    MACHINE="$m" DISPLAY="$d" envsubst '${MACHINE} ${DISPLAY}' < "$TPL" > "$out"
    echo "Rendered $out"
  done
done
