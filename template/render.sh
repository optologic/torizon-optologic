#!/usr/bin/env bash
set -euo pipefail

# Machines and displays to generate. Edit these arrays to add/remove combinations.
MACHINES=(
  colibri-imx8x
  verdin-imx8mp
  verdin-imx8mm
  verdin-imx95
)

DISPLAYS=(
  5inch-SCX0500132GGC06
  7inch-SCX0700117GGC03
  10inch-SCX1001511GGC49
)

# Specific Toradex BSP version and build per machine
declare -A TORADEX_BSP_VERSION_ARRAY
TORADEX_BSP_VERSION_ARRAY["default"]='7.3.0'
TORADEX_BSP_VERSION_ARRAY["verdin-imx95"]='7.4.0'

# Specific Toradex BSP version and build per machine
declare -A TORADEX_BSP_BUILD_ARRAY
TORADEX_BSP_BUILD_ARRAY["default"]='18'
TORADEX_BSP_BUILD_ARRAY["verdin-imx95"]='28'

# Optional BASE_DEVICETREE per machine
declare -A BASE_DEVICETREE_ARRAY
BASE_DEVICETREE_ARRAY["colibri-imx8x"]='custom: "linux-toradex/arch/arm64/boot/dts/freescale/imx8qxp-colibri-iris-v2.dts"'
BASE_DEVICETREE_ARRAY["verdin-imx8mp"]='' # None: keep the default
BASE_DEVICETREE_ARRAY["verdin-imx8mm"]='' # None: keep the default
BASE_DEVICETREE_ARRAY["verdin-imx95"]='' # None: keep the default

# Paths
TPL=${TPL:-template/torizon-dtb-overlay-nxp.yaml.tpl}
OUTDIR=${OUTDIR:-.}

# Generate all combinations
for m in "${MACHINES[@]}"; do

  set +u

  if [ -n "${TORADEX_BSP_VERSION_ARRAY[$m]}" ]; then
    TORADEX_BSP_VERSION="${TORADEX_BSP_VERSION_ARRAY[$m]}"
  else
    TORADEX_BSP_VERSION="${TORADEX_BSP_VERSION_ARRAY["default"]}"
  fi

  if [ -n "${TORADEX_BSP_BUILD_ARRAY[$m]}" ]; then
    TORADEX_BSP_BUILD="${TORADEX_BSP_BUILD_ARRAY[$m]}"
  else
    TORADEX_BSP_BUILD="${TORADEX_BSP_BUILD_ARRAY["default"]}"
  fi

  set -u

  for d in "${DISPLAYS[@]}"; do
    # Skip 5inch for verdin-imx8mp (delivered as a binary Torizon core image)
    if [[ "$m" == "verdin-imx8mp" && "$d" == "5inch" ]]; then
      continue
    fi
    out="$OUTDIR/${m}_optologic_panel-cap-touch-${d}-lvds.yaml"
    BASE_DEVICETREE="${BASE_DEVICETREE_ARRAY["$m"]}"
    env MACHINE="$m" DISPLAY="$d" BASE_DEVICETREE="$BASE_DEVICETREE" \
        TORADEX_BSP_VERSION="$TORADEX_BSP_VERSION" TORADEX_BSP_BUILD="$TORADEX_BSP_BUILD" \
      envsubst '${MACHINE} ${DISPLAY} ${BASE_DEVICETREE} ${TORADEX_BSP_VERSION} ${TORADEX_BSP_BUILD}' < "$TPL" > "$out"
    echo "Rendered $out"
  done
done
