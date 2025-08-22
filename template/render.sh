#!/usr/bin/env bash
set -euo pipefail

# Machines and displays to generate. Edit these arrays to add/remove combinations.
MACHINES=(
  verdin-imx8mp
  colibri-imx8x
)

DISPLAYS=(
  5inch
  7inch
  10inch
)

# Optional BASE_DEVICETREE per machine
declare -A BASE_DEVICETREE_ARRAY
BASE_DEVICETREE_ARRAY["colibri-imx8x"]='custom: "linux-toradex/arch/arm64/boot/dts/freescale/imx8qxp-colibri-iris-v2.dts"'
BASE_DEVICETREE_ARRAY["verdin-imx8mp"]='' # None: keep the default

# Paths
TPL=${TPL:-template/torizon-dtb-overlay-nxp.yaml.tpl}
OUTDIR=${OUTDIR:-.}

# Generate all combinations
for m in "${MACHINES[@]}"; do
  for d in "${DISPLAYS[@]}"; do
    # Skip 5inch for verdin-imx8mp (delivered as a binary Torizon core image)
    if [[ "$m" == "verdin-imx8mp" && "$d" == "5inch" ]]; then
      continue
    fi
    out="$OUTDIR/${m}_optologic_panel-cap-touch-${d}-lvds.yaml"
    BASE_DEVICETREE="${BASE_DEVICETREE_ARRAY["$m"]}"
    env MACHINE="$m" DISPLAY="$d" BASE_DEVICETREE="$BASE_DEVICETREE" \
      envsubst '${MACHINE} ${DISPLAY} ${BASE_DEVICETREE}' < "$TPL" > "$out"
    echo "Rendered $out"
  done
done
