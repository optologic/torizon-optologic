# Toradex Easy Installer Configuration with OPTO Logic ${DISPLAY} Display and Touchscreen for ${MACHINE}
input:
  easy-installer:
    toradex-feed:
      version: "${TORADEX_BSP_VERSION}"
      release: quarterly
      machine: ${MACHINE}
      distro: torizon
      variant: torizon-docker
      build-number: "${TORADEX_BSP_BUILD}"
customization:
  device-tree:
    include-dirs:
      - linux-toradex/include
      - linux-toradex/arch/arm64/boot/dts/freescale
      - device-tree-overlays-optologic
    ${BASE_DEVICETREE}
    overlays:
      remove:
        - ${MACHINE}_hdmi_overlay.dtbo
        - ${MACHINE}_dsi-to-hdmi_overlay.dtbo
      add:
        - device-tree-overlays-optologic/${MACHINE}_optologic_panel-cap-touch-${DISPLAY}-lvds_overlay.dts
output:
  easy-installer:
    local: build/torizon_${MACHINE}_optologic_panel-cap-touch-${DISPLAY}-lvds_Tezi_${TORADEX_BSP_VERSION}
    name: "Toradex ${MACHINE} with OPTO Logic ${DISPLAY} Display and Touchscreen"
