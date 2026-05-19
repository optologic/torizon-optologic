#!/bin/bash
# Copyright (C) 2026 OPTO Logic
# SPDX-License-Identifier: MIT
#
# This script checks for updates in the Toradex manifest repository and updates
# the kernel and the template if a new revision is available. It also generates
# the yaml files based on the updated template.

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
TORADEX_BRANCH="scarthgap-7.x.y"
LINUX_RECIPE_NAME="linux-toradex-ti"

latest_stable_tag=$(git ls-remote --tags https://git.toradex.com/toradex-manifest.git \
    | awk -F/ '{print $NF}' | grep -v '\-devel' | sort -V | tail -n 1) || {
    echo -e "Failed to fetch the latest stable tag from the Toradex manifest repository.\n"
    exit 1
}

current_tag=$(grep -oP 'version:\s*"\K[^"]+' \
    $SCRIPT_DIR/../../template/torizon-dtb-overlay-ti.yaml.tpl) || {
    echo -e "Failed to extract the current Toradex tag from the workflow file.\n"
    exit 1
}

if [ "$latest_stable_tag" != "$current_tag" ]; then
    echo -e "A new Toradex manifest revision is available: $latest_stable_tag (current: $current_tag). Updating the kernel and the template\n"

    TORIZON_DOCKER_BASE_URL="https://artifacts.toradex.com/artifactory/torizoncore-oe-prod-frankfurt/$TORADEX_BRANCH"
    latest_release_torizon_docker=$(curl -s "$TORIZON_DOCKER_BASE_URL/release/" \
    | grep -Eo 'href="[0-9]+/'   | cut -d'"' -f2   | tr -d '/'   | sort -n   | tail -n1) || {
        echo -e "Failed to fetch the latest release version of Torizon Docker from the Toradex Artifactory.\n"
        exit 1
    }

    URL="https://git.toradex.com/toradex-manifest.git/tree/bsp/pinned-tdx.xml?h=$latest_stable_tag"
    meta_toradex_ti_commit=$(curl -fsSL "$URL" \
    | awk '
        /meta-toradex-ti\.git/ {found=1}
        found && /revision=/ {
            match($0, /revision="[^"]+"/)
            if (RSTART > 0) {
                rev = substr($0, RSTART+10, RLENGTH-11)
                print rev
                exit
            }
        }
    ') || {
        echo -e "Failed to fetch the meta-toradex-ti commit hash from the Toradex manifest repository.\n"
        exit 1
    }

    URL="https://git.toradex.com/meta-toradex-ti.git/tree/recipes-kernel/linux?id=$meta_toradex_ti_commit"
    LINUX_RECIPE=$(curl -fsSL "$URL" | grep -o $LINUX_RECIPE_NAME'_[^<"]*\.bb' | cut -d'?' -f1 | sort -u | sort -V | tail -n1) || {
        echo -e "Failed to fetch the linux-toradex recipe name from the meta-toradex-ti repository.\n"
        exit 1
    }

    URL="https://git.toradex.com/meta-toradex-ti.git/tree/recipes-kernel/linux/$LINUX_RECIPE?id=$meta_toradex_ti_commit"
    linux_toradex_ti_commit=$(curl -fsSL "$URL" | awk -F'"' '/^SRCREV_machine/ {print $2; exit}') || {
        echo -e "Failed to fetch the linux-toradex-ti commit hash from the meta-toradex-ti repository.\n"
        exit 1
    }

    git -C $SCRIPT_DIR/../../linux-toradex fetch || {
        echo -e "Failed to fetch the latest changes from the linux-toradex repository.\n"
        exit 1
    }

    git -C $SCRIPT_DIR/../../linux-toradex checkout $linux_toradex_ti_commit || {
        echo -e "Failed to checkout the linux-toradex repository to the new commit hash.\n"
        exit 1
    }

    sed -i "s/version:\s*\"$current_tag\"/version: \"$latest_stable_tag\"/g" \
        $SCRIPT_DIR/../../template/torizon-dtb-overlay-ti.yaml.tpl &&
    sed -i "s/build-number:\s*\"[0-9]\+\"/build-number: \"$latest_release_torizon_docker\"/g" \
        $SCRIPT_DIR/../../template/torizon-dtb-overlay-ti.yaml.tpl &&
    sed -i "s/_Tezi_$current_tag/_Tezi_$latest_stable_tag/g" \
        $SCRIPT_DIR/../../template/torizon-dtb-overlay-ti.yaml.tpl || {
        echo -e "Failed to update the torizon-dtb-overlay-ti.yaml.tpl template file with the new Toradex tag.\n"
        exit 1
    }

    echo -e "Generate the yaml files based on the updated template\n"

    $SCRIPT_DIR/../../template/render.sh

    echo "latest_stable_tag=$latest_stable_tag" >> $GITHUB_OUTPUT
    exit 2
else
    echo -e "The current Toradex revision is up to date: $current_tag\n"
    exit 0
fi
