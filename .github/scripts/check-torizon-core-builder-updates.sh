#!/bin/bash
# Copyright (C) 2026 OPTO Logic
# SPDX-License-Identifier: MIT
#
# This script checks for updates to the Torizon core builder and updates the
# workflow file if a new stable version is available.

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

latest_stable_tag=$(git ls-remote --tags https://github.com/torizon/torizoncore-builder.git \
    | awk -F/ '!/\^\{\}$/ {print $NF}' | sort -V | tail -n 1) || {
    echo -e "Failed to fetch the latest stable tag from the torizoncore-builder repository.\n"
    exit 1
}

current_tag=$(grep -oP 'TORIZON_CORE_BUILDER_VERSION:\s*\K.*' \
    $SCRIPT_DIR/../workflows/torizon-optologic-nxp-ci.yml) || {
    echo -e "Failed to extract the current Torizon core builder tag from the workflow file.\n"
    exit 1
}

if [ "$latest_stable_tag" != "$current_tag" ]; then
    echo -e "A new Torizon core builder is available: $latest_stable_tag (current: $current_tag). Updating the workflow file\n"

    sed -i "s/TORIZON_CORE_BUILDER_VERSION:\s*$current_tag/TORIZON_CORE_BUILDER_VERSION: $latest_stable_tag/g" \
        $SCRIPT_DIR/../workflows/torizon-optologic-nxp-ci.yml || {
        echo -e "Failed to update the torizon-optologic-nxp-ci.yml workflow file with the new Torizon core builder tag.\n"
        exit 1
    }

    echo "latest_stable_tag=$latest_stable_tag" >> $GITHUB_OUTPUT
    exit 2
else
    echo -e "The current Toradex revision is up to date: $current_tag\n"
    exit 0
fi
