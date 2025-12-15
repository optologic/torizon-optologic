# Torizon core builder configurations for Optologic accessories

This repository contains the Torizon core builder configurations for Optologic
displays on Toradex SoMs.

[![Torizon TI Optologic CI Build](https://github.com/optologic/torizon-optologic/actions/workflows/torizon-optologic-ti-ci.yml/badge.svg?branch=torizon-ti-7.x.y&event=push)](https://github.com/optologic/torizon-optologic/actions/workflows/torizon-optologic-ti-ci.yml)
[![Torizon NXP Optologic CI Build](https://github.com/optologic/torizon-optologic/actions/workflows/torizon-optologic-nxp-ci.yml/badge.svg?branch=torizon-nxp-7.x.y&event=push)](https://github.com/optologic/torizon-optologic/actions/workflows/torizon-optologic-nxp-ci.yml)

## Setting up Torizon Core Builder

This repository provides Torizon configurations for building Torizon Core
images. You should first become familiar with the [Torizon Core
Builder](https://developer.toradex.com/torizon/os-customization/torizoncore-builder-tool-customizing-torizoncore-images).
Please follow the link to set up the Torizon Core Builder environment.

## Obtaining the sources

Once you have installed the Torizon Core Builder, you must checkout the
appropriate branch for your hardware and Torizon version on this repository.
For example:
 - [`torizon-ti-7.x.y`](https://github.com/optologic/torizon-optologic/tree/torizon-ti-7.x.y) for the Toradex SoMs based on TI AM62x SoC
 - [`torizon-nxp-7.x.y`](https://github.com/optologic/torizon-optologic/tree/torizon-nxp-7.x.y) for the Toradex SoMs based on NXP i.MX 7ULP SoC

You must also clone the submodules:

```bash
git clone -b <branch_name> --recurse-submodules https://github.com/optologic/torizon-optologic.git
```

## Supported Hardware

We currently support the following Toradex SoMs:
 - `verdin-am62`
 - `verdin-am62p`
 - `verdin-imx8mp`
 - `verdin-imx8mm` (Requires the [Verdin DSI to LVDS adapter](https://www.toradex.com/accessories/verdin-dsi-to-lvds-adapter) with a compatible carrier board)
 - `verdin-imx95`
 - `colibri-imx8x` (Requires the Iris v2.0 carrier board)

These may be combined with the following OPTO Logic displays:
 - 5 inches (SCX0500132GGC06) with capacitive touchscreen (ILI2131)
 - 7 inches (SCX0700117GGC03) with capacitive touchscreen (ILI2117A)
 - 10.1 inches (SCX1001511GGC49) with capacitive touchscreen (ILI2511)

**NOTE:** The Verdin i.MX8MP SoC support for the 5" display is delivered as a binary
Torizon Core image instead of a torizoncore-builder configuration like the rest of these configurations.
You can [download our latest image built through the CI](https://github.com/optologic/meta-optologic/releases). If you want to regularly keep this
image updated, you'll have to regularly build it. Follow the documentation of our [meta-optologic](https://github.com/optologic/meta-optologic) to do so.
(This image requires a [kernel patch](https://developer.toradex.com/linux-bsp/application-development/multimedia/display-output-resolution-and-timings-linux/#verdin-imx8m-plus-lvds-known-issues) which is not supported by torizoncore-builder).

## Building the Torizon Core image

You should first select the Torizon Core Builder configuration file
corresponding to your hardware. For example, for the Verdin AM62 with a
7-inch display, you would use the `verdin-am62_optologic_panel-cap-touch-7inch-SCX0700117GGC03-lvds.yaml` file.

```bash
# Example for Verdin AM62 with OPTO Logic 7-inch display
torizoncore-builder build --file verdin-am62_optologic_panel-cap-touch-7inch-SCX0700117GGC03-lvds.yaml
```

If you have more specific needs, you are welcome to extend or import the
configuration files in this repository into your own Torizon Core Builder
distribution.

## Deploying with Toradex Easy Installer

The resulting image will be output in the `build` directory. You can then deploy
this image using [Toradex Easy Installer
(Tezi)](https://developer.toradex.com/software/toradex-easy-installer) or any
other method you prefer.

For instance, you may copy the
`build/torizon_verdin-am62_optologic_panel-cap-touch-7inch-SCX0700117GGC03-lvds_Tezi_7.3.0` on
your Tezi media (USB stick, SD card, etc.) and boot your Toradex SoM to install
it via the GUI.

## Testing the Display

The Torizon image is very minimal and doesn't include a graphical server without
an additional docker application. You may run one of the [Torizon Weston debian
containers](https://developer.toradex.com/torizon/application-development/provided-containers/list-of-container-images-for-torizon)
to test the display. Example for the Verdin i.MX8MP:

```bash
docker run -d --rm \
   --name weston \
   --privileged \
   --device=/dev/dri \
   --device=/dev/input \
   -v /tmp:/tmp \
   -v /run/udev:/run/udev \
   -v /var/run/dbus:/var/run/dbus \
   -v /etc:/etc \
   -e XDG_RUNTIME_DIR=/tmp \
   --entrypoint=weston \
   torizon/weston-imx8:4 \
   --backend=drm-backend.so --idle-time=0 --log=/tmp/weston.log
```

## Contribute or Contact

Please submit any patches and bug reports about this repository to the maintainer:

Maintainer: OPTO Logic Technology S.A. <support@optologic.ch>
