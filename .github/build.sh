#!/bin/bash
# Usage: .github/build.sh WORK DEST
#
# Builds TWRP for a v1-unlocked Echo Dot (2nd Gen), target omni_biscuit,
# on Ubuntu 20.04. It syncs TWRP's twrp-9.0 minimal manifest into WORK,
# with bootable/recovery from amazon-oss, whose android-9 branch adds the
# screenless and LED support this tree uses, and bengris32's bcbtool, which
# the tree's boot control links. It adds this device tree and the kernel,
# and copies recovery.img and the synced revisions (manifest.xml) into DEST.
set -euo pipefail

manifest=https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git
recovery_commit=8493941882f70204a10c46f19bb30ebd13a6da89
bcbtool_commit=98506d322351850dab688687f2a3a948e64f3495
kernel_release=https://github.com/bboe/android_kernel_amazon_biscuit/releases/download/v0.1/Image.gz-dtb
kernel_sha256=c6e138cb6dbad1313ee5b8ff074b712b3272d0c88e684b25e023a5e11dc90795

tree=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$1" "$2"
work=$(cd "$1" && pwd)
dest=$(cd "$2" && pwd)

if [ ! -x "$work/bin/repo" ]; then
  mkdir -p "$work/bin"
  curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo -o "$work/bin/repo"
  chmod +x "$work/bin/repo"
fi
export PATH="$work/bin:$PATH"

mkdir -p "$work/src"
cd "$work/src"
repo init -q --depth=1 -u "$manifest" -b twrp-9.0
mkdir -p .repo/local_manifests
cat > .repo/local_manifests/biscuit.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="amazon-oss" fetch="https://github.com/amazon-oss/" />
  <remove-project name="android_bootable_recovery" />
  <project path="bootable/recovery" name="android_bootable_recovery" remote="amazon-oss"
           revision="$recovery_commit" upstream="android-9" />
  <remote name="bengris32" fetch="https://github.com/bengris32/" />
  <project path="external/bcbtool" name="bcbtool" remote="bengris32"
           revision="$bcbtool_commit" upstream="master" />
</manifest>
EOF
repo sync -q -c -j"$(nproc)" --no-tags --no-clone-bundle --force-sync

rm -rf device/amazon/mt8163-echo
mkdir -p device/amazon
git clone -q --no-local "$tree" device/amazon/mt8163-echo
mkdir -p device/amazon/mt8163-echo/biscuit/prebuilts
curl -fsSL "$kernel_release" -o device/amazon/mt8163-echo/biscuit/prebuilts/Image.gz-dtb
echo "$kernel_sha256  device/amazon/mt8163-echo/biscuit/prebuilts/Image.gz-dtb" | sha256sum -c -

set +eu
# shellcheck disable=SC1091
. build/envsetup.sh
lunch omni_biscuit-eng
set -e
if [ "${TARGET_PRODUCT:-}" != omni_biscuit ]; then
  echo "lunch did not select omni_biscuit" >&2
  exit 1
fi
mka recoveryimage
set -u

cp out/target/product/biscuit/recovery.img "$dest/"
repo manifest -r -o "$dest/manifest.xml"
cd "$dest"
sha256sum recovery.img
